//
//  ConversationListTableViewControllerTests.swift
//
//  Created by Shivam Pokhriyal on 07/12/18.
//

import Foundation
import KommunicateCore_iOS_SDK
import XCTest
@testable import KommunicateChatUI_iOS_SDK

class ConversationListTableViewControllerTests: XCTestCase {
    var conversationVM: ALKConversationViewModel!

    override func setUp() {
        super.setUp()
        conversationVM = ALKConversationViewModel(contactId: nil, channelKey: nil, localizedStringFileName: ALKConfiguration().localizedStringFileName)
    }

    func testMuteConversationCalledFromDelegate() {
        let conversationListTableVCMock = ConversationListTableVCMock(viewModel: ALKConversationListViewModel(), dbService: ALMessageDBService(), configuration: ALKConfiguration(), showSearch: false)

        let muteConversationVC = MuteConversationViewController(delegate: conversationListTableVCMock.self, conversation: MockMessage().message, atIndexPath: IndexPath(row: 0, section: 0), configuration: ALKConfiguration())

        XCTAssertFalse(conversationListTableVCMock.isMuteCalled)

        muteConversationVC.tappedConfirm()

        XCTAssertTrue(conversationListTableVCMock.isMuteCalled)
    }
}
