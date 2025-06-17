//
//  KMChatMyPhotoLandscapeCell.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by Mukesh Thawani on 04/05/17.
//

import Foundation
import UIKit

// MARK: - KMChatMyPhotoLandscapeCell

final class KMChatMyPhotoLandscapeCell: KMChatPhotoCell {
    let appSettingsUserDefaults = KMChatAppSettingsUserDefaults()

    fileprivate var stateView: UIImageView = {
        let sv = UIImageView()
        sv.isUserInteractionEnabled = false
        sv.contentMode = .center
        return sv
    }()

    override func setupViews() {
        super.setupViews()

        let width = UIScreen.main.bounds.width

        contentView.addViewsForAutolayout(views: [stateView])

        photoView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6).isActive = true

        photoView.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 48).isActive = true
        photoView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14).isActive = true

        photoView.widthAnchor.constraint(equalToConstant: width * 0.64).isActive = true
        photoView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6).isActive = true

        fileSizeLabel.rightAnchor.constraint(equalTo: bubbleView.rightAnchor, constant: 0).isActive = true
        stateView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -1.0).isActive = true
        stateView.rightAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: -2.0).isActive = true

        timeLabel.rightAnchor.constraint(equalTo: stateView.leftAnchor, constant: -2.0).isActive = true
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
