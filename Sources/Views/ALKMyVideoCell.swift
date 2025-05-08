//
//  ALKMyVideoCell.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by Mukesh Thawani on 10/07/17.
//

import UIKit

class ALKMyVideoCell: ALKVideoCell {
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

    let appSettingsUserDefaults = ALKAppSettingsUserDefaults()
    override func setupViews() {
        super.setupViews()

        contentView.addViewsForAutolayout(views: [stateView])

        photoView.topAnchor
            .constraint(equalTo: contentView.topAnchor, constant: Padding.PhotoView.top)
            .isActive = true

        photoView.leadingAnchor
            .constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 48)
            .isActive = true
        photoView.trailingAnchor
            .constraint(equalTo: contentView.trailingAnchor, constant: -Padding.PhotoView.right)
            .isActive = true

        photoView.widthAnchor
            .constraint(equalToConstant: ALKVideoCell.maxWidth * ALKVideoCell.widthPercentage)
            .isActive = true
        photoView.heightAnchor
            .constraint(equalToConstant: ALKVideoCell.maxWidth * ALKVideoCell.heightPercentage)
            .isActive = true

        bubbleView.backgroundColor = UIColor.hex8(Color.Background.grayF2.rawValue).withAlphaComponent(0.26)

        fileSizeLabel.rightAnchor.constraint(equalTo: bubbleView.rightAnchor, constant: 0).isActive = true
        stateView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -1.0).isActive = true
        stateView.trailingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: -2.0).isActive = true

        timeLabel.trailingAnchor.constraint(equalTo: stateView.leadingAnchor, constant: -2.0).isActive = true
        timeLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: 2).isActive = true
    }

    override func update(viewModel: ALKMessageViewModel) {
        super.update(viewModel: viewModel)
        setStatusStyle(statusView: stateView, ALKMessageStyle.messageStatus)
    }

    override class func bottomPadding() -> CGFloat {
        return 6
    }

    override func setupStyle() {
        super.setupStyle()
        if ALKMessageStyle.sentBubble.style == .edge {
            bubbleView.layer.cornerRadius = ALKMessageStyle.sentBubble.cornerRadius
            bubbleView.backgroundColor = appSettingsUserDefaults.getSentMessageBackgroundColor()
        } else {
            photoView.layer.cornerRadius = ALKMessageStyle.sentBubble.cornerRadius
            bubbleView.layer.cornerRadius = ALKMessageStyle.sentBubble.cornerRadius
        }
        captionLabel.font = ALKMessageStyle.sentMessage.font
        captionLabel.textColor = ALKMessageStyle.sentMessage.text
        setStatusStyle(statusView: stateView, ALKMessageStyle.messageStatus)
    }
}
