//
//  KMAudioRecordButton.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by Shivam Pokhriyal on 17/08/18.
//

import AVFoundation
import Foundation
import KommunicateCore_iOS_SDK
import Speech

public protocol KMChatAudioRecorderProtocol: AnyObject {
    func moveButton(location: CGPoint)
    func finishRecordingAudio(soundData: NSData)
    func startRecordingAudio()
    func cancelRecordingAudio()
    func permissionNotGrant()
}

open class KMAudioRecordButton: UIButton {
    public enum KMChatSoundRecorderState {
        case recording
        case none
    }

    public var states: KMChatSoundRecorderState = .none {
        didSet {
            invalidateIntrinsicContentSize()
            setNeedsLayout()
            layoutIfNeeded()
        }
    }

    weak var delegate: KMChatAudioRecorderProtocol?

    private var recordingSession: AVAudioSession!
    private var audioRecorder: AVAudioRecorder!
    fileprivate var audioFilename: URL!
    private var audioPlayer: AVAudioPlayer?

    private var isSpeechToTextEnabled = false
    private var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let speechAudioEngine = AVAudioEngine()
    private var speechSilenceTimer: Timer?
    private var isSpeechInputTapInstalled = false
    private var activeSpeechSessionID: UUID?
    private var latestSpeechTranscription = ""
    private(set) var isListeningForSpeech = false

    var speechResultHandler: ((String, Bool) -> Void)?
    var speechStateHandler: ((Bool) -> Void)?

    let recordButton = KMExtendedTouchAreaButton(type: .custom)

    func setAudioRecDelegate(recorderDelegate: KMChatAudioRecorderProtocol?) {
        delegate = recorderDelegate
    }

    func configureSpeechToText(enabled: Bool, languageCode: String) {
        isSpeechToTextEnabled = enabled
        updateLanguage(code: languageCode)
        if !enabled {
            stopSpeechRecognition()
        }
    }

