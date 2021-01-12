//
//  ALKMessagCell+Menu.swift
//  ApplozicSwift
//
//  Created by Mukesh on 19/09/19.
//

import Foundation

extension ALKMessageCell: ALKCopyMenuItemProtocol, ALKReplyMenuItemProtocol, ALKReportMessageMenuItemProtocol {
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
