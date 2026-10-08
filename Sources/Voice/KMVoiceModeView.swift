import UIKit

private enum KMVoiceColors {
    static let microphone = UIColor(red: 37 / 255, green: 195 / 255, blue: 243 / 255, alpha: 1)
    static let microphoneRing = UIColor(red: 190 / 255, green: 239 / 255, blue: 255 / 255, alpha: 1)
    static let accent = UIColor(red: 98 / 255, green: 88 / 255, blue: 232 / 255, alpha: 1)
    static let closeBorder = UIColor(red: 221 / 255, green: 216 / 255, blue: 255 / 255, alpha: 1)
    static let listeningBackground = UIColor(red: 239 / 255, green: 250 / 255, blue: 255 / 255, alpha: 1)
    static let listeningBorder = UIColor(red: 143 / 255, green: 216 / 255, blue: 255 / 255, alpha: 1)
    static let listeningText = UIColor(red: 8 / 255, green: 122 / 255, blue: 120 / 255, alpha: 1)
    static let transcribingBackground = UIColor(red: 255 / 255, green: 243 / 255, blue: 224 / 255, alpha: 1)
    static let transcribingBorder = UIColor(red: 255 / 255, green: 183 / 255, blue: 77 / 255, alpha: 1)
    static let transcribingText = UIColor(red: 230 / 255, green: 81 / 255, blue: 0 / 255, alpha: 1)
    static let poweredByText = UIColor(red: 110 / 255, green: 120 / 255, blue: 130 / 255, alpha: 1)
}

final class KMVoiceModeView: UIView {
    var microphoneTapped: (() -> Void)?
    var closeTapped: (() -> Void)?
    var statusChanged: ((String?, KMVoiceModeController.State) -> Void)?

    private let microphoneButton = UIButton(type: .custom)
    private let closeButton = UIButton(type: .custom)
    private let poweredByLabel = UILabel()

