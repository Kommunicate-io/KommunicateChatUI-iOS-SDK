//
//  ConversationListTableViewControllerTests.swift
//  ApplozicSwiftDemoTests
//
//  Created by Shivam Pokhriyal on 07/12/18.
//  Copyright © 2018 Applozic. All rights reserved.
//

import Foundation
import XCTest
import Applozic
@testable import ApplozicSwift

class ConversationListTableViewControllerTests: XCTestCase {

    let mockMessage: ALMessage = {
        let alMessage = ALMessage()
        alMessage.contactIds = "testUser123"
        alMessage.message = "This is a test message"
        alMessage.type = "5"
        let date = Date().timeIntervalSince1970 * 1000
        alMessage.createdAtTime = NSNumber(value: date)
        alMessage.sendToDevice = false
        alMessage.deviceKey = ALUserDefaultsHandler.getDeviceKeyString()
        alMessage.shared = false
        alMessage.fileMeta = nil
        alMessage.storeOnDevice = false
        alMessage.contentType = Int16(ALMESSAGE_CONTENT_DEFAULT)
        alMessage.key = UUID().uuidString
        alMessage.source = Int16(SOURCE_IOS)
        return alMessage
    }()

    var conversationVM: ALKConversationViewModel!
    
    override func setUp() {
        super.setUp()
        conversationVM = ALKConversationViewModel(contactId: nil, channelKey: nil, localizedStringFileName: ALKConfiguration().localizedStringFileName)
        
    }
    
    func testMuteConversationCalledFromDelegate() {
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
        let conversationListTableVCMock = ConversationListTableVCMock(viewModel: ALKConversationListViewModel(), dbService: ALMessageDBService(), configuration: ALKConfiguration(), delegate: ConversationListTableViewDelegateMock())
        
        let muteConversationVC = MuteConversationViewController(delegate: conversationListTableVCMock.self, conversation: mockMessage, atIndexPath: IndexPath(row: 0, section: 0), configuration: ALKConfiguration())
        
        XCTAssertFalse(conversationListTableVCMock.isMuteCalled)
        
        muteConversationVC.tappedConfirm()
        
        XCTAssertTrue(conversationListTableVCMock.isMuteCalled)
    }

}
