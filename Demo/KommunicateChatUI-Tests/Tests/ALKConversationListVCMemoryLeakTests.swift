//
//  ALKConversationListVCMemoryLeakTests.swift
//
//  Created by Mukesh on 31/12/18.
//

import Nimble
import Quick
@testable import KommunicateChatUI_iOS_SDK

class ALKConversationListVCMemoryLeakTests: QuickSpec {
    override func spec() {
        var conversationListVC: ALKConversationListViewControllerMock!
        var isDeinitCalled = false

        describe("when ALKConversationListViewController is dismissed") {
            beforeEach {
                waitUntil(timeout: DispatchTimeInterval.seconds(Int(5))) { done in
                    conversationListVC = ALKConversationListViewControllerMock(configuration: ALKConfiguration())
                    let conversationVC = ALKConversationViewControllerMock(configuration: ALKConfiguration(), individualLaunch: true)
                    conversationVC.viewModel = ALKConversationViewModel(contactId: nil, channelKey: 000, localizedStringFileName: ALKConfiguration().localizedStringFileName)
                    let conversationListVM = ALKConversationListViewModel()

                    // Pass all mocks
                    conversationListVC.viewModel = conversationListVM
                    conversationListVC.dbService = ALMessageDBServiceMock()
                    conversationListVC.conversationViewController = conversationVC
                    conversationListVC.onDeinitialized = {
                        done()
                        isDeinitCalled = true
                    }

                    let testUtil = ViewControllerTestUtil<ALKConversationListViewControllerMock>()
                    testUtil.setupTopLevelUI(withViewController: conversationListVC!)
                    testUtil.tearDownTopLevelUI()
                    conversationListVC = nil
                }
            }
            it("calls deinit") {
                expect(isDeinitCalled).to(beTrue())
            }
        }
    }
}
