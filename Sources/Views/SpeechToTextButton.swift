//
//  SpeechToTextButton.swift
//  ApplozicSwift
//
//  Created by Mukesh on 01/09/20.
//

#if SPEECH_REC
    import Foundation
    import Speech

    open class SpeechToTextButton: UIButton, Localizable {
        public enum ALKSoundRecorderState {
            case recording
            case none
        }

        public var states: ALKSoundRecorderState = .none {
            didSet {
                invalidateIntrinsicContentSize()
                setNeedsLayout()
                layoutIfNeeded()
            }
        }

        override open var intrinsicContentSize: CGSize {
            if state == .none {
                return recordButton.intrinsicContentSize
            } else {
                return CGSize(width: recordButton.intrinsicContentSize.width * 3, height: recordButton.intrinsicContentSize.height)
            }
        }

        weak var delegate: ALKAudioRecorderProtocol?
        let textView: UITextView
        let localizedStringFileName: String

        private let recordButton: UIButton = {
            let button = UIButton(type: .custom)
            var image = UIImage(named: "microphone", in: Bundle.applozic, compatibleWith: nil)
            image = image?.imageFlippedForRightToLeftLayoutDirection()
                .withRenderingMode(.alwaysTemplate)
            button.setImage(image, for: .normal)
            return button
        }()

        private lazy var speechRecognizer = SFSpeechRecognizer()
        private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
        private var recognitionTask: SFSpeechRecognitionTask?
        private let audioEngine = AVAudioEngine()
        private lazy var speechToTextPlaceholder: NSAttributedString = {
            let placeholderText = self.localizedString(
                forKey: "SpeechToTextPlaceholder",
                withDefaultValue: SystemMessage.Microphone.SpeechToTextPlaceholder,
                fileName: self.localizedStringFileName
            )
            let attributes: [NSAttributedString.Key: Any] = [
                NSAttributedString.Key.font: ALKChatBarConfiguration.TextView.placeholder.font,
                NSAttributedString.Key.foregroundColor: ALKChatBarConfiguration.TextView.placeholder.text,
            ]
            let styledText = NSAttributedString(string: placeholderText, attributes: attributes)
            return styledText
        }()

        public init(textView: UITextView, localizedStringFileName: String) {
            self.textView = textView
            self.localizedStringFileName = localizedStringFileName
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            setupRecordButton()
        }

        @available(*, unavailable)
        public required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        func setAudioRecDelegate(recorderDelegate: ALKAudioRecorderProtocol?) {
            delegate = recorderDelegate
        }

        func setupRecordButton() {
            addViewsForAutolayout(views: [recordButton])
            recordButton.layout {
                $0.top == topAnchor
                $0.bottom == bottomAnchor
                $0.leading == leadingAnchor
                $0.trailing == trailingAnchor
            }
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(userDidTapRecord(_:)))
            longPress.cancelsTouchesInView = false
            longPress.allowableMovement = 10
            longPress.minimumPressDuration = 0.2
            recordButton.addGestureRecognizer(longPress)
        }

        private func checkSpeechRecognizerPermission(completion: @escaping (Bool) -> Void) {
            speechRecognizer?.delegate = self
            SFSpeechRecognizer.requestAuthorization { authStatus in
                OperationQueue.main.addOperation {
                    switch authStatus {
                    case .authorized:
                        completion(true)
                    case .denied, .restricted, .notDetermined:
                        completion(false)
                    default:
                        completion(false)
                    }
                }
            }
        }

        private func startRecording() throws {
            guard states != .recording else { return }
            // Cancel the previous task if it's running.
            recognitionTask?.cancel()
            recognitionTask = nil

            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            let inputNode = audioEngine.inputNode
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            guard let speechRecognizer = speechRecognizer, let recognitionRequest = recognitionRequest else {
                print("Speech recognizer not available")
                return
            }
            recognitionRequest.shouldReportPartialResults = true
            if #available(iOS 13, *) {
                recognitionRequest.requiresOnDeviceRecognition = speechRecognizer.supportsOnDeviceRecognition
            }
            recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
                var isFinal = false
                if let result = result {
                    self.textView.text = result.bestTranscription.formattedString
                    isFinal = result.isFinal
                }
                if error != nil || isFinal {
                    self.audioEngine.stop()
                    inputNode.removeTap(onBus: 0)
                    self.recognitionRequest = nil
                    self.recognitionTask = nil
                }
            }
            // Configure the microphone input.
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, _) in
                self.recognitionRequest?.append(buffer)
            }
            audioEngine.prepare()
            try audioEngine.start()
            states = .recording
            textView.attributedText = speechToTextPlaceholder
        }

        fileprivate func stopRecording() {
            guard states == .recording else { return }
            audioEngine.stop()
            recognitionRequest?.endAudio()
            states = .none
            guard textView.attributedText == speechToTextPlaceholder else {
                delegate?.cancelRecordingAudio()
                return
            }
            textView.text = ""
        }

        @objc func userDidTapRecord(_ gesture: UIGestureRecognizer) {
            let button = gesture.view as! UIButton
            let location = gesture.location(in: button)
            let height = button.frame.size.height

            switch gesture.state {
            case .began:
                checkSpeechRecognizerPermission { allowed in
                    guard allowed else {
                        self.delegate?.permissionNotGrant()
                        return
                    }
                    do {
                        try self.startRecording()
                    } catch {
                        print("Error while recording: ", error.localizedDescription)
                    }
                }
            case .changed:
                if location.y < -10 || location.y > height + 10 {
                    if states == .recording {
                        stopRecording()
                    }
                }
            case .ended, .failed, .possible, .cancelled:
                stopRecording()
            @unknown default:
                print("Unknown Microphone Permission state")
            }
        }

        func setButtonTintColor(color: UIColor) {
            recordButton.imageView?.tintColor = color
        }
    }

    extension SpeechToTextButton: SFSpeechRecognizerDelegate {
        public func speechRecognizer(_: SFSpeechRecognizer, availabilityDidChange available: Bool) {
            guard !available else { return }
            stopRecording()
        }
    }
#endif