    func updateLanguage(code: String) {
        guard !code.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: code))
    }

    func setupRecordButton() {
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(recordButton)

        addConstraints([NSLayoutConstraint(item: recordButton, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0)])
        addConstraints([NSLayoutConstraint(item: recordButton, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0)])
        addConstraints([NSLayoutConstraint(item: recordButton, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0)])
        addConstraints([NSLayoutConstraint(item: recordButton, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0)])

        var image = UIImage(named: "microphone", in: Bundle.km, compatibleWith: nil)
        image = image?.imageFlippedForRightToLeftLayoutDirection()
            .withRenderingMode(.alwaysTemplate)
        recordButton.setImage(image, for: .normal)

        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(userDidLongPressRecord(_:)))
        longPress.cancelsTouchesInView = false
        longPress.allowableMovement = 10
        longPress.minimumPressDuration = 0.2
        recordButton.addGestureRecognizer(longPress)

        let tap = UITapGestureRecognizer(target: self, action: #selector(userDidTapRecord(_:)))
        tap.require(toFail: longPress)
        recordButton.addGestureRecognizer(tap)
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        setupRecordButton()
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open var intrinsicContentSize: CGSize {
        if states == .none {
            return recordButton.intrinsicContentSize
        } else {
            return CGSize(width: recordButton.intrinsicContentSize.width * 3, height: recordButton.intrinsicContentSize.height)
        }
    }

    private func checkMicrophonePermission() -> Bool? {
        let soundSession = AVAudioSession.sharedInstance()

        switch soundSession.recordPermission {
        case .undetermined:
            soundSession.requestRecordPermission { _ in }
            return nil
        case .denied:
            return false
        case .granted:
            return true
        @unknown default:
            print("Unknown Microphone Permission state")
            return false
        }
    }

    @objc fileprivate func startAudioRecord() {
        recordingSession = AVAudioSession.sharedInstance()
        audioFilename = URL(fileURLWithPath: NSTemporaryDirectory().appending("tempRecording.m4a"))
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue
        ]
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.overrideOutputAudioPort(.speaker)
            try recordingSession.setActive(true)
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            states = .recording
        } catch {
            print("Error while initiating audio recording: ", error.localizedDescription)
            stopAudioRecord()
        }
    }

    @objc func cancelAudioRecord() {
        if states == .recording {
            audioRecorder.stop()
            audioRecorder = nil
            states = .none
        }
    }

    @objc fileprivate func stopAudioRecord() {
        if states == .recording {
            audioRecorder.stop()
            audioRecorder = nil
            states = .none
            if audioFilename.isFileURL {
                guard let soundData = NSData(contentsOf: audioFilename) else { return }
                delegate?.finishRecordingAudio(soundData: soundData)
            }
        }
    }

    @objc private func userDidTapRecord(_: UITapGestureRecognizer) {
        guard isSpeechToTextEnabled else { return }
        if isListeningForSpeech {
            stopSpeechRecognition()
            return
        }

        requestSpeechPermissions { [weak self] isAllowed in
            guard let self = self else { return }
            guard isAllowed else {
                self.delegate?.permissionNotGrant()
                return
            }

            do {
                try self.startSpeechRecognition()
            } catch {
                self.stopSpeechRecognition()
                print("Error while starting speech recognition: ", error.localizedDescription)
            }
        }
    }

    @objc func userDidLongPressRecord(_ gesture: UIGestureRecognizer) {
        guard let button = gesture.view as? UIButton else { return }
        let location = gesture.location(in: button)
        let height = button.frame.size.height

        switch gesture.state {
        case .began:
            stopSpeechRecognition()
            guard let isMicrophoneAllowed = checkMicrophonePermission() else { return }
            if isMicrophoneAllowed {
                startAudioRecord()
                delegate?.startRecordingAudio()
            } else {
                delegate?.permissionNotGrant()
            }

        case .changed:
            if location.y < -10 || location.y > height + 10 {
                if states == .recording {
                    delegate?.cancelRecordingAudio()
                    cancelAudioRecord()
                }
            }
            delegate?.moveButton(location: location)

        case .ended:
            if states == .none {
                return
            }
            stopAudioRecord()

        case .failed, .possible, .cancelled:
            if states == .recording {
                stopAudioRecord()
            } else {
                delegate?.cancelRecordingAudio()
                cancelAudioRecord()
            }
        @unknown default:
            print("Unknown Microphone Permission state")
        }
    }

    private func setSpeechListening(_ isListening: Bool) {
        guard isListeningForSpeech != isListening else { return }
        isListeningForSpeech = isListening
        speechStateHandler?(isListening)
    }

    func stopSpeechRecognition() {
        let wasRecognizingSpeech = activeSpeechSessionID != nil ||
            speechAudioEngine.isRunning ||
            recognitionTask != nil ||
            recognitionRequest != nil

        activeSpeechSessionID = nil
        speechSilenceTimer?.invalidate()
        speechSilenceTimer = nil
        speechAudioEngine.stop()
        removeSpeechInputTapIfNeeded()
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil
        setSpeechListening(false)

        if wasRecognizingSpeech {
            let audioSession = AVAudioSession.sharedInstance()
            try? audioSession.setActive(false, options: .notifyOthersOnDeactivation)
        }
    }

    private func requestSpeechPermissions(completion: @escaping (Bool) -> Void) {
        guard Bundle.main.object(forInfoDictionaryKey: "NSSpeechRecognitionUsageDescription") != nil,
              Bundle.main.object(forInfoDictionaryKey: "NSMicrophoneUsageDescription") != nil else {
            print("Speech-to-text requires NSSpeechRecognitionUsageDescription and NSMicrophoneUsageDescription in the host app Info.plist")
            completion(false)
            return
        }

        func requestMicrophonePermission() {
            let audioSession = AVAudioSession.sharedInstance()
            switch audioSession.recordPermission {
            case .granted:
                completion(true)
            case .denied:
                completion(false)
            case .undetermined:
                audioSession.requestRecordPermission { isGranted in
                    DispatchQueue.main.async {
                        completion(isGranted)
                    }
                }
            @unknown default:
                completion(false)
            }
        }

        switch SFSpeechRecognizer.authorizationStatus() {
        case .authorized:
            requestMicrophonePermission()
        case .notDetermined:
            SFSpeechRecognizer.requestAuthorization { status in
                DispatchQueue.main.async {
                    guard status == .authorized else {
                        completion(false)
                        return
                    }
                    requestMicrophonePermission()
                }
            }
        case .denied, .restricted:
            completion(false)
        @unknown default:
            completion(false)
        }
    }

    private func startSpeechRecognition() throws {
        stopSpeechRecognition()

        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            throw SpeechRecognitionError.recognizerUnavailable
        }

        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        if speechRecognizer.supportsOnDeviceRecognition {
            request.requiresOnDeviceRecognition = true
        }
        recognitionRequest = request

        let inputNode = speechAudioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }
        isSpeechInputTapInstalled = true

        let sessionID = UUID()
        activeSpeechSessionID = sessionID
        latestSpeechTranscription = ""
        recognitionTask = speechRecognizer.recognitionTask(with: request) { [weak self] result, error in
            DispatchQueue.main.async {
                guard let self = self,
                      self.activeSpeechSessionID == sessionID else { return }

                if let result = result {
                    let transcription = result.bestTranscription.formattedString
                    let hasTranscription = !transcription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    if hasTranscription {
                        if result.isFinal || transcription.count >= self.latestSpeechTranscription.count {
                            self.latestSpeechTranscription = transcription
                            self.speechResultHandler?(transcription, result.isFinal)
                        }
                        self.resetSpeechSilenceTimer(for: sessionID)
                    }

                    if result.isFinal {
                        self.completeSpeechRecognition(for: sessionID)
                    }
                } else if error != nil {
                    self.completeSpeechRecognition(for: sessionID)
                }
            }
        }

        speechAudioEngine.prepare()
        try speechAudioEngine.start()
        setSpeechListening(true)
    }

    private func resetSpeechSilenceTimer(for sessionID: UUID) {
        guard activeSpeechSessionID == sessionID else { return }
        speechSilenceTimer?.invalidate()
        speechSilenceTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { [weak self] _ in
            self?.finishSpeechInput(for: sessionID)
        }
    }

    private func finishSpeechInput(for sessionID: UUID) {
        guard activeSpeechSessionID == sessionID else { return }
        speechSilenceTimer?.invalidate()
        speechSilenceTimer = nil
        speechAudioEngine.stop()
        removeSpeechInputTapIfNeeded()
        recognitionRequest?.endAudio()
        setSpeechListening(false)
    }

    private func completeSpeechRecognition(for sessionID: UUID) {
        guard activeSpeechSessionID == sessionID else { return }
        activeSpeechSessionID = nil
        speechSilenceTimer?.invalidate()
        speechSilenceTimer = nil
        speechAudioEngine.stop()
        removeSpeechInputTapIfNeeded()
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil
        setSpeechListening(false)

        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setActive(false, options: .notifyOthersOnDeactivation)
    }

    private func removeSpeechInputTapIfNeeded() {
        guard isSpeechInputTapInstalled else { return }
        speechAudioEngine.inputNode.removeTap(onBus: 0)
        isSpeechInputTapInstalled = false
    }

    func setButtonTintColor(color: UIColor) {
        recordButton.imageView?.tintColor = color
    }
}

private enum SpeechRecognitionError: Error {
    case recognizerUnavailable
}

extension KMAudioRecordButton: AVAudioRecorderDelegate {
    public func audioRecorderDidFinishRecording(_: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            stopAudioRecord()
        }
    }
}
