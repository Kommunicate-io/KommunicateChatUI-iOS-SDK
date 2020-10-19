//
//  ReceivedButtonsView.swift
//  ApplozicSwift
//
//  Created by Shivam Pokhriyal on 25/09/19.
//

import UIKit

public class ReceivedButtonsCell: UITableViewCell {
    enum ViewPadding {
        enum NameLabel {
            static let top: CGFloat = 6
            static let leading: CGFloat = 57
            static let trailing: CGFloat = 57
            static let height: CGFloat = 17
        }

        enum AvatarImageView {
            static let top: CGFloat = 18
            static let leading: CGFloat = 9
            static let height: CGFloat = 37
            static let width: CGFloat = 37
        }

        enum TimeLabel {
            static var leading: CGFloat = 2.0
            static var bottom: CGFloat = 2.0
            static let maxWidth: CGFloat = 200
        }

        static let maxWidth = UIScreen.main.bounds.width
        static let messageViewPadding = Padding(
            left: ChatCellPadding.ReceivedMessage.Message.left,
            right: ChatCellPadding.ReceivedMessage.Message.right,
            top: ChatCellPadding.ReceivedMessage.Message.top,
            bottom: 0
        )
    }

    public var tapped: ((_ index: Int, _ name: String) -> Void)?

    // MARK: - Fileprivate properties

    fileprivate var avatarImageView: UIImageView = {
        let imv = UIImageView()
        imv.contentMode = .scaleAspectFill
        imv.image = UIImage(named: "contact-placeholder", in: Bundle.richMessageKit, compatibleWith: nil)
        imv.clipsToBounds = true
        let layer = imv.layer
        layer.cornerRadius = 18.5
        layer.masksToBounds = true
        imv.isUserInteractionEnabled = true
        return imv
    }()

