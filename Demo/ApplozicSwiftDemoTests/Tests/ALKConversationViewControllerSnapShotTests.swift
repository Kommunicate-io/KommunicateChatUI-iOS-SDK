//
//  ALKConversationViewControllerSnapShotTests.swift
//  ApplozicSwiftDemoTests
//
//  Created by Mukesh Thawani on 10/10/18.
//  Copyright © 2018 Applozic. All rights reserved.
//

import Foundation

import Quick
import Nimble
import Nimble_Snapshots
import Applozic
@testable import ApplozicSwift


class ALKConversationViewControllerSnapShotTests: QuickSpec {

    override func spec() {

        describe("Test Conversation VC") {

            var conversationVC: ALKConversationViewController!
            var navigationController: UINavigationController!

            beforeEach {
                let contactId = "testExample"
                conversationVC = ALKConversationViewController(configuration: ALKConfiguration())
                let convVM = ALKConversationViewModelMock(contactId: contactId, channelKey: nil)

                let firstMessage = ALKConversationViewModelMock.getMessageToPost()
                firstMessage.message = "first message"
                let secondMessage = ALKConversationViewModelMock.getMessageToPost()
                secondMessage.message = "second message"
                let thirdMessage = ALKConversationViewModelMock.getMessageToPost()
                thirdMessage.type = "4"
                let fourthMessage = ALKConversationViewModelMock.getMessageToPost()
                fourthMessage.type = "4"

                let testBundle = Bundle(for: ALKConversationViewControllerSnapShotTests.self)
                let (firstImageMessage, _) = convVM.send(photo: UIImage(named: "testImage.png", in: testBundle, compatibleWith: nil)!)
                firstImageMessage?.status = NSNumber(integerLiteral: Int(SENT.rawValue))
                let (secondImageMessage, _) = convVM.send(photo: UIImage(named: "testImage.png", in: testBundle, compatibleWith: nil)!)
                secondImageMessage?.status = NSNumber(integerLiteral: Int(SENT.rawValue))
                secondImageMessage?.type = "4"

                ALKConversationViewModelMock.testMessages = [firstMessage.messageModel, secondMessage.messageModel, thirdMessage.messageModel, fourthMessage.messageModel, firstImageMessage!.messageModel, secondImageMessage!.messageModel]

                conversationVC.viewModel = convVM
                navigationController = ALKBaseNavigationViewController(rootViewController: conversationVC)
            }

            it("has attachments") {
                XCTAssertNotNil(navigationController.view)
                XCTAssertNotNil(conversationVC.view)
                XCTAssertNotNil(conversationVC.navigationController?.view)
                expect(conversationVC.navigationController).to(haveValidSnapshot())
            }

            it("has text messages") {
                XCTAssertNotNil(conversationVC.viewModel.messageModels)
                XCTAssertFalse(conversationVC.viewModel.messageModels.isEmpty)

                conversationVC.tableView.setContentOffset(.zero, animated: true)
                expect(conversationVC.navigationController).to(recordSnapshot())

            }
        }
    }
}
