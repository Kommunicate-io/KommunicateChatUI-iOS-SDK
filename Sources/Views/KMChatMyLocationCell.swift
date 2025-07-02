//
//  KMChatMyLocationCell.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by Mukesh Thawani on 04/05/17.
//

import Foundation
#if canImport(RichMessageKit)
    import RichMessageKit
#endif
import UIKit

final class KMChatMyLocationCell: KMChatLocationCell {
    // MARK: - Declare Variables or Types

    // MARK: Environment in chat

    fileprivate var stateView: UIImageView = {
        let sv = UIImageView()
        sv.isUserInteractionEnabled = false
        sv.contentMode = .center
        return sv
    }()

    // MARK: - Lifecycle

    override func setupViews() {
        super.setupViews()
        accessibilityIdentifier = "myLocationCell"
        // add view to contenview and setup constraint
        contentView.addViewsForAutolayout(views: [stateView])

        bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6.0).isActive = true
        bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6.0).isActive = true
        bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14.0).isActive = true

        stateView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -1.0).isActive = true
        stateView.trailingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: -2.0).isActive = true

        timeLabel.trailingAnchor.constraint(equalTo: stateView.leadingAnchor, constant: -2.0).isActive = true
        timeLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: 2).isActive = true
    }

    override func update(viewModel: KMChatMessageViewModel) {
        super.update(viewModel: viewModel)
        setStatusStyle(statusView: stateView, KMChatMessageStyle.messageStatus)
    }

    override func setupStyle() {
        super.setupStyle()
        bubbleView.setBubbleStyle(KMChatMessageStyle.sentBubble, isReceiverSide: false)
        setStatusStyle(statusView: stateView, KMChatMessageStyle.messageStatus)
    }

    override class func rowHeigh(viewModel: KMChatMessageViewModel, width: CGFloat) -> CGFloat {
        return super.rowHeigh(viewModel: viewModel, width: width) + 12.0
    }
}