    init() {
        super.init(frame: .zero)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setState(_ state: KMVoiceModeController.State) {
        microphoneButton.layer.removeAnimation(forKey: "voicePulse")
        microphoneButton.alpha = state == .listening ? 1 : 0.72

        switch state {
        case .listening:
            showStatus(localized("VoiceModeListening", defaultValue: "Listening…"), state: state)
            startPulse()
        case .transcribing:
            showStatus(localized("VoiceModeTranscribing", defaultValue: "Transcribing…"), state: state)
        case .error:
            showStatus(localized("VoiceModeError", defaultValue: "Please try again"), state: state)
        default:
            hideStatus(state: state)
        }

        microphoneButton.accessibilityValue = accessibilityValue(for: state)
    }

    private func setupView() {
        backgroundColor = .clear
        accessibilityIdentifier = "voiceModeView"

        configure(
            button: microphoneButton,
            imageName: "mic.fill",
            backgroundColor: KMVoiceColors.microphone,
            size: 80,
            accessibilityLabel: localized("VoiceModeMicrophone", defaultValue: "Voice mode microphone")
        )
        configure(
            button: closeButton,
            imageName: "xmark",
            backgroundColor: .secondarySystemBackground,
            size: 52,
            accessibilityLabel: localized("VoiceModeClose", defaultValue: "Close voice mode")
        )
        microphoneButton.layer.borderColor = KMVoiceColors.microphoneRing.cgColor
        microphoneButton.layer.borderWidth = 7
        closeButton.backgroundColor = .white
        closeButton.tintColor = KMVoiceColors.accent
        closeButton.layer.borderColor = KMVoiceColors.closeBorder.cgColor
        closeButton.layer.borderWidth = 2

        poweredByLabel.text = localized("VoiceModePoweredBy", defaultValue: "AI Agent powered by Kommunicate")
        poweredByLabel.font = .preferredFont(forTextStyle: .caption2)
        poweredByLabel.adjustsFontForContentSizeCategory = true
        poweredByLabel.textColor = KMVoiceColors.poweredByText
        poweredByLabel.textAlignment = .center

        microphoneButton.addTarget(self, action: #selector(didTapMicrophone), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)

        let controls = UIStackView(arrangedSubviews: [microphoneButton, closeButton])
        controls.axis = .horizontal
        controls.alignment = .center
        controls.spacing = 18

        [controls, poweredByLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 140),
            controls.centerXAnchor.constraint(equalTo: centerXAnchor),
            controls.bottomAnchor.constraint(equalTo: poweredByLabel.topAnchor, constant: -8),
            microphoneButton.widthAnchor.constraint(equalToConstant: 80),
            microphoneButton.heightAnchor.constraint(equalToConstant: 80),
            closeButton.widthAnchor.constraint(equalToConstant: 52),
            closeButton.heightAnchor.constraint(equalToConstant: 52),

            poweredByLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            poweredByLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            poweredByLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }

    private func configure(
        button: UIButton,
        imageName: String,
        backgroundColor: UIColor,
        size: CGFloat,
        accessibilityLabel: String
    ) {
        let config = UIImage.SymbolConfiguration(pointSize: size * 0.3, weight: .semibold)
        button.setImage(UIImage(systemName: imageName, withConfiguration: config), for: .normal)
        button.tintColor = .white
        button.backgroundColor = backgroundColor
        button.layer.cornerRadius = size / 2
        button.accessibilityLabel = accessibilityLabel
        button.accessibilityTraits = .button
    }

    private func showStatus(_ text: String, state: KMVoiceModeController.State) {
        statusChanged?(text, state)
    }

    private func hideStatus(state: KMVoiceModeController.State) {
        statusChanged?(nil, state)
    }

    private func startPulse() {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.fromValue = 1
        animation.toValue = 1.08
        animation.duration = 0.8
        animation.autoreverses = true
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        microphoneButton.layer.add(animation, forKey: "voicePulse")
    }

    private func accessibilityValue(for state: KMVoiceModeController.State) -> String {
        switch state {
        case .listening:
            return localized("VoiceModeListening", defaultValue: "Listening")
        case .transcribing:
            return localized("VoiceModeTranscribing", defaultValue: "Transcribing")
        case .speaking:
            return localized("VoiceModeSpeaking", defaultValue: "Speaking")
        default:
            return ""
        }
    }

    private func localized(_ key: String, defaultValue: String) -> String {
        return Bundle.km.localizedString(forKey: key, value: defaultValue, table: nil)
    }

    @objc private func didTapMicrophone() {
        microphoneTapped?()
    }

    @objc private func didTapClose() {
        closeTapped?()
    }
}

final class KMVoiceStatusView: UIView {
    static let height: CGFloat = 64

    private let statusLabel = UILabel()

    init() {
        super.init(frame: .zero)

        statusLabel.font = .preferredFont(forTextStyle: .body)
        statusLabel.adjustsFontForContentSizeCategory = true
        statusLabel.layer.borderWidth = 1
        statusLabel.layer.cornerRadius = 18
        statusLabel.layer.masksToBounds = true
        statusLabel.textAlignment = .center
        statusLabel.accessibilityIdentifier = "voiceModeStatus"
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(statusLabel)

        NSLayoutConstraint.activate([
            statusLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            statusLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            statusLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 40),
            statusLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 120),
            statusLabel.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, multiplier: 0.72)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setText(_ text: String, state: KMVoiceModeController.State) {
        let isTranscribing = state == .transcribing
        statusLabel.textColor = isTranscribing
            ? KMVoiceColors.transcribingText
            : KMVoiceColors.listeningText
        statusLabel.backgroundColor = isTranscribing
            ? KMVoiceColors.transcribingBackground
            : KMVoiceColors.listeningBackground
        statusLabel.layer.borderColor = (
            isTranscribing
                ? KMVoiceColors.transcribingBorder
                : KMVoiceColors.listeningBorder
        ).cgColor
        statusLabel.text = "   \(text)   "
        statusLabel.accessibilityLabel = text
    }
}
