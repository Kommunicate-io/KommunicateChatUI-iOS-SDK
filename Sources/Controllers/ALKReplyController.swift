//
//  ALKReplyController.swift
//  ApplozicSwift
//
//  Created by apple on 01/07/19.
//

import Foundation

import Applozic
import Kingfisher

class ALKReplyController: UIViewController, Localizable {
    public struct Padding {
        struct ModelView {
            static let height: CGFloat = 250.0
            static let left: CGFloat = 30.0
            static let right: CGFloat = 30.0
        }

        struct TitleLabel {
            static let top: CGFloat = 15.0
            static let left: CGFloat = 10.0
            static let right: CGFloat = 10.0
            static let height : CGFloat  = 30.0
        }

        struct MessageLabel {
            static let bottom: CGFloat = 12.0
            static let left: CGFloat = 15.0
            static let right: CGFloat = 15.0
            static let height : CGFloat  = 50.0

        }

        struct MessageTextView {
            static let top: CGFloat = 3.0
            static let left: CGFloat = 10.0
            static let right: CGFloat = 10.0
            static let height : CGFloat  = 80.0
        }

        struct ButtonUIView {
            static let height: CGFloat = 50.0
        }

        struct ConfirmButton {
            static let height: CGFloat = 50.0
            static let left: CGFloat = 3.0
        }

        struct AvatarImage {
            static let top: CGFloat = 35.0
            static let left: CGFloat = 9.0
            static let width: CGFloat = 25.0
            static let height: CGFloat = 25.0
        }
    }

    var action: String!
    var configuration: ALKConfiguration!
    var messageKey: String?

