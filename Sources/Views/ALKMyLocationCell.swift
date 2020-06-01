//
//  ALKMyLocationCell.swift
//  ApplozicSwift
//
//  Created by Mukesh Thawani on 04/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import Foundation

final class ALKMyLocationCell: ALKLocationCell {
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

    override func update(viewModel: ALKMessageViewModel) {
        super.update(viewModel: viewModel)
        setStatusStyle(statusView: stateView, ALKMessageStyle.messageStatus)
    }

    override func setupStyle() {
        super.setupStyle()
        bubbleView.setBubbleStyle(ALKMessageStyle.sentBubble, isReceiverSide: false)
        setStatusStyle(statusView: stateView, ALKMessageStyle.messageStatus)
    }

    override class func rowHeigh(viewModel: ALKMessageViewModel, width: CGFloat) -> CGFloat {
        return super.rowHeigh(viewModel: viewModel, width: width) + 12.0
    }
}
