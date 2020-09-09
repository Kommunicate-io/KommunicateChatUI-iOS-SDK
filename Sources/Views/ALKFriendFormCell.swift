//
//  ALKFriendFormCell.swift
//  ApplozicSwift
//
//  Created by Mukesh on 09/07/20.
//

import Kingfisher
import UIKit

class ALKFriendFormCell: ALKFormCell {
    enum ViewPadding {
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

        static var maxWidth = UIScreen.main.bounds.width
        static let messageViewPadding = Padding(left: ChatCellPadding.ReceivedMessage.Message.left,
                                                right: ChatCellPadding.ReceivedMessage.Message.right,
                                                top: ChatCellPadding.ReceivedMessage.Message.top,
                                                bottom: 0)
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

    fileprivate lazy var messageView = MessageView(
        bubbleStyle: MessageTheme.receivedMessage.bubble,
        messageStyle: MessageTheme.receivedMessage.message,
        maxWidth: ViewPadding.maxWidth
    )

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
        identifier = viewModel.identifier
        super.update(viewModel: viewModel)
        let isMessageEmpty = viewModel.isMessageEmpty
        let model = viewModel.messageDetails()

        messageViewHeight.constant = isMessageEmpty ? 0 :
            ReceivedMessageViewSizeCalculator().rowHeight(messageModel: model, maxWidth: ViewPadding.maxWidth, padding: ViewPadding.messageViewPadding)

        if !isMessageEmpty {
            messageView.update(model: model)
        }
        messageView.updateHeighOfView(hideView: isMessageEmpty, model: model)
        let placeHolder = UIImage(named: "placeholder", in: Bundle.applozic, compatibleWith: nil)

        if let url = viewModel.avatarURL {
            let resource = ImageResource(downloadURL: url, cacheKey: url.absoluteString)
            avatarImageView.kf.setImage(with: resource, placeholder: placeHolder)
        } else {
            avatarImageView.image = placeHolder
        }

        nameLabel.text = viewModel.displayName
        nameLabel.setStyle(ALKMessageStyle.displayName)

        if let submitButton = submitButton, submitButtonView.subviews.isEmpty {
            submitButtonViewHeight.constant = submitButton.buttonHeight()
            submitButtonView.addSubview(submitButton)
        }
        timeLabel.setStyle(ALKMessageStyle.time)
        timeLabel.text = viewModel.time
        let timeLabelSize = viewModel.time!.rectWithConstrainedWidth(
            ViewPadding.TimeLabel.maxWidth,
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
            timeLabel,
        ])
        nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: ViewPadding.NameLabel.top).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: ViewPadding.NameLabel.leading).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -ViewPadding.NameLabel.trailing).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: ViewPadding.NameLabel.height).isActive = true

        avatarImageView.topAnchor.constraint(equalTo: topAnchor, constant: ViewPadding.AvatarImageView.top).isActive = true
        avatarImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: ViewPadding.AvatarImageView.leading).isActive = true
        avatarImageView.heightAnchor.constraint(equalToConstant: ViewPadding.AvatarImageView.height).isActive = true
        avatarImageView.widthAnchor.constraint(equalToConstant: ViewPadding.AvatarImageView.width).isActive = true

        timeLabel.leadingAnchor.constraint(equalTo: itemListView.leadingAnchor, constant: ViewPadding.TimeLabel.leading).isActive = true
        timeLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -ViewPadding.TimeLabel.bottom)
            .isActive = true
        timeLabelWidth.isActive = true
        timeLabelHeight.isActive = true
        timeLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor).isActive = true

        let leftPadding = ChatCellPadding.ReceivedMessage.Message.left
        let rightPadding = ChatCellPadding.ReceivedMessage.Message.right
        let templateLeftPadding = CGFloat(ALKMessageStyle.receivedBubble.widthPadding)
        messageViewHeight.isActive = true
        submitButtonViewHeight.isActive = true
        messageView.layout {
            $0.top == nameLabel.bottomAnchor
            $0.leading == avatarImageView.trailingAnchor + leftPadding
            $0.trailing <= trailingAnchor - rightPadding
        }
        itemListView.layout {
            $0.top == messageView.bottomAnchor + ChatCellPadding.ReceivedMessage.MessageButton.top
            $0.bottom == submitButtonView.topAnchor - ChatCellPadding.ReceivedMessage.MessageButton.bottom
            $0.leading == avatarImageView.trailingAnchor + templateLeftPadding
            $0.trailing == trailingAnchor - ChatCellPadding.ReceivedMessage.MessageButton.right
        }
        submitButtonView.layout {
            $0.bottom == timeLabel.topAnchor - ChatCellPadding.ReceivedMessage.MessageButton.bottom
            $0.leading == itemListView.leadingAnchor
            $0.trailing == itemListView.trailingAnchor
        }
    }
}
