//
//  ALKMessageButtonCell.swift
//  ApplozicSwift
//
//  Created by Shivam Pokhriyal on 10/01/19.
//

import Kingfisher
open class ALKMyMessageButtonCell: ALKChatBaseCell<ALKMessageViewModel> {
    enum Padding {
        enum StateView {
            static let bottom: CGFloat = 3
            static let right: CGFloat = 2
            static let height: CGFloat = 9
            static let width: CGFloat = 17
        }

        enum TimeLabel {
            static let right: CGFloat = 2
            static let left: CGFloat = 2
            static let bottom: CGFloat = 2
            static let maxWidth: CGFloat = 200
        }
    }

    fileprivate var timeLabel: UILabel = {
        let lb = UILabel()
        lb.isOpaque = true
        return lb
    }()

    fileprivate var stateView: UIImageView = {
        let sv = UIImageView()
        sv.isUserInteractionEnabled = false
        sv.contentMode = .center
        return sv
    }()

    fileprivate lazy var timeLabelWidth = timeLabel.widthAnchor.constraint(equalToConstant: 0)
    fileprivate lazy var timeLabelHeight = timeLabel.heightAnchor.constraint(equalToConstant: 0)

    var messageView = ALKMyMessageView()
    var buttonView = SuggestedReplyView()
    lazy var messageViewHeight = self.messageView.heightAnchor.constraint(equalToConstant: 0)

    override func setupViews() {
        super.setupViews()
        setupConstraints()
    }

    open func update(viewModel: ALKMessageViewModel, maxWidth: CGFloat) {
        self.viewModel = viewModel
        let isMessageEmpty = viewModel.isMessageEmpty

        let messageWidth = maxWidth -
            (ChatCellPadding.SentMessage.Message.left + ChatCellPadding.SentMessage.Message.right)

        messageViewHeight.constant = isMessageEmpty ? 0 : ALKMyMessageView.rowHeight(viewModel: viewModel, width: messageWidth)

        if !isMessageEmpty {
            messageView.update(viewModel: viewModel)
        }

        messageView.updateHeightOfView(hideView: isMessageEmpty, viewModel: viewModel, maxWidth: maxWidth)

        guard let dict = viewModel.linkOrSubmitButton() else {
            buttonView.isHidden = true
            return
        }
        buttonView.isHidden = false
        let buttonWidth = maxWidth - (ChatCellPadding.SentMessage.MessageButton.left + ChatCellPadding.SentMessage.MessageButton.right)
        buttonView.update(model: dict, maxWidth: buttonWidth)
        // Set time
        timeLabel.text = viewModel.time
        timeLabel.setStyle(ALKMessageStyle.time)

        let timeLabelSize = viewModel.time!.rectWithConstrainedWidth(
            Padding.TimeLabel.maxWidth,
            font: ALKMessageStyle.time.font
        )

        timeLabelHeight.constant = timeLabelSize.height.rounded(.up)
        timeLabelWidth.constant = timeLabelSize.width.rounded(.up)

        setStatusStyle(statusView: stateView, ALKMessageStyle.messageStatus)
    }

    open override class func rowHeigh(viewModel: ALKMessageViewModel, width: CGFloat) -> CGFloat {
        var height: CGFloat = 0
        let timeLabelSize = viewModel.time!.rectWithConstrainedWidth(
            Padding.TimeLabel.maxWidth,
            font: ALKMessageStyle.time.font
        )

        if !viewModel.isMessageEmpty {
            let messageWidth = width -
                (ChatCellPadding.SentMessage.Message.left + ChatCellPadding.SentMessage.Message.right)
            height = ALKMyMessageView.rowHeight(viewModel: viewModel, width: messageWidth)
        }

        guard let dict = viewModel.linkOrSubmitButton() else {
            return height + 10 // Paddding
        }
        let buttonWidth = width - (ChatCellPadding.SentMessage.MessageButton.left + ChatCellPadding.SentMessage.MessageButton.right)
        let buttonHeight = SuggestedReplyView.rowHeight(model: dict, maxWidth: buttonWidth)
        return height
            + buttonHeight
            + ChatCellPadding.SentMessage.MessageButton.top
            + ChatCellPadding.SentMessage.MessageButton.bottom + timeLabelSize.height.rounded(.up) + Padding.TimeLabel.bottom
    }

    private func setupConstraints() {
        contentView.addViewsForAutolayout(views: [messageView, buttonView, timeLabel, stateView])
        NSLayoutConstraint.activate([
            messageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            messageView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: ChatCellPadding.SentMessage.Message.left
            ),
            messageView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -1 * ChatCellPadding.SentMessage.Message.right
            ),
            messageViewHeight,

            buttonView.topAnchor.constraint(
                equalTo: messageView.bottomAnchor,
                constant: ChatCellPadding.SentMessage.MessageButton.top
            ),
            buttonView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -ChatCellPadding.SentMessage.MessageButton.right
            ),
            buttonView.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor),
            buttonView.bottomAnchor.constraint(
                equalTo: timeLabel.topAnchor,
                constant: -ChatCellPadding.SentMessage.MessageButton.bottom
            ),
            stateView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1 * Padding.StateView.bottom),
            stateView.trailingAnchor.constraint(equalTo: buttonView.trailingAnchor, constant: -1 * Padding.StateView.right),
            stateView.heightAnchor.constraint(equalToConstant: Padding.StateView.height),
            stateView.widthAnchor.constraint(equalToConstant: Padding.StateView.width),
            timeLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1 * Padding.TimeLabel.bottom),
            timeLabelWidth,
            timeLabelHeight,
            timeLabel.trailingAnchor.constraint(equalTo: stateView.leadingAnchor, constant: -1 * Padding.TimeLabel.right),
        ])
    }
}

