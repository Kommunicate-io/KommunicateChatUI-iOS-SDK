import AVFoundation
import Foundation

protocol KMVoiceAudioRecorderDelegate: AnyObject {
    func voiceAudioRecorder(_ recorder: KMVoiceAudioRecorder, didCapture audioData: Data, generation: Int)
    func voiceAudioRecorderDidDetectNoSpeech(_ recorder: KMVoiceAudioRecorder, generation: Int)
    func voiceAudioRecorder(_ recorder: KMVoiceAudioRecorder, didFail error: Error, generation: Int)
}

final class KMVoiceAudioRecorder {
    enum RecorderError: LocalizedError {
        case invalidInputFormat
        case converterUnavailable
        case conversionFailed

        var errorDescription: String? {
            switch self {
            case .invalidInputFormat: return "The microphone input format is unavailable"
            case .converterUnavailable: return "The microphone audio format cannot be converted"
            case .conversionFailed: return "Microphone audio conversion failed"
            }
        }
    }

    private enum Constants {
        static let sampleRate = 16_000.0
        static let bytesPerSample = 2
        static let calibrationDuration = 0.12
        static let requiredSpeechFrames = 2
        static let startNoiseFactor = 1.8
        static let endNoiseFactor = 1.5
        static let noiseSmoothing = 0.95
        static let calibrationSmoothing = 0.7
        static let initialNoiseRMS = 0.002 * Double(Int16.max)
        static let minimumNoiseRMS = 0.00005 * Double(Int16.max)
        static let minimumSpeechRMS = 120.0
        static let endSilenceDuration = 2.0
        static let maximumSegmentDuration = 30.0
        static let preRollBytes = 16_000
    }

    weak var delegate: KMVoiceAudioRecorderDelegate?

    private let audioEngine: AVAudioEngine
    private let processingQueue = DispatchQueue(label: "io.kommunicate.voice-recorder")
    private var converter: AVAudioConverter?
    private var targetFormat: AVAudioFormat?
    private var generation = 0
    private var isRecording = false
    private var tapInstalled = false
    private var noiseRMS = Constants.initialNoiseRMS
    private var calibrationSamples = 0
    private var consecutiveSpeechFrames = 0
    private var silenceSamples = 0
    private var totalSamples = 0
    private var speechDetected = false
    private var preRoll = Data()
    private var capturedAudio = Data()

    init(audioEngine: AVAudioEngine = AVAudioEngine()) {
        self.audioEngine = audioEngine
    }

    func start(generation: Int) throws -> Bool {
        let canStart = processingQueue.sync { () -> Bool in
            guard !isRecording else { return false }
            isRecording = true
            self.generation = generation
            calibrationSamples = 0
            consecutiveSpeechFrames = 0
            silenceSamples = 0
            totalSamples = 0
            speechDetected = false
            preRoll.removeAll(keepingCapacity: true)
            capturedAudio.removeAll(keepingCapacity: true)
            return true
        }
        guard canStart else { return false }

        let inputNode = audioEngine.inputNode
        let inputFormat = inputNode.outputFormat(forBus: 0)
        guard inputFormat.sampleRate > 0, inputFormat.channelCount > 0,
              let targetFormat = AVAudioFormat(
                commonFormat: .pcmFormatInt16,
                sampleRate: Constants.sampleRate,
                channels: 1,
                interleaved: false
              )
        else {
            processingQueue.sync { isRecording = false }
            throw RecorderError.invalidInputFormat
        }
        guard let converter = AVAudioConverter(from: inputFormat, to: targetFormat) else {
            processingQueue.sync { isRecording = false }
            throw RecorderError.converterUnavailable
        }

        processingQueue.sync {
            self.converter = converter
            self.targetFormat = targetFormat
        }
        inputNode.installTap(onBus: 0, bufferSize: 1_024, format: inputFormat) { [weak self] buffer, _ in
            guard let self = self, let copiedBuffer = self.copy(buffer: buffer) else { return }
            self.processingQueue.async {
                self.process(buffer: copiedBuffer, generation: generation)
            }
        }
        tapInstalled = true

        do {
            audioEngine.prepare()
            try audioEngine.start()
            return true
        } catch {
            stop()
            throw error
        }
    }

    func stop() {
        processingQueue.sync {
            isRecording = false
            converter = nil
            targetFormat = nil
            preRoll.removeAll(keepingCapacity: false)
            capturedAudio.removeAll(keepingCapacity: false)
        }
        stopEngine()
    }

    func resetNoiseCalibration() {
        processingQueue.async {
            self.noiseRMS = Constants.initialNoiseRMS
        }
    }

    private func process(buffer: AVAudioPCMBuffer, generation: Int) {
        guard isRecording, self.generation == generation else { return }
        do {
            let pcmData = try convertedPCMData(from: buffer)
            guard !pcmData.isEmpty else { return }
            processPCMData(pcmData, generation: generation)
        } catch {
            finish(with: .failure(error), generation: generation)
        }
    }

