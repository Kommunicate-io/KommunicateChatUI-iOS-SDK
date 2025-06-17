//
//  KMChatMyPhotoPortalCell.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by Mukesh Thawani on 04/05/17.
//

import Foundation
import UIKit

// MARK: - KMChatMyPhotoPortalCell

final class KMChatMyPhotoPortalCell: KMChatPhotoCell {
    enum State {
        case upload
        case uploading
        case uploaded
    }

    let appSettingsUserDefaults = KMChatAppSettingsUserDefaults()
    fileprivate var stateView: UIImageView = {
        let sv = UIImageView()
        sv.isUserInteractionEnabled = false
        sv.contentMode = .center
        return sv
    }()

    enum Padding {
        enum PhotoView {
            static let right: CGFloat = 14
            static let top: CGFloat = 6
        }
    }

    override class var messageTextFont: UIFont {
        return KMChatMessageStyle.sentMessage.font
    }

    override func setupViews() {
        super.setupViews()
        accessibilityIdentifier = "myPhotoCell"
        contentView.addViewsForAutolayout(views: [stateView])

        photoView.topAnchor
            .constraint(equalTo: contentView.topAnchor, constant: Padding.PhotoView.top)
            .isActive = true

        photoView.trailingAnchor
            .constraint(equalTo: contentView.trailingAnchor, constant: -Padding.PhotoView.right)
            .isActive = true

        photoView.widthAnchor
            .constraint(equalToConstant: KMChatPhotoCell.maxWidth * KMChatPhotoCell.widthPercentage)
            .isActive = true
        photoView.heightAnchor
            .constraint(equalToConstant: KMChatPhotoCell.maxWidth * KMChatPhotoCell.heightPercentage)
            .isActive = true

        bubbleView.backgroundColor = UIColor.hex8(Color.Background.grayF2.rawValue).withAlphaComponent(0.26)

        fileSizeLabel.rightAnchor.constraint(equalTo: bubbleView.rightAnchor, constant: 0).isActive = true
        stateView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -1.0).isActive = true
        stateView.trailingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: -2.0).isActive = true

        timeLabel.trailingAnchor.constraint(equalTo: stateView.leadingAnchor, constant: -2.0).isActive = true
        timeLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: 2).isActive = true
    }

    override func update(viewModel: KMChatMessageViewModel) {
        super.update(viewModel: viewModel)
        setStatusStyle(statusView: stateView, KMChatMessageStyle.messageStatus)
    }

    override class func bottomPadding() -> CGFloat {
        return 6
    }

    override func setupStyle() {
        super.setupStyle()
        captionLabel.font = KMChatMessageStyle.sentMessage.font
        captionLabel.textColor = KMChatMessageStyle.sentMessage.text
        if KMChatMessageStyle.sentBubble.style == .edge {
            bubbleView.layer.cornerRadius = KMChatMessageStyle.sentBubble.cornerRadius
            bubbleView.backgroundColor = appSettingsUserDefaults.getSentMessageBackgroundColor()
            photoView.layer.cornerRadius = KMChatMessageStyle.sentBubble.cornerRadius
        } else {
            photoView.layer.cornerRadius = KMChatMessageStyle.sentBubble.cornerRadius
            bubbleView.layer.cornerRadius = KMChatMessageStyle.sentBubble.cornerRadius
        }
        setStatusStyle(statusView: stateView, KMChatMessageStyle.messageStatus)
    }
}
