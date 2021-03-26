//
//  ALKConversationViewController+MessageCell.swift
//  ApplozicSwift
//
//  Created by Mukesh on 09/04/20.
//

import Foundation
import UIKit

extension ALKConversationViewController: ALKMessageCellDelegate {
    public func urlTapped(url: URL, message _: ALKMessageViewModel) {
        UIApplication.shared.open(url)
    }
}
