import AVFoundation
import Foundation
import KommunicateCore_iOS_SDK

protocol KMVoiceModeControllerDelegate: AnyObject {
    func voiceModeController(_ controller: KMVoiceModeController, didChange state: KMVoiceModeController.State)
    func voiceModeController(_ controller: KMVoiceModeController, didProduceTranscript transcript: String) -> Bool
    func voiceModeController(_ controller: KMVoiceModeController, didFail error: Error)
}

final class KMVoiceModeController: NSObject {
    enum State: Equatable {
        case idle
        case listening
        case transcribing
        case sending
        case waitingForResponse
        case processingResponse
        case speaking
        case error
    }

    enum ControllerError: LocalizedError {
        case voiceModeUnavailable
        case microphonePermissionRequired
        case audioSessionUnavailable

        var errorDescription: String? {
            switch self {
            case .voiceModeUnavailable: return "Voice mode is unavailable"
            case .microphonePermissionRequired: return "Microphone permission is required for voice mode"
            case .audioSessionUnavailable: return "Unable to activate the audio session"
            }
        }
    }

    static var isVoiceModeAvailable: Bool {
        return KMCoreUserDefaultsHandler.isVoiceChatEnabled()
            && !KMCoreSettings.isAgentAppConfigurationEnabled()
    }

    private enum Constants {
        static let maximumProcessedMessageIDs = 100
        static let recorderRetryDelay = 0.05
    }

    weak var delegate: KMVoiceModeControllerDelegate?
    private(set) var state: State = .idle
    private(set) var isActive = false

    private let audioSession: AVAudioSession
    private let apiClient: KMCoreVoiceAPIClient
    private let audioRecorder: KMVoiceAudioRecorder
    private let playbackManager: KMVoicePlaybackManager
    private var conversationID: Int64 = 0
    private var sessionGeneration = 0
    private var processedMessageIDs = Set<String>()
    private var processedMessageIDOrder = [String]()

    init(
        delegate: KMVoiceModeControllerDelegate,
        audioSession: AVAudioSession = .sharedInstance(),
        apiClient: KMCoreVoiceAPIClient = KMCoreVoiceAPIClient(),
        audioRecorder: KMVoiceAudioRecorder = KMVoiceAudioRecorder(),
        playbackManager: KMVoicePlaybackManager = KMVoicePlaybackManager()
    ) {
        self.delegate = delegate
        self.audioSession = audioSession
        self.apiClient = apiClient
        self.audioRecorder = audioRecorder
        self.playbackManager = playbackManager
        super.init()

        self.audioRecorder.delegate = self
        self.playbackManager.delegate = self
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(audioSessionWasInterrupted(_:)),
            name: AVAudioSession.interruptionNotification,
            object: audioSession
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(audioRouteDidChange(_:)),
            name: AVAudioSession.routeChangeNotification,
            object: audioSession
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    static func requestMicrophonePermission(completion: @escaping (Bool) -> Void) {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }

    @discardableResult
    func start(conversationID: Int64) -> Bool {
        dispatchPrecondition(condition: .onQueue(.main))
        if isActive {
            return true
        }
        guard Self.isVoiceModeAvailable else {
            notify(error: ControllerError.voiceModeUnavailable)
            return false
        }
        guard audioSession.recordPermission == .granted else {
            notify(error: ControllerError.microphonePermissionRequired)
            return false
        }

        do {
            try audioSession.setCategory(
                .playAndRecord,
                mode: .voiceChat,
                options: [.defaultToSpeaker, .allowBluetoothHFP]
            )
            try audioSession.setActive(true)
        } catch {
            notify(error: ControllerError.audioSessionUnavailable)
            return false
        }

        self.conversationID = conversationID
        sessionGeneration += 1
        isActive = true
        processedMessageIDs.removeAll(keepingCapacity: true)
        processedMessageIDOrder.removeAll(keepingCapacity: true)
        audioRecorder.resetNoiseCalibration()
        beginListening(generation: sessionGeneration)
        return true
    }

    func stop() {
        dispatchPrecondition(condition: .onQueue(.main))
        let wasActive = isActive
        isActive = false
        sessionGeneration += 1
        audioRecorder.stop()
        apiClient.cancelActiveRequest()
        playbackManager.stop()
        processedMessageIDs.removeAll(keepingCapacity: false)
        processedMessageIDOrder.removeAll(keepingCapacity: false)
        if wasActive {
            try? audioSession.setActive(false, options: .notifyOthersOnDeactivation)
        }
        update(state: .idle)
    }

    func release() {
        stop()
        NotificationCenter.default.removeObserver(self)
        delegate = nil
    }

    @discardableResult
    func handleBotMessage(identifier: String?, text: String?) -> Bool {
        dispatchPrecondition(condition: .onQueue(.main))
        guard isActive,
              let normalizedText = text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !normalizedText.isEmpty
        else {
            return false
        }

        let messageID = identifier ?? ""
        guard messageID.isEmpty || !processedMessageIDs.contains(messageID) else {
            return false
        }
        if !messageID.isEmpty {
            remember(messageID: messageID)
        }

        let generation = sessionGeneration
        audioRecorder.stop()
        update(state: .processingResponse)
        apiClient.synthesizeText(normalizedText) { [weak self] response, error in
            DispatchQueue.main.async {
                guard let self = self, self.isCurrent(generation: generation) else { return }
                if let error = error {
                    self.recover(from: error, generation: generation)
                    return
                }
                guard let response = response else {
                    self.recover(from: ControllerError.audioSessionUnavailable, generation: generation)
                    return
                }

                do {
                    self.update(state: .speaking)
                    try self.playbackManager.play(
                        audioData: response.audioData,
                        contentType: response.contentType
                    )
                } catch {
                    self.recover(from: error, generation: generation)
                }
            }
        }
        return true
    }

    private func beginListening(generation: Int) {
        guard isCurrent(generation: generation) else { return }
        do {
            if try audioRecorder.start(generation: generation) {
                update(state: .listening)
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + Constants.recorderRetryDelay) { [weak self] in
                    self?.beginListening(generation: generation)
                }
            }
        } catch {
            fail(with: error, generation: generation)
        }
    }

