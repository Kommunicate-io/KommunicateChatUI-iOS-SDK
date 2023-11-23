//
//  KMFriendVideoTemplateCell.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by sathyan elangovan on 28/09/23.
//

import Foundation
import Kingfisher
import UIKit


class KMFriendVideoTemplateCell : KMVideoTemplateCell {
    let appSettingsUserDefaults = ALKAppSettingsUserDefaults()

    fileprivate lazy var messageView = MessageView(
        bubbleStyle: MessageTheme.receivedMessage.bubble,
        messageStyle: MessageTheme.receivedMessage.message,
        maxWidth: ViewPadding.maxWidth - (ViewPadding.messageViewPadding.left + ViewPadding.messageViewPadding.right)
    )

    lazy var messageViewHeight = self.messageView.heightAnchor.constraint(equalToConstant: 0)
    
    private var avatarImageView: UIImageView = {
        let imv = UIImageView()
        imv.contentMode = .scaleAspectFill
        imv.clipsToBounds = true
        let layer = imv.layer
        layer.cornerRadius = 18.5
        layer.backgroundColor = UIColor.lightGray.cgColor
        layer.masksToBounds = true
        imv.isUserInteractionEnabled = true
        return imv
    }()

    private var nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textColor = UIColor.lightGray
        return label
    }()

    override class func topPadding() -> CGFloat {
        return 28
    }
    
    override func setupStyle() {
        super.setupStyle()
        nameLabel.setStyle(ALKMessageStyle.displayName)
    }
    
    
    override func setupViews() {
        super.setupViews()
        let width = UIScreen.main.bounds.width

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(avatarTappedAction))
        avatarImageView.addGestureRecognizer(tapGesture)

        contentView.addViewsForAutolayout(views: [avatarImageView, messageView, nameLabel])
        contentView.bringSubviewToFront(messageView)
        nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 57).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -56).isActive = true
        nameLabel.bottomAnchor.constraint(equalTo: messageView.topAnchor, constant: -6).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: 16).isActive = true

        avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 18).isActive = true
        avatarImageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: 0).isActive = true

        avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 9).isActive = true
        avatarImageView.trailingAnchor.constraint(equalTo: messageView.leadingAnchor, constant: -10).isActive = true

        avatarImageView.heightAnchor.constraint(equalToConstant: 37).isActive = true
        avatarImageView.widthAnchor.constraint(equalTo: avatarImageView.heightAnchor).isActive = true
        
        let leftPadding = ChatCellPadding.ReceivedMessage.Message.left
        let rightPadding = ChatCellPadding.ReceivedMessage.Message.right
        messageView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor).isActive = true
        messageView.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: leftPadding).isActive = true
        messageView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -1 * rightPadding).isActive = true
        messageViewHeight.isActive = true

        let templateLeftPadding = CGFloat(ALKMessageStyle.receivedBubble.widthPadding)

        videoTableview.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: templateLeftPadding).isActive = true
        videoTableview.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -56).isActive = true
        videoTableview.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16).isActive = true

        videoTableview.topAnchor.constraint(equalTo: messageView.bottomAnchor, constant: 6).isActive = true
        videoTableview.widthAnchor.constraint(equalToConstant: width * 0.60).isActive = true

        timeLabel.leadingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: 2).isActive = true
        timeLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: 2).isActive = true

        nameLabel.isHidden = KMCellConfiguration.hideSenderName
    }
    
    override func update(viewModel: ALKMessageViewModel) {
        super.update(viewModel: viewModel)
        nameLabel.text = viewModel.displayName
        let isMessageEmpty = viewModel.isMessageEmpty
        let model = viewModel.messageDetails()
        messageViewHeight.constant = isMessageEmpty ? 0 :
            ReceivedMessageViewSizeCalculator().rowHeight(messageModel: model, maxWidth: ViewPadding.maxWidth, padding: ViewPadding.messageViewPadding)
        if !isMessageEmpty {
            messageView.update(model: model)
        } else if #available(iOS 17, *) {
            messageView.update(model: model)
        }
        messageView.updateHeighOfView(hideView: isMessageEmpty, model: model)
        let placeHolder = UIImage(named: "placeholder", in: Bundle.km, compatibleWith: nil)
        guard let url = viewModel.avatarURL else {
            avatarImageView.image = placeHolder
            return
        }
        let resource = Kingfisher.ImageResource(downloadURL: url, cacheKey: url.absoluteString)
        avatarImageView.kf.setImage(with: resource, placeholder: placeHolder)
    }

    @objc private func avatarTappedAction() {
        avatarTapped?()
    }
}
