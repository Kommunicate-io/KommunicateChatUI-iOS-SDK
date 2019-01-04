//
//  ConversationListTableVCMock.swift
//  ApplozicSwiftDemoTests
//
//  Created by Shivam Pokhriyal on 19/12/18.
//  Copyright © 2018 Applozic. All rights reserved.
//

import Foundation
import Applozic
@testable import ApplozicSwift

class ConversationListTableVCMock: ALKConversationListTableViewController {
    
    var isMuteCalled: Bool = false
    
    override func mute(conversation: ALMessage, forTime: Int64, atIndexPath: IndexPath) {
        isMuteCalled = true
    }
    
    func tapped(_ chat: ALKChatViewModelProtocol, at index: Int) {
        
    }
    
    func emptyChatCellTapped() {
        
    }
    
}