    private let modalView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 5
        return view
    }()

    private let timeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "Sun, 18 June"
        label.textColor = UIColor(red: 88 / 255.0, green: 87 / 255.0, blue: 87 / 255.0, alpha: 1.0)
        label.numberOfLines = 3
        label.font = Font.bold(size: 12.0).font()
        return label
    }()

    private var avatarImageView: UIImageView = {
        let imv = UIImageView()
        imv.contentMode = .scaleAspectFill
        imv.clipsToBounds = true
        let layer = imv.layer
        layer.cornerRadius = 12
        layer.masksToBounds = true
        imv.image = UIImage(named: "contactPlaceholder", in: Bundle.applozic, compatibleWith: nil)
        imv.isUserInteractionEnabled = true
        return imv
    }()

    let messageView: UITextView = {
        let textView = UITextView(frame: .zero)
        textView.isUserInteractionEnabled = true
        textView.isSelectable = true
        textView.isScrollEnabled = true
        textView.isEditable = false
        textView.dataDetectorTypes = .link
        textView.textColor = UIColor.gray
        textView.setFont(Font.normal(size: 14).font())
        textView.linkTextAttributes = [.foregroundColor: UIColor.blue,
                                       .underlineStyle: NSUnderlineStyle.single.rawValue]
        textView.delaysContentTouches = false
        textView.setBackgroundColor(UIColor(red: 249 / 255.0, green: 249 / 255.0, blue: 249 / 255.0, alpha: 1.0))
        return textView
    }()

    private let alertMessageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 4
        label.textColor = UIColor(red: 140 / 255.0, green: 140 / 255.0, blue: 140 / 255.0, alpha: 1.0)
        label.text = "We are unable to directly retrieve this message for you. You can still scroll up your messages and view it."
        label.font = Font.light(size: 14.0).font()
        return label
    }()

    private lazy var confirmButton: UIButton = {
        let button = UIButton()
        let title = localizedString(forKey: "OkayMessage", withDefaultValue: SystemMessage.ButtonName.okay, fileName: configuration.localizedStringFileName)
        button.setTitle(title, for: .normal)
        button.setTitleColor(UIView().tintColor, for: .normal)
        button.setFont(font: Font.normal(size: 16.0).font())
        button.setBackgroundColor(UIColor(red: 242.0 / 255.0, green: 242.0 / 255.0, blue: 242.0 / 255.0, alpha: 1.0))
        return button
    }()

    private let buttonUIView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 93.7, green: 93.7, blue: 93.7, alpha: 1.0)
        return view
    }()

    init(messageKey: String, configuration: ALKConfiguration) {
        super.init(nibName: nil, bundle: nil)
        self.messageKey = messageKey
        self.configuration = configuration
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()

        let messageDatabase = ALMessageDBService()
        let message = messageDatabase.getMessageByKey(messageKey)
        messageView.sizeToFit()
        let placeHolder = UIImage(named: "placeholder", in: Bundle.applozic, compatibleWith: nil)
        let contactService = ALContactService()
        let contact = contactService.loadContact(byKey: "userId", value: message?.to)

        if let imageUrl = contact?.contactImageUrl, let url = URL(string: imageUrl) {
            let resource = ImageResource(downloadURL: url, cacheKey: url.absoluteString)
            avatarImageView.kf.setImage(with: resource, placeholder: placeHolder)
        } else {
            avatarImageView.image = placeHolder
        }

        view.backgroundColor = UIColor(10, green: 10, blue: 10, alpha: 0.2)
        view.isOpaque = false

        guard let value = message?.createdAtTime.doubleValue else {
            return
        }

        let date = Date(timeIntervalSince1970: Double(value / 1000))

        timeLabel.text = date.stringCompareCurrentDate()
    }

    @objc func tappedCancel() {
        dismiss(animated: true, completion: nil)
    }

    @objc func tappedConfirmButton() {
        dismiss(animated: true, completion: nil)
    }

    func setupViews() {
        view.addViewsForAutolayout(views: [modalView])

        modalView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        modalView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        modalView.heightAnchor.constraint(equalToConstant: Padding.ModelView.height).isActive = true
        modalView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Padding.ModelView.left).isActive = true
        modalView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Padding.ModelView.right).isActive = true

        modalView.addViewsForAutolayout(views: [timeLabel, alertMessageLabel, buttonUIView, confirmButton, avatarImageView, buttonUIView, messageView])

        modalView.bringSubviewToFront(confirmButton)
        modalView.bringSubviewToFront(messageView)

        avatarImageView.topAnchor.constraint(equalTo: modalView.topAnchor, constant: Padding.AvatarImage.top).isActive = true

        avatarImageView.leadingAnchor.constraint(
            equalTo: modalView.leadingAnchor,
            constant: Padding.AvatarImage.left
        ).isActive = true

        avatarImageView.heightAnchor.constraint(equalToConstant: Padding.AvatarImage.height).isActive = true

        avatarImageView.widthAnchor.constraint(equalToConstant: Padding.AvatarImage.width).isActive = true

        timeLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: Padding.TitleLabel.left).isActive = true
        timeLabel.heightAnchor.constraint(equalToConstant: Padding.TitleLabel.height).isActive = true
        timeLabel.topAnchor.constraint(equalTo: modalView.topAnchor, constant: Padding.TitleLabel.top).isActive = true

        messageView.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: -Padding.MessageTextView.top).isActive = true

        messageView.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: Padding.MessageTextView.left).isActive = true
        messageView.trailingAnchor.constraint(equalTo: modalView.trailingAnchor, constant: -Padding.MessageTextView.right).isActive = true

        messageView.heightAnchor.constraint(equalToConstant: Padding.MessageTextView.height).isActive = true

        alertMessageLabel.leadingAnchor.constraint(equalTo: modalView.leadingAnchor, constant: Padding.MessageLabel.left).isActive = true
        alertMessageLabel.trailingAnchor.constraint(equalTo: modalView.trailingAnchor, constant: -Padding.MessageLabel.right).isActive = true
        alertMessageLabel.heightAnchor.constraint(equalToConstant: Padding.MessageLabel.height).isActive = true

        alertMessageLabel.bottomAnchor.constraint(equalTo: buttonUIView.topAnchor, constant: -Padding.MessageLabel.bottom).isActive = true

        buttonUIView.heightAnchor.constraint(equalToConstant: Padding.ButtonUIView.height).isActive = true
        buttonUIView.leadingAnchor.constraint(equalTo: modalView.leadingAnchor).isActive = true
        buttonUIView.trailingAnchor.constraint(equalTo: modalView.trailingAnchor).isActive = true
        buttonUIView.bottomAnchor.constraint(equalTo: modalView.bottomAnchor).isActive = true

        confirmButton.heightAnchor.constraint(equalToConstant: Padding.ConfirmButton.height).isActive = true
        confirmButton.leadingAnchor.constraint(equalTo: buttonUIView.leadingAnchor, constant: Padding.ConfirmButton.left).isActive = true
        confirmButton.trailingAnchor.constraint(equalTo: buttonUIView.trailingAnchor).isActive = true
        confirmButton.bottomAnchor.constraint(equalTo: modalView.bottomAnchor).isActive = true

        confirmButton.addTarget(self, action: #selector(tappedConfirmButton), for: .touchUpInside)
    }
}
