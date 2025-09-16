//
//  KMMyVideoTemplateCell.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by sathyan elangovan on 28/09/23.
//

import Foundation
import UIKit

class KMMyVideoTemplateCell: KMVideoTemplateCell {
    
    fileprivate var stateView: UIImageView = {
        let sv = UIImageView()
        sv.isUserInteractionEnabled = false
        sv.contentMode = .center
        return sv
    }()

    let appSettingsUserDefaults = KMChatAppSettingsUserDefaults()
    
    override func setupViews() {
        super.setupViews()

        let width = UIScreen.main.bounds.width

        contentView.addViewsForAutolayout(views: [stateView])

        videoTableview.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6).isActive = true

        videoTableview.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 48).isActive = true
        videoTableview.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14).isActive = true

        videoTableview.widthAnchor.constraint(equalToConstant: width * 0.60).isActive = true
        videoTableview.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6).isActive = true
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
        setStatusStyle(statusView: stateView, KMChatMessageStyle.messageStatus)
    }
}
