//
//  ALKAccountSuspensionController.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by Mukesh Thawani on 05/06/18.
//

import UIKit

public class ALKAccountSuspensionController: UIViewController, Localizable {
    public var configuration: ALKConfiguration!
    static let CurrentActivatedPlan = "KM_CURRENT_ACTIVATED_PLAN"

    public required init(configuration: ALKConfiguration) {
        self.configuration = configuration
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// When the close button is tapped this will be called.
    public var closePressed: (() -> Void)?

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupMessageLabel()
    }

    @objc func closeButtonAction(_: UIButton) {
        closePressed?()
    }
    
    @IBOutlet weak var messageLabel: UILabel!
    
    private enum UserPlanType: String {
        case trial, churn, other

        static func from(_ plan: String) -> UserPlanType {
            let lowercasedPlan = plan.lowercased()
            if lowercasedPlan.contains("trial") {
                return .trial
            } else if lowercasedPlan.contains("churn") {
                return .churn
            } else {
                return .other
            }
        }
    }

    func setupMessageLabel() {
        let userDefaults = UserDefaults(suiteName: "group.kommunicate.sdk") ?? .standard
        let currentPlan = userDefaults.string(forKey: ALKAccountSuspensionController.CurrentActivatedPlan) ?? ""
        let planType = UserPlanType.from(currentPlan)

        let (key, defaultValue): (String, String)

        switch planType {
        case .trial:
            key = "TrialUserDisconnectionMessage"
            defaultValue = SystemMessage.SuspendedScreen.TrialUserDisconnectionMessage
        case .churn:
            key = "ChurnedUserDisconnectionMessage"
            defaultValue = SystemMessage.SuspendedScreen.ChurnedUserDisconnectionMessage
        case .other:
            key = "MobileNotSupportedMessage"
            defaultValue = SystemMessage.SuspendedScreen.MobileNotSupportedMessage
        }

        messageLabel.text = localizedString(
            forKey: key,
            withDefaultValue: defaultValue,
            fileName: configuration.localizedStringFileName
        )
    }

    private func setupViews() {
        view.backgroundColor = UIColor(netHex: 0xFAFAFA)
        guard let accountView = Bundle.km.loadNibNamed("ALKAccountSuspensionView", owner: self, options: nil)?.first as? UIView else {
            return
        }
        accountView.frame = CGRect(x: 0, y: 50, width: view.frame.width, height: view.frame.height - 50)
        view.addSubview(accountView)
        let closeButton = closeButtonOf(frame: CGRect.zero)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(closeButton)

        // Constraints
        var topAnchor = view.topAnchor
        if #available(iOS 11, *) {
            topAnchor = view.safeAreaLayoutGuide.topAnchor
        }
        NSLayoutConstraint.activate(
            [closeButton.topAnchor.constraint(equalTo: topAnchor, constant: 20),
             closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
             closeButton.heightAnchor.constraint(equalToConstant: 30),
             closeButton.widthAnchor.constraint(equalToConstant: 30)]
        )
    }

    private func closeButtonOf(frame: CGRect) -> UIButton {
        let button = UIButton(type: .system)
        button.frame = frame
        button.addTarget(self, action: #selector(closeButtonAction(_:)), for: .touchUpInside)
        let closeImage = UIImage(named: "close", in: Bundle.km, compatibleWith: nil)
        button.setImage(closeImage, for: .normal)
        button.tintColor = UIColor.black
        button.isHidden = true
        return button
    }
}
