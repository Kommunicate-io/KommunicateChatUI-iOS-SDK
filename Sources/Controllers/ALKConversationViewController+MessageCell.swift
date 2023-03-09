//
//  ALKConversationViewController+MessageCell.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by Mukesh on 09/04/20.
//

import Foundation
import UIKit

extension ALKConversationViewController: ALKMessageCellDelegate {
    public func urlTapped(url: URL, message _: ALKMessageViewModel) {
        UIApplication.sharedUIApplication()?.open(url)
    }
}
