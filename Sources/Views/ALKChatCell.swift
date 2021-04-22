//
//  ChatCell.swift
//
//
//  Created by Mukesh Thawani on 04/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import ApplozicCore
import Foundation
import Kingfisher
import SwipeCellKit
import UIKit

public protocol ALKChatViewModelProtocol {
    var avatar: URL? { get }
    var avatarImage: UIImage? { get }
    var avatarGroupImageUrl: String? { get }
    var name: String { get }
    var groupName: String { get }
    var theLastMessage: String? { get }
    var hasUnreadMessages: Bool { get }
    var totalNumberOfUnreadMessages: UInt { get }
    var isGroupChat: Bool { get }
    var contactId: String? { get }
    var channelKey: NSNumber? { get }
    var conversationId: NSNumber! { get set }
    var createdAt: String? { get }
    var messageType: ALKMessageType { get }
    var channelType: Int16 { get }
    var isMessageEmpty: Bool { get }
    var messageMetadata: NSMutableDictionary? { get }
}

extension ALKChatViewModelProtocol {
    var containsMentions: Bool {
        // Only check when it's a group
        guard channelKey != nil, let mentionParser = mentionParser else {
            return false
        }
        return mentionParser.containsMentions
    }

    var mentionedUserIds: Set<String>? {
        return mentionParser?.mentionedUserIds()
    }

    private var mentionParser: MessageMentionDecoder? {
        guard let message = theLastMessage,
              let metadata = messageMetadata as? [String: Any],
              !metadata.isEmpty
        else {
            return nil
        }
        let mentionParser = MessageMentionDecoder(message: message, metadata: metadata)
        return mentionParser
    }

    func attributedTextWithMentions(
        defaultAttributes: [NSAttributedString.Key: Any],
        mentionAttributes: [NSAttributedString.Key: Any],
        displayNames: ((Set<String>) -> ([String: String]?))?
    ) -> NSAttributedString? {
        guard containsMentions,
              let userIds = mentionedUserIds,
              let names = displayNames?(userIds),
              let attributedText = mentionParser?.messageWithMentions(
                  displayNamesOfUsers: names,
                  attributesForMention: mentionAttributes,
                  defaultAttributes: defaultAttributes
              )
        else {
            return nil
        }
        return attributedText
    }

    func displayNames() -> [String: String]? {
        let alConactService = ALContactService()
        var names: [String: String] = [:]

        mentionedUserIds?.forEach {
            let contact = alConactService.loadContact(byKey: "userId", value: $0)
            names[$0] = contact?.getDisplayName()
        }
        return names
    }
}

public enum ALKChatCellAction {
    case delete
    case favorite
    case store
    case mute
    case unmute
    case block
    case unblock
}

public final class ALKChatCell: SwipeTableViewCell, Localizable {
    enum ConstraintIdentifier: String {
        case iconWidthIdentifier = "iconViewWidth"
    }

    enum Padding {
        enum Email {
            static let top: CGFloat = 4
            static let left: CGFloat = 12
            static let height: CGFloat = 15
            static let width: CGFloat = 24
        }
    }

    public enum Config {
        public static var iconMuted = UIImage(named: "muted", in: Bundle.applozic, compatibleWith: nil)
    }

    public var localizationFileName: String = "Localizable"
    var displayNames: ((Set<String>) -> ([String: String]?))?

    private var avatarImageView: UIImageView = {
        let imv = UIImageView()
        imv.contentMode = .scaleAspectFill
        imv.clipsToBounds = true
        let layer = imv.layer
        layer.cornerRadius = 22.5
        layer.backgroundColor = UIColor.clear.cgColor
        layer.masksToBounds = true
        return imv
    }()

    private var nameLabel: UILabel = {
        let label = UILabel()
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.font = Font.bold(size: 14.0).font()
        label.textColor = .text(.black00)
        return label
    }()

    private var messageLabel: UILabel = {
        let label = UILabel()
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.font = Font.normal(size: 14.0).font()
        label.textColor = UIColor(netHex: 0x9B9B9B)
        return label
    }()

    private var lineView: UIView = {
        let view = UIView()
        let layer = view.layer
        view.backgroundColor = UIColor(red: 200.0 / 255.0, green: 199.0 / 255.0, blue: 204.0 / 255.0, alpha: 0.33)
        return view
    }()

