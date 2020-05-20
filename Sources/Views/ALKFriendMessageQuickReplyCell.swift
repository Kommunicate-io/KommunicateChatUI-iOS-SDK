//
//  ALKFriendQuickReplyCell.swift
//  ApplozicSwift
//
//  Created by Shivam Pokhriyal on 07/01/19.
//

import Kingfisher
public class ALKFriendMessageQuickReplyCell: ALKChatBaseCell<ALKMessageViewModel> {
    enum ConstraintIdentifier {
        enum NameLabel {
            static let height = "NameLabelHeight"
        }

        enum AvatarImageView {
            static let height = "AvatarImageViewHeight"
        }
    }

    enum Padding {
        enum NameLabel {
            static let top: CGFloat = 6
            static let leading: CGFloat = 57
            static let trailing: CGFloat = 57
            static let height: CGFloat = 16
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
    }

    fileprivate var timeLabel: UILabel = {
        let lb = UILabel()
        lb.isOpaque = true
        return lb
    }()

    fileprivate var avatarImageView: UIImageView = {
        let imv = UIImageView()
        imv.contentMode = .scaleAspectFill
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

    fileprivate lazy var timeLabelWidth = timeLabel.widthAnchor.constraint(equalToConstant: 0)
    fileprivate lazy var timeLabelHeight = timeLabel.heightAnchor.constraint(equalToConstant: 0)

    var messageView = ALKFriendMessageView()
    var quickReplyView = SuggestedReplyView()

    var quickReplySelected: ((_ index: Int, _ title: String) -> Void)?

    lazy var messageViewHeight = self.messageView.heightAnchor.constraint(equalToConstant: 0)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupConstraints()
        quickReplyView.delegate = self
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func update(viewModel: ALKMessageViewModel, maxWidth: CGFloat) {
        let isMessageEmpty = viewModel.isMessageEmpty

        let messageWidth = maxWidth -
            (ChatCellPadding.ReceivedMessage.Message.left + ChatCellPadding.ReceivedMessage.Message.right)

        messageViewHeight.constant = isMessageEmpty ? 0 : ALKFriendMessageView.rowHeight(viewModel: viewModel, width: messageWidth)

        if !isMessageEmpty {
            messageView.update(viewModel: viewModel)
        }

        showNameAndAvatarImageView(isMessageEmpty: isMessageEmpty, viewModel: viewModel)

        messageView.updateHeightOfViews(hideView: isMessageEmpty, viewModel: viewModel, maxWidth: maxWidth)
        guard let suggestedReplies = viewModel.suggestedReply() else {
            quickReplyView.isHidden = true
            return
        }
        timeLabel.text = viewModel.time
        let timeLabelSize = viewModel.time!.rectWithConstrainedWidth(
            Padding.TimeLabel.maxWidth,
            font: ALKMessageStyle.time.font
        )

        timeLabelHeight.constant = timeLabelSize.height.rounded(.up)
        timeLabelWidth.constant = timeLabelSize.width.rounded(.up)
        timeLabel.setStyle(ALKMessageStyle.time)
        let quickReplyViewWidth = maxWidth -
            (ChatCellPadding.ReceivedMessage.QuickReply.left + ChatCellPadding.ReceivedMessage.Message.right)
        quickReplyView.update(model: suggestedReplies, maxWidth: quickReplyViewWidth)
    }

    public class func rowHeight(viewModel: ALKMessageViewModel, maxWidth: CGFloat) -> CGFloat {
        let isMessageEmpty = viewModel.isMessageEmpty
        var height: CGFloat = 0

        let timeLabelSize = viewModel.time!.rectWithConstrainedWidth(
            Padding.TimeLabel.maxWidth,
            font: ALKMessageStyle.time.font
        )

        let minimumHeight: CGFloat = 60 // 55 is avatar image... + padding

        if isMessageEmpty {
            height += Padding.NameLabel.height + Padding.NameLabel.top + ChatCellPadding.ReceivedMessage.Message.top
        } else {
            let messageWidth = maxWidth -
                (ChatCellPadding.ReceivedMessage.Message.left + ChatCellPadding.ReceivedMessage.Message.right)
            height = ALKFriendMessageView.rowHeight(viewModel: viewModel, width: messageWidth) + ChatCellPadding.ReceivedMessage.Message.top
        }

        guard let suggestedReplies = viewModel.suggestedReply() else {
            return minimumHeight
        }

        let quickReplyViewWidth = maxWidth -
            (ChatCellPadding.ReceivedMessage.QuickReply.left + ChatCellPadding.ReceivedMessage.Message.right)
        return height
            + SuggestedReplyView.rowHeight(model: suggestedReplies, maxWidth: quickReplyViewWidth)
            + ChatCellPadding.ReceivedMessage.QuickReply.top
            + ChatCellPadding.ReceivedMessage.QuickReply.bottom + timeLabelSize.height.rounded(.up)
            + Padding.TimeLabel.bottom
    }

    private func setupConstraints() {
        contentView.addViewsForAutolayout(views: [messageView, quickReplyView, timeLabel, nameLabel, avatarImageView])
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: Padding.NameLabel.top),
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Padding.NameLabel.leading),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Padding.NameLabel.trailing),
            nameLabel.heightAnchor.constraintEqualToAnchor(constant: 0, identifier: ConstraintIdentifier.NameLabel.height),
            avatarImageView.topAnchor.constraint(equalTo: topAnchor, constant: Padding.AvatarImageView.top),
            avatarImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Padding.AvatarImageView.leading),
            avatarImageView.heightAnchor.constraintEqualToAnchor(constant: 0, identifier: ConstraintIdentifier.AvatarImageView.height),
            avatarImageView.widthAnchor.constraint(equalToConstant: Padding.AvatarImageView.width),
            messageView.topAnchor.constraint(
                equalTo: nameLabel.bottomAnchor,
                constant: ChatCellPadding.ReceivedMessage.Message.top
            ),
            messageView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: ChatCellPadding.ReceivedMessage.Message.left
            ),
            messageView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -1 * ChatCellPadding.ReceivedMessage.Message.right
            ),
            messageViewHeight,
            quickReplyView.topAnchor.constraint(
                equalTo: messageView.bottomAnchor,
                constant: ChatCellPadding.ReceivedMessage.QuickReply.top
            ),
            quickReplyView.leadingAnchor.constraint(
                equalTo: messageView.leadingAnchor,
                constant: ChatCellPadding.ReceivedMessage.QuickReply.left
            ),
            quickReplyView.trailingAnchor.constraint(
                lessThanOrEqualTo: contentView.trailingAnchor,
                constant: -ChatCellPadding.ReceivedMessage.Message.right
            ),
            quickReplyView.bottomAnchor.constraint(
                equalTo: timeLabel.topAnchor,
                constant: -ChatCellPadding.ReceivedMessage.QuickReply.bottom
            ),
            timeLabel.leadingAnchor.constraint(equalTo: quickReplyView.leadingAnchor, constant: Padding.TimeLabel.leading),
            timeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -1 * Padding.TimeLabel.bottom),
            timeLabelWidth,
            timeLabelHeight,
            timeLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
        ])
    }

    private func showNameAndAvatarImageView(isMessageEmpty: Bool, viewModel: ALKMessageViewModel) {
        nameLabel
            .constraint(withIdentifier: ConstraintIdentifier.NameLabel.height)?
            .constant = isMessageEmpty ? Padding.NameLabel.height : 0
        avatarImageView
            .constraint(withIdentifier: ConstraintIdentifier.AvatarImageView.height)?
            .constant = isMessageEmpty ? Padding.AvatarImageView.height : 0

        if isMessageEmpty {
            let placeHolder = UIImage(named: "placeholder", in: Bundle.applozic, compatibleWith: nil)

            if let url = viewModel.avatarURL {
                let resource = ImageResource(downloadURL: url, cacheKey: url.absoluteString)
                avatarImageView.kf.setImage(with: resource, placeholder: placeHolder)
            } else {
                avatarImageView.image = placeHolder
            }

            nameLabel.text = viewModel.displayName
            nameLabel.setStyle(ALKMessageStyle.displayName)
        }
    }
}

extension ALKFriendMessageQuickReplyCell: Tappable {
    public func didTap(index: Int?, title: String) {
        guard let quickReplySelected = quickReplySelected, let index = index else { return }
        quickReplySelected(index, title)
    }
}
