//
//  ALKMessagCell+Menu.swift
//  ApplozicSwift
//
//  Created by Mukesh on 19/09/19.
//

import Foundation

extension ALKMessageCell: ALKCopyMenuItemProtocol, ALKReplyMenuItemProtocol, ALKReportMessageMenuItemProtocol {
    func menuCopy(_: Any) {
        UIPasteboard.general.string = viewModel?.message ?? ""
    }

    func menuReply(_: Any) {
        menuAction?(.reply)
    }

    func menuReport(_: Any) {
        menuAction?(.reportMessage)
    }
}
