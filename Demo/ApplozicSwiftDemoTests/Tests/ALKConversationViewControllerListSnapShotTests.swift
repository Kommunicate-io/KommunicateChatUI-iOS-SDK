//
//  ALKConversationViewControllerUITests.swift
//  ApplozicSwiftDemoTests
//
//  Created by Mukesh Thawani on 17/06/18.
//  Copyright © 2018 Applozic. All rights reserved.
//

import Quick
import Nimble
import Nimble_Snapshots
import Applozic
@testable import ApplozicSwift

class ALKConversationViewControllerListSnapShotTests: QuickSpec {

    override func spec() {
        
        describe("Conversation list") {

            var conversationVC: ALKConversationListViewController!
            var navigationController: UINavigationController!

            beforeEach {

                conversationVC = ALKConversationListViewController(configuration: ALKConfiguration())
                conversationVC.dbServiceType = ALMessageDBServiceMock.self
                let firstMessage = ALKConversationViewModelMock.getMessageToPost()
                firstMessage.message = "first message"
                let secondmessage = ALKConversationViewModelMock.getMessageToPost()
                secondmessage.message = "second message"
                ALKConversationViewModelMock.testMessages = [firstMessage.messageModel, secondmessage.messageModel]
                conversationVC.conversationViewModelType = ALKConversationViewModelMock.self
                navigationController = ALKBaseNavigationViewController(rootViewController: conversationVC)
            }

            it("Show list") {
                XCTAssertNotNil(navigationController.view)
                XCTAssertNotNil(conversationVC.view)
                expect(navigationController).to(haveValidSnapshot())
            }

            it("Open chat thread") {
                conversationVC.beginAppearanceTransition(true, animated: false)
                conversationVC.endAppearanceTransition()
                XCTAssertNotNil(conversationVC.tableView)
                guard let tableView = conversationVC.tableView else {
                    return
                }
                tableView.delegate?.tableView?(tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
                XCTAssertNotNil(conversationVC.navigationController?.view)
                expect(conversationVC.navigationController).toEventually(haveValidSnapshot())
            }
        }

        describe("configure right nav bar icon") {

            var configuration: ALKConfiguration!
            var conversationVC: ALKConversationListViewController!
            var navigationController: UINavigationController!

            beforeEach {
                configuration = ALKConfiguration()
                configuration.rightNavBarImageForConversationListView = UIImage(named: "close", in: Bundle.applozic, compatibleWith: nil)
                conversationVC = ALKConversationListViewController(configuration: configuration)
                conversationVC.dbServiceType = ALMessageDBServiceMock.self
                conversationVC.conversationViewModelType = ALKConversationViewModelMock.self
                conversationVC.beginAppearanceTransition(true, animated: false)
                conversationVC.endAppearanceTransition()
                navigationController = ALKBaseNavigationViewController(rootViewController: conversationVC)
            }

            it("change icon image") {
                navigationController.navigationBar.snapshotView(afterScreenUpdates: true)
                expect(navigationController.navigationBar).to(haveValidSnapshot())
            }
        }

    }

    func getApplicationKey() -> NSString {

        let appKey = ALUserDefaultsHandler.getApplicationKey() as NSString?
        let applicationKey = appKey
        return applicationKey!
    }
}