    private func transcribe(audioData: Data, generation: Int) {
        guard isCurrent(generation: generation) else { return }
        update(state: .transcribing)
        apiClient.transcribePCMAudio(audioData, conversationID: conversationID) { [weak self] transcript, error in
            DispatchQueue.main.async {
                guard let self = self, self.isCurrent(generation: generation) else { return }
                if let error = error {
                    self.recover(from: error, generation: generation)
                    return
                }

                let normalizedTranscript = transcript?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                guard !normalizedTranscript.isEmpty else {
                    self.beginListening(generation: generation)
                    return
                }

                self.update(state: .sending)
                if self.delegate?.voiceModeController(
                    self,
                    didProduceTranscript: normalizedTranscript
                ) == true {
                    self.update(state: .waitingForResponse)
                } else {
                    self.beginListening(generation: generation)
                }
            }
        }
    }

    private func recover(from error: Error, generation: Int) {
        guard isCurrent(generation: generation) else { return }
        update(state: .error)
        delegate?.voiceModeController(self, didFail: error)
        beginListening(generation: generation)
    }

    private func fail(with error: Error, generation: Int) {
        guard isCurrent(generation: generation) else { return }
        isActive = false
        sessionGeneration += 1
        audioRecorder.stop()
        apiClient.cancelActiveRequest()
        playbackManager.stop()
        processedMessageIDs.removeAll(keepingCapacity: false)
        processedMessageIDOrder.removeAll(keepingCapacity: false)
        try? audioSession.setActive(false, options: .notifyOthersOnDeactivation)
        update(state: .error)
        delegate?.voiceModeController(self, didFail: error)
    }

    private func notify(error: Error) {
        update(state: .error)
        delegate?.voiceModeController(self, didFail: error)
    }

    private func isCurrent(generation: Int) -> Bool {
        return isActive && sessionGeneration == generation
    }

    private func update(state: State) {
        self.state = state
        delegate?.voiceModeController(self, didChange: state)
    }

    private func remember(messageID: String) {
        processedMessageIDs.insert(messageID)
        processedMessageIDOrder.append(messageID)
        if processedMessageIDOrder.count > Constants.maximumProcessedMessageIDs {
            let oldestID = processedMessageIDOrder.removeFirst()
            processedMessageIDs.remove(oldestID)
        }
    }

    @objc private func audioSessionWasInterrupted(_ notification: Notification) {
        guard isActive,
              let rawType = notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt,
              AVAudioSession.InterruptionType(rawValue: rawType) == .began
        else {
            return
        }
        stop()
    }

    @objc private func audioRouteDidChange(_ notification: Notification) {
        guard isActive,
              let rawReason = notification.userInfo?[AVAudioSessionRouteChangeReasonKey] as? UInt,
              AVAudioSession.RouteChangeReason(rawValue: rawReason) == .oldDeviceUnavailable
        else {
            return
        }
        stop()
    }
}

extension KMVoiceModeController: KMVoiceAudioRecorderDelegate {
    func voiceAudioRecorder(
        _ recorder: KMVoiceAudioRecorder,
        didCapture audioData: Data,
        generation: Int
    ) {
        transcribe(audioData: audioData, generation: generation)
    }

    func voiceAudioRecorderDidDetectNoSpeech(
        _ recorder: KMVoiceAudioRecorder,
        generation: Int
    ) {
        beginListening(generation: generation)
    }

    func voiceAudioRecorder(
        _ recorder: KMVoiceAudioRecorder,
        didFail error: Error,
        generation: Int
    ) {
        fail(with: error, generation: generation)
    }
}

extension KMVoiceModeController: KMVoicePlaybackManagerDelegate {
    func voicePlaybackManagerDidFinish(_ manager: KMVoicePlaybackManager) {
        beginListening(generation: sessionGeneration)
    }

    func voicePlaybackManager(_ manager: KMVoicePlaybackManager, didFail error: Error) {
        recover(from: error, generation: sessionGeneration)
    }
}
