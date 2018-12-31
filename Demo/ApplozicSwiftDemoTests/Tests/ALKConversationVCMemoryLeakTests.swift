//
//  ALKConversationVCMemoryLeakTests.swift
//  ApplozicSwiftDemoTests
//
//  Created by Mukesh on 31/12/18.
//  Copyright © 2018 Applozic. All rights reserved.
//

import Nimble
import Quick
@testable import ApplozicSwift

class ALKConversationVCMemoryLeakTests: QuickSpec {

    override func spec() {

        var conversationVC: ALKConversationViewControllerMock?
        var isDeinitCalled: Bool = false

        describe("Controller should be deallocated when dismissed") {
            beforeEach {
                waitUntil(timeout: 5.0) { done in
                    conversationVC  = ALKConversationViewControllerMock(configuration: ALKConfiguration())
                    conversationVC?.viewModel = ALKConversationViewModel(contactId: nil, channelKey: 000, localizedStringFileName: ALKConfiguration().localizedStringFileName)
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
            it("deinit called") {
                expect(isDeinitCalled).to(beTrue())
            }
        }
    }
}
