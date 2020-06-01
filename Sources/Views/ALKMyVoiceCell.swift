//
//  ALKMyVoiceCell.swift
//  ApplozicSwift
//
//  Created by Mukesh Thawani on 04/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import Foundation

import AVFoundation
import Kingfisher
import UIKit

class ALKMyVoiceCell: ALKVoiceCell {
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

        soundPlayerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6).isActive = true
        soundPlayerView.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 48).isActive = true
        soundPlayerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14).isActive = true
        soundPlayerView.widthAnchor.constraint(equalToConstant: width * 0.48).isActive = true
        soundPlayerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6).isActive = true

        bubbleView.backgroundColor = UIColor.hex8(Color.Background.grayF2.rawValue).withAlphaComponent(0.26)
        stateView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -1.0).isActive = true
        stateView.trailingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: -2.0).isActive = true

        timeLabel.trailingAnchor.constraint(equalTo: stateView.leadingAnchor, constant: -2.0).isActive = true
        timeLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: 0).isActive = true
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
        bubbleView.setBubbleStyle(ALKMessageStyle.sentBubble, isReceiverSide: false)
        soundPlayerView.setBubbleStyle(ALKMessageStyle.sentBubble, isReceiverSide: false)
        setStatusStyle(statusView: stateView, ALKMessageStyle.messageStatus)
    }
}