class ALKFriendMessageButtonCell: ALKChatBaseCell<ALKMessageViewModel> {
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
    var buttonView = SuggestedReplyView()
    lazy var messageViewHeight = self.messageView.heightAnchor.constraint(equalToConstant: 0)

    var buttonSelected: ((_ index: Int, _ name: String) -> Void)?

    override func setupViews() {
        super.setupViews()
        buttonView.delegate = self
        setupConstraints()
    }

    open func update(viewModel: ALKMessageViewModel, maxWidth: CGFloat) {
        self.viewModel = viewModel
        let isMessageEmpty = viewModel.isMessageEmpty

        let messageWidth = maxWidth -
            (ChatCellPadding.ReceivedMessage.Message.left + ChatCellPadding.ReceivedMessage.Message.right)

        messageViewHeight.constant = isMessageEmpty ? 0 : ALKFriendMessageView.rowHeight(viewModel: viewModel, width: messageWidth)

        messageView.updateHeightOfViews(hideView: isMessageEmpty, viewModel: viewModel, maxWidth: maxWidth)
        showNameAndAvatarImageView(isMessageEmpty: isMessageEmpty, viewModel: viewModel)

        if !isMessageEmpty {
            messageView.update(viewModel: viewModel)
        }

        guard let dict = viewModel.linkOrSubmitButton() else {
            buttonView.isHidden = true
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

        buttonView.isHidden = false
        let buttonWidth = maxWidth - (ChatCellPadding.ReceivedMessage.MessageButton.left + ChatCellPadding.ReceivedMessage.MessageButton.right)
        buttonView.update(model: dict, maxWidth: buttonWidth)
    }

    open override class func rowHeigh(viewModel: ALKMessageViewModel, width: CGFloat) -> CGFloat {
        let isMessageEmpty = viewModel.isMessageEmpty
        var height: CGFloat = 0

        let timeLabelSize = viewModel.time!.rectWithConstrainedWidth(
            Padding.TimeLabel.maxWidth,
            font: ALKMessageStyle.time.font
        )

        let minimumHeight: CGFloat = 60 // 55 is avatar image... + padding

        if isMessageEmpty {
            height = Padding.NameLabel.height + Padding.NameLabel.top
        } else {
            let messageWidth = width -
                (ChatCellPadding.ReceivedMessage.Message.left + ChatCellPadding.ReceivedMessage.Message.right)
            height = ALKFriendMessageView.rowHeight(viewModel: viewModel, width: messageWidth)
        }

        guard let dict = viewModel.linkOrSubmitButton() else {
            return minimumHeight + 10 // Paddding
        }

        let buttonWidth = width - (ChatCellPadding.ReceivedMessage.MessageButton.left + ChatCellPadding.ReceivedMessage.MessageButton.right)
        let buttonHeight = SuggestedReplyView.rowHeight(model: dict, maxWidth: buttonWidth)
        return height
            + buttonHeight
            + ChatCellPadding.ReceivedMessage.MessageButton.top
            + ChatCellPadding.ReceivedMessage.MessageButton.bottom + timeLabelSize.height.rounded(.up)
            + Padding.TimeLabel.bottom
    }

    private func setupConstraints() {
        contentView.addViewsForAutolayout(views: [nameLabel, avatarImageView, messageView, buttonView, timeLabel])
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
            messageView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
            messageView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: ChatCellPadding.ReceivedMessage.Message.left
            ),
            messageView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -1 * ChatCellPadding.ReceivedMessage.Message.right
            ),
            messageViewHeight,
            buttonView.topAnchor.constraint(
                equalTo: messageView.bottomAnchor,
                constant: ChatCellPadding.ReceivedMessage.MessageButton.top
            ),
            buttonView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: ChatCellPadding.ReceivedMessage.MessageButton.left
            ),
            buttonView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor),
            buttonView.bottomAnchor.constraint(
                equalTo: timeLabel.topAnchor,
                constant: -ChatCellPadding.ReceivedMessage.MessageButton.bottom
            ),
            timeLabel.leadingAnchor.constraint(equalTo: buttonView.leadingAnchor, constant: Padding.TimeLabel.leading),
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

extension ALKFriendMessageButtonCell: Tappable {
    func didTap(index: Int?, title: String) {
        guard let index = index, let buttonSelected = buttonSelected else { return }
        buttonSelected(index, title)
    }
}