    private var muteIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.isHidden = true
        imageView.image = Config.iconMuted
        return imageView
    }()

    private var emailIcon: UIImageView = {
        let imv = UIImageView()
        imv.contentMode = .scaleAspectFill
        imv.clipsToBounds = true
        imv.isHidden = true
        imv.image = UIImage(named: "alk_email_icon", in: Bundle.applozic, compatibleWith: nil)
        return imv
    }()

    // MARK: BadgeNumber

    private lazy var badgeNumberView: UIView = {
        let view = UIView(frame: .zero)
        view.setBackgroundColor(.background(.main))
        return view
    }()

    private lazy var badgeNumberLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "0"
        label.textAlignment = .center
        label.setTextColor(.white)
        label.setFont(UIFont.font(.normal(size: 9.0)))

        return label
    }()

    private var timeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.numberOfLines = 1
        label.font = Font.normal(size: 14.0).font()
        label.textColor = UIColor(netHex: 0x9B9B9B)
        label.textAlignment = UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft ? .left : .right
        return label
    }()

    private var onlineStatusView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor.onlineGreen()
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupConstraints()
    }

    override public func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        guard viewModel != nil else {
            return
        }

        lineView.backgroundColor = UIColor(netHex: 0xF1F1F1)
        backgroundColor = highlighted ? UIColor(netHex: 0xECECEC) : UIColor.white
        contentView.backgroundColor = backgroundColor

        // set backgroundColor of badgeNumber
        badgeNumberView.setBackgroundColor(.background(.main))
    }

    override public func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        guard viewModel != nil else {
            return
        }

        lineView.backgroundColor = UIColor(netHex: 0xF1F1F1)
        backgroundColor = selected ? UIColor(netHex: 0xECECEC) : UIColor.white
        contentView.backgroundColor = backgroundColor

        // set backgroundColor of badgeNumber
        badgeNumberView.setBackgroundColor(.background(.main))
    }

    private func isConversationMuted(viewModel: ALKChatViewModelProtocol) -> Bool {
        if let channelKey = viewModel.channelKey,
           let channel = ALChannelService().getChannelByKey(channelKey)
        {
            if channel.isNotificationMuted() {
                return true
            } else {
                return false
            }
        } else if let contactId = viewModel.contactId,
                  let contact = ALContactService().loadContact(byKey: "userId", value: contactId)
        {
            if contact.isNotificationMuted() {
                return true
            } else {
                return false
            }
        } else {
            // Conversation is not for user or channel
            return true
        }
    }

    var viewModel: ALKChatViewModelProtocol?

    public func update(viewModel: ALKChatViewModelProtocol, identity _: ALKIdentityProtocol?, placeholder: UIImage? = nil) {
        self.viewModel = viewModel
        let placeHolder = placeholderImage(placeholder, viewModel: viewModel)

        if let avatarImage = viewModel.avatarImage {
            if let imgStr = viewModel.avatarGroupImageUrl, let imgURL = URL(string: imgStr) {
                let resource = ImageResource(downloadURL: imgURL, cacheKey: imgStr)
                avatarImageView.kf.setImage(with: resource, placeholder: avatarImage)
            } else {
                avatarImageView.image = placeHolder
            }
        } else if let avatar = viewModel.avatar {
            let resource = ImageResource(downloadURL: avatar, cacheKey: avatar.absoluteString)
            avatarImageView.kf.setImage(with: resource, placeholder: placeHolder)
        } else {
            avatarImageView.image = placeHolder
        }

        let name = viewModel.isGroupChat ? viewModel.groupName : viewModel.name
        nameLabel.text = name

        let attrs: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: messageLabel.font ?? Font.normal(size: 14.0).font(),
            NSAttributedString.Key.foregroundColor: messageLabel.textColor ?? UIColor(netHex: 0x9B9B9B),
        ]

        if let attributedText = viewModel
            .attributedTextWithMentions(
                defaultAttributes: [:],
                mentionAttributes: attrs as [NSAttributedString.Key: Any],
                displayNames: displayNames
            )
        {
            messageLabel.attributedText = attributedText
        } else {
            messageLabel.text = viewModel.theLastMessage
        }

        muteIcon.isHidden = !isConversationMuted(viewModel: viewModel)

        if viewModel.messageType == .email {
            emailIcon.isHidden = false
            emailIcon.constraint(withIdentifier: ConstraintIdentifier.iconWidthIdentifier.rawValue)?.constant = Padding.Email.width
        } else {
            emailIcon.isHidden = true
            emailIcon.constraint(withIdentifier: ConstraintIdentifier.iconWidthIdentifier.rawValue)?.constant = 0
        }

        // get unread count of message and set badgenumber
        let unreadMsgCount = viewModel.totalNumberOfUnreadMessages
        let numberText: String = (unreadMsgCount < 1000 ? "\(unreadMsgCount)" : "999+")
        let isHidden = (unreadMsgCount < 1)

        badgeNumberView.isHidden = isHidden
        badgeNumberLabel.text = numberText

        timeLabel.text = viewModel.createdAt
        onlineStatusView.isHidden = true

        if !viewModel.isGroupChat {
            let contactService = ALContactService()
            guard let contactId = viewModel.contactId,
                  let contact = contactService.loadContact(byKey: "userId", value: contactId)
            else {
                return
            }

            if contact.block || contact.blockBy || contactService.isUserDeleted(contactId) {
                onlineStatusView.isHidden = true
                return
            }

            onlineStatusView.isHidden = !contact.connected
        }
    }

    private func placeholderImage(_ placeholderImage: UIImage? = nil, viewModel: ALKChatViewModelProtocol) -> UIImage? {
        guard let image = placeholderImage else {
            var placeholder = "contactPlaceholder"

            if viewModel.isGroupChat, viewModel.channelType != Int16(SUPPORT_GROUP.rawValue) {
                placeholder = "groupPlaceholder"
            }
            return UIImage(named: placeholder, in: Bundle.applozic, compatibleWith: nil)
        }
        return image
    }

    private func setupConstraints() {
        contentView.addViewsForAutolayout(views: [avatarImageView, nameLabel, messageLabel, lineView, muteIcon, badgeNumberView, timeLabel, onlineStatusView, emailIcon])
        // setup constraint of imageProfile
        avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 17.0).isActive = true
        avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15.0).isActive = true
        avatarImageView.heightAnchor.constraint(equalToConstant: 45.0).isActive = true
        avatarImageView.widthAnchor.constraint(equalToConstant: 45.0).isActive = true

        // setup constraint of name
        nameLabel.topAnchor.constraint(equalTo: avatarImageView.topAnchor, constant: 2).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 12).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: timeLabel.leadingAnchor, constant: -5).isActive = true

        emailIcon.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: Padding.Email.top).isActive = true
        emailIcon.heightAnchor.constraint(equalToConstant: Padding.Email.height).isActive = true
        emailIcon.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: Padding.Email.left).isActive = true
        emailIcon.widthAnchor.constraintEqualToAnchor(constant: 0, identifier: ConstraintIdentifier.iconWidthIdentifier.rawValue).isActive = true

        // setup constraint of mood'
        messageLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2).isActive = true
        messageLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        messageLabel.leadingAnchor.constraint(equalTo: emailIcon.trailingAnchor, constant: 0).isActive = true
        messageLabel.trailingAnchor.constraint(equalTo: muteIcon.leadingAnchor, constant: -8).isActive = true

        // setup constraint of line
        lineView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        lineView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        lineView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        lineView.heightAnchor.constraint(equalToConstant: 1).isActive = true

        muteIcon.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -19).isActive = true
        muteIcon.centerYAnchor.constraint(equalTo: messageLabel.centerYAnchor).isActive = true
        muteIcon.widthAnchor.constraint(equalToConstant: 15.0).isActive = true
        muteIcon.heightAnchor.constraint(equalToConstant: 15.0).isActive = true

        // setup constraint of badgeNumber
        badgeNumberView.addViewsForAutolayout(views: [badgeNumberLabel])
        badgeNumberView.topAnchor.constraint(equalTo: avatarImageView.topAnchor, constant: 0).isActive = true
        badgeNumberView.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: -12).isActive = true

        badgeNumberLabel.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 1000), for: .horizontal)
        badgeNumberLabel.topAnchor.constraint(equalTo: badgeNumberView.topAnchor, constant: 2.0).isActive = true
        badgeNumberLabel.bottomAnchor.constraint(equalTo: badgeNumberView.bottomAnchor, constant: -2.0).isActive = true
        badgeNumberLabel.leadingAnchor.constraint(equalTo: badgeNumberView.leadingAnchor, constant: 2.0).isActive = true
        badgeNumberLabel.trailingAnchor.constraint(equalTo: badgeNumberView.trailingAnchor, constant: -2.0).isActive = true
        badgeNumberLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 11.0).isActive = true
        badgeNumberLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 11.0).isActive = true

        timeLabel.heightAnchor.constraint(equalToConstant: 15).isActive = true
        timeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -19).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 70).isActive = true
        timeLabel.topAnchor.constraint(equalTo: nameLabel.topAnchor, constant: 0).isActive = true

        onlineStatusView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0).isActive = true
        onlineStatusView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        onlineStatusView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0).isActive = true
        onlineStatusView.widthAnchor.constraint(equalToConstant: 6).isActive = true

        // update frame
        contentView.layoutIfNeeded()

        badgeNumberView.layer.cornerRadius = badgeNumberView.frame.size.height / 2.0
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private weak var comingSoonDelegate: UIView?

    func setComingSoonDelegate(delegate: UIView) {
        comingSoonDelegate = delegate
    }

    override public func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
    }

    private func getRandomColor() -> UIColor {
        let colors = [0x19A5E4, 0x0EB04B, 0xF3B618, 0xE4E9EC]
        let randomNum = randomInt(min: 0, max: 3)
        return UIColor(netHex: colors[randomNum])
    }

    func randomInt(min: Int, max: Int) -> Int {
        return min + Int(arc4random_uniform(UInt32(max - min + 1)))
    }
}
