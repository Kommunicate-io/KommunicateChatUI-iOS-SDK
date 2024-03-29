//
//  ALKConversationVCMemoryLeakTests.swift
//
//  Created by Mukesh on 31/12/18.
//

import Nimble
import Quick
@testable import KommunicateChatUI_iOS_SDK

class ALKConversationVCMemoryLeakTests: QuickSpec {
    override func spec() {
        var conversationVC: ALKConversationViewControllerMock?
        var isDeinitCalled = false

        describe("when ALKConversationViewController is dismissed") {
            beforeEach {
                waitUntil(timeout: DispatchTimeInterval.seconds(5)) { done in
                    conversationVC = ALKConversationViewControllerMock(configuration: ALKConfiguration(), individualLaunch: true)
                    conversationVC?.viewModel = ALKConversationViewModel(contactId: "000", channelKey: nil, localizedStringFileName: ALKConfiguration().localizedStringFileName)
                    conversationVC?.contactService = ALContactServiceMock()
                    conversationVC?.onDeinitialized = {
                        done()
                        isDeinitCalled = true
                    }

                    let testUtil = ViewControllerTestUtil<ALKConversationViewController>()
                    testUtil.setupTopLevelUI(withViewController: conversationVC!)
                    testUtil.tearDownTopLevelUI()
                    conversationVC = nil
                }
            }
            it("calls deinit") {
                expect(isDeinitCalled).to(beTrue())
            }
        }
    }
}
