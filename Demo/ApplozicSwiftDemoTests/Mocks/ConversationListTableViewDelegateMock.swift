//
//  ConversationListTableViewDelegateMock.swift
//  ApplozicSwiftDemoTests
//
//  Created by Shivam Pokhriyal on 07/12/18.
//  Copyright © 2018 Applozic. All rights reserved.
//

import Foundation
import Applozic

@testable import ApplozicSwift

class ConversationListTableViewDelegateMock: ALKConversationListTableViewDelegate {
    func muteNotification(conversation: ALMessage, isMuted: Bool) {

    }

    func userBlockNotification(userId: String, isBlocked: Bool) {

    }

    
    func tapped(_ chat: ALKChatViewModelProtocol, at index: Int) {
        
    }
    
    func emptyChatCellTapped() {
        
    }
    
    func scrolledToBottom() {
        
    }
}
