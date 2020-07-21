//
//  ALKFriendFormCell.swift
//  ApplozicSwift
//
//  Created by Mukesh on 09/07/20.
//

import UIKit
import Kingfisher

class ALKFriendFormCell: ALKFormCell {
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

    fileprivate var messageView = ALKFriendMessageView()
    fileprivate var submitButtonView = UIView(frame: .zero)

    fileprivate lazy var timeLabelWidth = timeLabel.widthAnchor.constraint(equalToConstant: 0)
    fileprivate lazy var timeLabelHeight = timeLabel.heightAnchor.constraint(equalToConstant: 0)

    lazy var messageViewHeight = self.messageView.heightAnchor.constraint(equalToConstant: 0)
    lazy var submitButtonViewHeight = self.submitButtonView.heightAnchor.constraint(equalToConstant: 0)

    override func setupViews() {
        super.setupViews()
        setupConstraints()
    }

    override func update(viewModel: ALKMessageViewModel) {
        self.identifier = viewModel.identifier
        super.update(viewModel: viewModel)
        let isMessageEmpty = viewModel.isMessageEmpty
        let maxWidth = UIScreen.main.bounds.width
        let messageWidth = maxWidth - (ChatCellPadding.ReceivedMessage.Message.left +
            ChatCellPadding.ReceivedMessage.Message.right)
        messageViewHeight.constant = isMessageEmpty ? 0 : ALKFriendMessageView.rowHeight(viewModel: viewModel, width: messageWidth)
        if !isMessageEmpty {
            messageView.update(viewModel: viewModel)
        }
        messageView.updateHeightOfViews(hideView: isMessageEmpty, viewModel: viewModel, maxWidth: maxWidth)
        showNameAndAvatarImageView(isMessageEmpty: isMessageEmpty, viewModel: viewModel)
        if let submitButton = submitButton, submitButtonView.subviews.isEmpty {
            submitButtonViewHeight.constant = submitButton.buttonHeight()
            submitButtonView.addSubview(submitButton)
        }
        timeLabel.setStyle(ALKMessageStyle.time)
        timeLabel.text = viewModel.time
        let timeLabelSize = viewModel.time!.rectWithConstrainedWidth(
            Padding.TimeLabel.maxWidth,
            font: ALKMessageStyle.time.font
        )
        timeLabelHeight.constant = timeLabelSize.height.rounded(.up)
        timeLabelWidth.constant = timeLabelSize.width.rounded(.up)
        layoutIfNeeded()
    }

    private func setupConstraints() {
        addViewsForAutolayout(views: [
            nameLabel,
            avatarImageView,
            messageView,
            itemListView,
            submitButtonView,
            timeLabel
        ])
        nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: Padding.NameLabel.top).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Padding.NameLabel.leading).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Padding.NameLabel.trailing).isActive = true
        nameLabel.heightAnchor.constraintEqualToAnchor(constant: 0, identifier: ConstraintIdentifier.NameLabel.height).isActive = true

        avatarImageView.topAnchor.constraint(equalTo: topAnchor, constant: Padding.AvatarImageView.top).isActive = true
        avatarImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Padding.AvatarImageView.leading).isActive = true
        avatarImageView.heightAnchor.constraintEqualToAnchor(constant: 0, identifier: ConstraintIdentifier.AvatarImageView.height).isActive = true
        avatarImageView.widthAnchor.constraint(equalToConstant: Padding.AvatarImageView.width).isActive = true

        timeLabel.leadingAnchor.constraint(equalTo: itemListView.leadingAnchor, constant: Padding.TimeLabel.leading).isActive = true
        timeLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Padding.TimeLabel.bottom)
            .isActive = true
        timeLabelWidth.isActive = true
        timeLabelHeight.isActive = true
        timeLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor).isActive = true

        let leftPadding = ChatCellPadding.ReceivedMessage.Message.left
        let rightPadding = ChatCellPadding.ReceivedMessage.Message.right
        let widthPadding = CGFloat(ALKMessageStyle.receivedBubble.widthPadding)
        let templateLeftPadding = leftPadding + 64 - widthPadding
        messageViewHeight.isActive = true
        submitButtonViewHeight.isActive = true
        messageView.layout {
            $0.top == nameLabel.bottomAnchor
            $0.leading == leadingAnchor + leftPadding
            $0.trailing == trailingAnchor - rightPadding
        }
        itemListView.layout {
            $0.top == messageView.bottomAnchor + ChatCellPadding.ReceivedMessage.MessageButton.top
            $0.bottom == submitButtonView.topAnchor - ChatCellPadding.ReceivedMessage.MessageButton.bottom
            $0.leading == messageView.leadingAnchor + templateLeftPadding
            $0.trailing == trailingAnchor - ChatCellPadding.ReceivedMessage.MessageButton.right
        }
        submitButtonView.layout {
            $0.bottom == timeLabel.topAnchor - ChatCellPadding.ReceivedMessage.MessageButton.bottom
            $0.leading == itemListView.leadingAnchor
            $0.trailing == itemListView.trailingAnchor
        }
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
