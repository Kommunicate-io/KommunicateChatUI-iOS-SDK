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

    var conversationListVC: ALKConversationListViewController!

    override func setUp() {
        super.setUp()
        conversationListVC = ALKConversationListViewController(configuration: ALKConfiguration())
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testNewMessage_WhenActiveThreadIsDifferent() {
        let conversationVM = ALKConversationViewModel(contactId: nil, channelKey: nil, localizedStringFileName: ALKConfiguration().localizedStringFileName)

        let result = conversationListVC.isNewMessageForActiveThread(alMessage: mockMessage, vm: conversationVM)
        XCTAssertFalse(result)
    }

    func testNewMessage_WhenActiveThreadIsSame() {
        let conversationVM = ALKConversationViewModel(
            contactId: "testUser123",
            channelKey: nil,
            localizedStringFileName: ALKConfiguration().localizedStringFileName)
        let result = conversationListVC
            .isNewMessageForActiveThread(alMessage: mockMessage, vm: conversationVM)
        XCTAssertTrue(result)
    }

    func testDelegateCallback_whenMessageThreadIsSelected() {

        let selectItemExpectation = XCTestExpectation(description: "Conversation list item selected")
        let conversation = ConversationListTest()
        conversation.selectItemExpectation = selectItemExpectation

        let conversationListVM = ALKConversationListViewModel()
        let conversationVC = ALKConversationViewControllerMock(configuration: ALKConfiguration())
        conversationVC.viewModel = ALKConversationViewModelMock(contactId: nil, channelKey: 000, localizedStringFileName: ALKConfiguration().localizedStringFileName)

        // Pass all mocks
        conversationListVC.viewModel = conversationListVM
        conversationListVC.delegate = conversation
        conversationListVC.dbServiceType = ALMessageDBServiceMock.self
        conversationListVC.conversationViewController = conversationVC

        // Select first thread
        conversationListVC.viewWillAppear(false)
        let firstIndex = IndexPath(row: 0, section: 0)
        XCTAssertNotNil(conversationListVC.tableView)
        guard let tableView = conversationListVC.tableView else {
            return
        }
        tableView.selectRow(at: firstIndex, animated: false, scrollPosition: .none)
        tableView.delegate?.tableView?(tableView, didSelectRowAt: firstIndex)
        
        wait(for: [selectItemExpectation], timeout: 2)
    }
    
    func testMessageSentByLoggedInUser_WhenTypeOutBox() {
        mockMessage.type = "5" // Message type OUTBOX
        XCTAssertTrue(conversationListVC.isMessageSentByLoggedInUser(alMessage: mockMessage))
    }
    
    func testMessageSentByLoggedInUser_WhenTypeInBox() {
        mockMessage.type = "4" // Message type INBOX
        XCTAssertFalse(conversationListVC.isMessageSentByLoggedInUser(alMessage: mockMessage))
    }
}
