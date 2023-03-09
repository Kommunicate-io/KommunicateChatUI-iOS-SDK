//
//  ConversationListTableViewDelegateMock.swift
//
//  Created by Shivam Pokhriyal on 07/12/18.
//

import Foundation
import KommunicateCore_iOS_SDK
@testable import KommunicateChatUI_iOS_SDK

class ConversationListTableViewDelegateMock: ALKConversationListTableViewDelegate {
    func muteNotification(conversation _: ALMessage, isMuted _: Bool) {}

    func userBlockNotification(userId _: String, isBlocked _: Bool) {}

    func tapped(_: ALKChatViewModelProtocol, at _: Int) {}

    func emptyChatCellTapped() {}

    func scrolledToBottom() {}
}
