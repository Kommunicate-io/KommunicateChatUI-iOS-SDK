//  KMChatFriendPhotoLandscapeCell.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by Mukesh Thawani on 04/05/17.
//

import Foundation
import UIKit

// MARK: - FriendPhotoLandscapeCell

final class KMChatFriendPhotoLandscapeCell: KMChatFriendPhotoCell {
    override func setupViews() {
        super.setupViews()
        let width = UIScreen.main.bounds.width
        photoView.widthAnchor.constraint(equalToConstant: width * 0.64).isActive = true
    }
}