    private func processPCMData(_ data: Data, generation: Int) {
        let sampleCount = data.count / Constants.bytesPerSample
        guard sampleCount > 0 else { return }

        let rms: Double = data.withUnsafeBytes { rawBuffer in
            let samples = rawBuffer.bindMemory(to: Int16.self)
            let sum = samples.reduce(into: 0.0) { result, sample in
                let value = Double(sample)
                result += value * value
            }
            return sqrt(sum / Double(sampleCount))
        }

        totalSamples += sampleCount
        let calibrationLimit = Int(Constants.sampleRate * Constants.calibrationDuration)
        if calibrationSamples < calibrationLimit {
            let calibrationCeiling = max(Constants.minimumNoiseRMS, noiseRMS * 1.5)
            let calibrationRMS = min(rms, calibrationCeiling)
            noiseRMS = max(
                Constants.minimumNoiseRMS,
                Constants.calibrationSmoothing * noiseRMS
                    + (1 - Constants.calibrationSmoothing) * calibrationRMS
            )
            calibrationSamples += sampleCount
        }

        appendToPreRoll(data)
        let startThreshold = max(Constants.minimumSpeechRMS, noiseRMS * Constants.startNoiseFactor)
        if calibrationSamples >= calibrationLimit, !speechDetected, rms < startThreshold {
            noiseRMS = max(
                Constants.minimumNoiseRMS,
                Constants.noiseSmoothing * noiseRMS + (1 - Constants.noiseSmoothing) * rms
            )
        }
        let endThreshold = max(Constants.minimumSpeechRMS, noiseRMS * Constants.endNoiseFactor)

        if !speechDetected {
            consecutiveSpeechFrames = rms >= startThreshold ? consecutiveSpeechFrames + 1 : 0
            if consecutiveSpeechFrames >= Constants.requiredSpeechFrames {
                speechDetected = true
                capturedAudio.append(preRoll)
                preRoll.removeAll(keepingCapacity: false)
            }
        } else {
            capturedAudio.append(data)
            silenceSamples = rms < endThreshold ? silenceSamples + sampleCount : 0
        }

        let maximumSamples = Int(Constants.sampleRate * Constants.maximumSegmentDuration)
        let endSilenceSamples = Int(Constants.sampleRate * Constants.endSilenceDuration)
        if speechDetected, silenceSamples >= endSilenceSamples {
            finish(with: .success(capturedAudio), generation: generation)
        } else if totalSamples >= maximumSamples {
            if speechDetected, !capturedAudio.isEmpty {
                finish(with: .success(capturedAudio), generation: generation)
            } else {
                finishWithoutSpeech(generation: generation)
            }
        }
    }

    private func appendToPreRoll(_ data: Data) {
        preRoll.append(data)
        if preRoll.count > Constants.preRollBytes {
            preRoll.removeFirst(preRoll.count - Constants.preRollBytes)
        }
    }

    private func convertedPCMData(from inputBuffer: AVAudioPCMBuffer) throws -> Data {
        guard let converter = converter, let targetFormat = targetFormat else {
            throw RecorderError.converterUnavailable
        }

        let ratio = targetFormat.sampleRate / inputBuffer.format.sampleRate
        let capacity = AVAudioFrameCount(ceil(Double(inputBuffer.frameLength) * ratio)) + 32
        guard let outputBuffer = AVAudioPCMBuffer(pcmFormat: targetFormat, frameCapacity: capacity) else {
            throw RecorderError.conversionFailed
        }

        var suppliedInput = false
        var conversionError: NSError?
        let status = converter.convert(to: outputBuffer, error: &conversionError) { _, inputStatus in
            if suppliedInput {
                inputStatus.pointee = .noDataNow
                return nil
            }
            suppliedInput = true
            inputStatus.pointee = .haveData
            return inputBuffer
        }
        guard conversionError == nil,
              status == .haveData || status == .inputRanDry || status == .endOfStream,
              let channelData = outputBuffer.int16ChannelData
        else {
            throw conversionError ?? RecorderError.conversionFailed
        }
        return Data(bytes: channelData[0], count: Int(outputBuffer.frameLength) * Constants.bytesPerSample)
    }

    private func copy(buffer: AVAudioPCMBuffer) -> AVAudioPCMBuffer? {
        guard let copy = AVAudioPCMBuffer(pcmFormat: buffer.format, frameCapacity: buffer.frameCapacity) else {
            return nil
        }
        copy.frameLength = buffer.frameLength
        let sourceBuffers = UnsafeMutableAudioBufferListPointer(buffer.mutableAudioBufferList)
        let destinationBuffers = UnsafeMutableAudioBufferListPointer(copy.mutableAudioBufferList)
        for (source, destination) in zip(sourceBuffers, destinationBuffers) {
            guard let sourceData = source.mData, let destinationData = destination.mData else { continue }
            memcpy(destinationData, sourceData, Int(source.mDataByteSize))
        }
        return copy
    }

    private func finish(with result: Result<Data, Error>, generation: Int) {
        guard isRecording, self.generation == generation else { return }
        isRecording = false
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.stopEngine()
            switch result {
            case let .success(audioData):
                self.delegate?.voiceAudioRecorder(self, didCapture: audioData, generation: generation)
            case let .failure(error):
                self.delegate?.voiceAudioRecorder(self, didFail: error, generation: generation)
            }
        }
    }

    private func finishWithoutSpeech(generation: Int) {
        guard isRecording, self.generation == generation else { return }
        isRecording = false
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.stopEngine()
            self.delegate?.voiceAudioRecorderDidDetectNoSpeech(self, generation: generation)
        }
    }

    private func stopEngine() {
        if tapInstalled {
            audioEngine.inputNode.removeTap(onBus: 0)
            tapInstalled = false
        }
        audioEngine.stop()
        audioEngine.reset()
    }
}