    fileprivate var nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.isOpaque = true
        return label
    }()

    fileprivate var timeLabel: UILabel = {
        let lb = UILabel()
        lb.isOpaque = true
        return lb
    }()

    fileprivate lazy var buttons = SuggestedReplyView()
    fileprivate lazy var messageView = MessageView(
        bubbleStyle: MessageTheme.receivedMessage.bubble,
        messageStyle: MessageTheme.receivedMessage.message,
        maxWidth: ViewPadding.maxWidth
    )
    fileprivate lazy var messageViewHeight = messageView.heightAnchor.constraint(equalToConstant: 0)
    fileprivate lazy var timeLabelWidth = timeLabel.widthAnchor.constraint(equalToConstant: 0)
    fileprivate lazy var timeLabelHeight = timeLabel.heightAnchor.constraint(equalToConstant: 0)

    // MARK: - Initializer

    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        buttons.delegate = self
        setupConstraints()
        backgroundColor = .clear
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Updates the `ReceivedButtonsCell`.
    ///
    /// - Parameter model: object that conforms to `SuggestedReplyMessage`
    public func update(model: SuggestedReplyMessage) {
        guard !model.message.isMyMessage else {
            print("For Received view isMyMessage should be false")
            return
        }

        let isMessageEmpty = model.message.isMessageEmpty()
        messageViewHeight.constant =
            isMessageEmpty ? 0 : ReceivedMessageViewSizeCalculator().rowHeight(
                messageModel: model.message,
                maxWidth: ViewPadding.maxWidth,
                padding: ViewPadding.messageViewPadding
            )

        if !isMessageEmpty {
            messageView.update(model: model.message)
        }
        if let url = model.message.imageURL {
            ImageCache.downloadImage(url: url) { [weak self] image in
                guard let image = image else { return }
                DispatchQueue.main.async {
                    self?.avatarImageView.image = image
                }
            }
        }

        nameLabel.text = model.message.displayName
        nameLabel.setStyle(MessageTheme.receivedMessage.displayName)
        messageView.updateHeighOfView(hideView: isMessageEmpty, model: model.message)
        timeLabel.text = model.message.time
        let timeLabelSize = model.message.time.rectWithConstrainedWidth(
            ViewPadding.TimeLabel.maxWidth,
            font: MessageTheme.receivedMessage.time.font
        )

        timeLabelHeight.constant = timeLabelSize.height.rounded(.up)
        timeLabelWidth.constant = timeLabelSize.width.rounded(.up)
        timeLabel.setStyle(MessageTheme.receivedMessage.time)

        let buttonsWidth = ViewPadding.maxWidth -
            (ChatCellPadding.ReceivedMessage.QuickReply.left + ChatCellPadding.ReceivedMessage.Message.right + ViewPadding.AvatarImageView.leading + ViewPadding.AvatarImageView.width + ChatCellPadding.ReceivedMessage.Message.left)
        buttons.update(model: model, maxWidth: buttonsWidth)
    }

    /// It is used to get exact height of `ReceivedButtonsCell` using messageModel, width and padding
    ///
    /// - Parameters:
    ///   - model: object that conforms to `SuggestedReplyMessage`
    /// - Returns: exact height of the view.
    public static func rowHeight(model: SuggestedReplyMessage) -> CGFloat {
        let isMessageEmpty = model.message.isMessageEmpty()
        var height: CGFloat = 0

        let timeLabelSize = model.message.time.rectWithConstrainedWidth(
            ViewPadding.TimeLabel.maxWidth,
            font: MessageTheme.receivedMessage.time.font
        )
        if isMessageEmpty {
            height += ViewPadding.NameLabel.height + ViewPadding.NameLabel.top + ChatCellPadding.ReceivedMessage.Message.top
        } else {
            height = ReceivedMessageViewSizeCalculator().rowHeight(messageModel: model.message, maxWidth: ViewPadding.maxWidth, padding: ViewPadding.messageViewPadding) + ViewPadding.NameLabel.height +
                ViewPadding.NameLabel.top
        }

        let quickReplyViewWidth = ViewPadding.maxWidth -
            (ChatCellPadding.ReceivedMessage.QuickReply.left + ChatCellPadding.ReceivedMessage.Message.right + ViewPadding.AvatarImageView.leading + ViewPadding.AvatarImageView.width + ChatCellPadding.ReceivedMessage.Message.left)
        return height
            + SuggestedReplyView.rowHeight(model: model, maxWidth: quickReplyViewWidth)
            + ChatCellPadding.ReceivedMessage.QuickReply.top
            + ChatCellPadding.ReceivedMessage.QuickReply.bottom + timeLabelSize.height.rounded(.up)
            + ViewPadding.TimeLabel.bottom
    }

    private func setupConstraints() {
        contentView.addViewsForAutolayout(views: [messageView, buttons, timeLabel, nameLabel, avatarImageView])
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: ViewPadding.NameLabel.top),
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: ViewPadding.NameLabel.leading),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -ViewPadding.NameLabel.trailing),
            nameLabel.heightAnchor.constraint(equalToConstant: ViewPadding.NameLabel.height),
            avatarImageView.topAnchor.constraint(equalTo: topAnchor, constant: ViewPadding.AvatarImageView.top),
            avatarImageView.heightAnchor.constraint(equalToConstant: ViewPadding.AvatarImageView.height),
            avatarImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: ViewPadding.AvatarImageView.leading),
            avatarImageView.widthAnchor.constraint(equalToConstant: ViewPadding.AvatarImageView.width),
            messageView.topAnchor.constraint(
                equalTo: nameLabel.bottomAnchor,
                constant: ChatCellPadding.ReceivedMessage.Message.top
            ),
            messageView.leadingAnchor.constraint(
                equalTo: avatarImageView.trailingAnchor,
                constant: ChatCellPadding.ReceivedMessage.Message.left
            ),
            messageView.trailingAnchor.constraint(
                lessThanOrEqualTo: contentView.trailingAnchor,
                constant: -1 * ChatCellPadding.ReceivedMessage.Message.right
            ),
            messageViewHeight,
            buttons.topAnchor.constraint(
                equalTo: messageView.bottomAnchor,
                constant: ChatCellPadding.ReceivedMessage.QuickReply.top
            ),
            buttons.leadingAnchor.constraint(
                equalTo: messageView.leadingAnchor
            ),
            buttons.trailingAnchor.constraint(
                lessThanOrEqualTo: contentView.trailingAnchor,
                constant: -ChatCellPadding.ReceivedMessage.Message.right
            ),
            buttons.bottomAnchor.constraint(
                equalTo: timeLabel.topAnchor,
                constant: -ChatCellPadding.ReceivedMessage.QuickReply.bottom
            ),
            timeLabel.leadingAnchor.constraint(equalTo: buttons.leadingAnchor, constant: ViewPadding.TimeLabel.leading),
            timeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -1 * ViewPadding.TimeLabel.bottom),
            timeLabelWidth,
            timeLabelHeight,
            timeLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
        ])
    }
}

extension ReceivedButtonsCell: Tappable {
    public func didTap(index: Int?, title: String) {
        guard let tapped = tapped, let index = index else { return }
        tapped(index, title)
    }
}
