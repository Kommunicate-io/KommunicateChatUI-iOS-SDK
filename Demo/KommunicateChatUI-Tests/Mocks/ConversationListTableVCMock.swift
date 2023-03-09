//
//  ConversationListTableVCMock.swift
//
//  Created by Shivam Pokhriyal on 19/12/18.
//

import Foundation
import KommunicateCore_iOS_SDK
@testable import KommunicateChatUI_iOS_SDK

class ConversationListTableVCMock: ALKConversationListTableViewController {
    var isMuteCalled: Bool = false

    override func mute(conversation _: ALMessage, forTime _: Int64, atIndexPath _: IndexPath) {
        isMuteCalled = true
    }

    func tapped(_: ALKChatViewModelProtocol, at _: Int) {}

    func emptyChatCellTapped() {}
}
