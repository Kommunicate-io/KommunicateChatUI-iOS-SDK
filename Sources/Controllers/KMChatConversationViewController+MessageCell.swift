//
//  KMChatConversationViewController+MessageCell.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by Mukesh on 09/04/20.
//

import Foundation
import UIKit

extension KMChatConversationViewController: KMChatMessageCellDelegate {
    public func urlTapped(url: URL, message _: KMChatMessageViewModel) {
        UIApplication.sharedUIApplication()?.open(url)
    }
}
