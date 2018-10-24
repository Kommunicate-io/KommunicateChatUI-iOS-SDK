//
//  ALKConversationListViewControllerTests.swift
//  ApplozicSwiftDemoTests
//
//  Created by Shivam Pokhriyal on 13/10/18.
//  Copyright © 2018 Applozic. All rights reserved.
//

import XCTest
import Applozic
@testable import ApplozicSwift
class ALKConversationListViewControllerTests: XCTestCase {
    
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

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testNewMessage_WhenActiveThreadIsDifferent() {
        let conversationVC = ALKConversationListViewController(configuration: ALKConfiguration())
        let conversationVM = ALKConversationViewModel(contactId: nil, channelKey: nil)
        
        let result = conversationVC.isNewMessageForActiveThread(alMessage: mockMessage, vm: conversationVM)
        XCTAssertFalse(result)
    }
    
    func testNewMessage_WhenActiveThreadIsSame() {
        let conversationVC = ALKConversationListViewController(configuration: ALKConfiguration())
        let conversationVM = ALKConversationViewModel(contactId: "testUser123", channelKey: nil)
        
        let result = conversationVC.isNewMessageForActiveThread(alMessage: mockMessage, vm: conversationVM)
        XCTAssertTrue(result)
    }

    func testMuteConversationCalledFromDelegate() {
        
        class ALKConversationListViewControllerMock: ALKConversationListViewController {
            var isMuteCalled: Bool = false
            
            required init(configuration: ALKConfiguration) {
                super.init(configuration: configuration)
            }
            
            required init?(coder aDecoder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
            
            override func mute(conversation: ALMessage, forTime: Int64, atIndexPath: IndexPath) {
                isMuteCalled = true
            }
        }
        
        let conversationListVC = ALKConversationListViewControllerMock(configuration: ALKConfiguration())
        XCTAssertFalse(conversationListVC.isMuteCalled)
        let muteConversationVC = MuteConversationViewController(delegate: conversationListVC.self, conversation: mockMessage, atIndexPath: IndexPath(row: 0, section: 0))

        muteConversationVC.tappedConfirm()
        
        XCTAssertTrue(conversationListVC.isMuteCalled)
    }
}
