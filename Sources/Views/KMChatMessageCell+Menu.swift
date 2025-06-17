//
//  KMChatMessageCell+Menu.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by Mukesh on 19/09/19.
//

import Foundation

extension KMChatMessageCell: KMChatCopyMenuItemProtocol, KMChatReplyMenuItemProtocol, KMChatReportMessageMenuItemProtocol {
    func menuCopy(_: Any) {
        menuAction?(.copy)
    }

    func menuReply(_: Any) {
        menuAction?(.reply)
    }

    func menuReport(_: Any) {
        menuAction?(.report)
    }
}
