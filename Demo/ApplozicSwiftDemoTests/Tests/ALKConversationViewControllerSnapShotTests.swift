//
//  ALKConversationViewControllerSnapshotTests.swift
//  ApplozicSwiftDemoTests
//
//  Created by Shivam Pokhriyal on 24/10/18.
//  Copyright © 2018 Applozic. All rights reserved.
//

import Quick
import Nimble
import Nimble_Snapshots
import Applozic
@testable import ApplozicSwift

class ALKConversationViewControllerSnapshotTests: QuickSpec{
    
    override func spec() {
        
        describe("Test Conversation VC") {
            
            var conversationVC: ALKConversationViewController!
            var navigationController: UINavigationController!
            
            beforeEach {
                let contactId = "testExample"
                conversationVC = ALKConversationViewController(configuration: ALKConfiguration())
                let convVM = ALKConversationViewModelMock(contactId: contactId, channelKey: nil, localizedStringFileName: ALKConfiguration().localizedStringFileName)
                
                let firstMessage = ALKConversationViewModelMock.getMessageToPost()
                firstMessage.message = "first message"
                let secondMessage = ALKConversationViewModelMock.getMessageToPost()
                secondMessage.message = "second message"
                let thirdMessage = ALKConversationViewModelMock.getMessageToPost()
                thirdMessage.type = "4"
                let fourthMessage = ALKConversationViewModelMock.getMessageToPost()
                fourthMessage.type = "4"
                
                let testBundle = Bundle(for: ALKConversationViewControllerSnapshotTests.self)
                let (firstImageMessage, _) = convVM.send(photo: UIImage(named: "testImage.png", in: testBundle, compatibleWith: nil)!, metadata :nil)
                let date = Date(timeIntervalSince1970: -123456789.0).timeIntervalSince1970*1000
                firstImageMessage?.createdAtTime = NSNumber(value: date)
                firstImageMessage?.status = NSNumber(integerLiteral: Int(SENT.rawValue))
                firstImageMessage?.message = "Test caption"
                let (secondImageMessage, _) = convVM.send(photo: UIImage(named: "testImage.png", in: testBundle, compatibleWith: nil)!, metadata :nil)
                secondImageMessage?.status = NSNumber(integerLiteral: Int(SENT.rawValue))
                secondImageMessage?.createdAtTime = NSNumber(value: date)
                secondImageMessage?.type = "4"
                
                ALKConversationViewModelMock.testMessages = [firstMessage.messageModel, secondMessage.messageModel, thirdMessage.messageModel, fourthMessage.messageModel, firstImageMessage!.messageModel, secondImageMessage!.messageModel]
                
                conversationVC.viewModel = convVM
                navigationController = ALKBaseNavigationViewController(rootViewController: conversationVC)
            }
            
            it("has all the messages") {
                XCTAssertNotNil(navigationController.view)
                XCTAssertNotNil(conversationVC.view)
                XCTAssertNotNil(conversationVC.navigationController?.view)
                
                // We are not verifying the actual image, just the image message
                // as image is loaded asynchronously so, it will be tested through
                // functional tests.
                expect(conversationVC.navigationController).to(haveValidSnapshot())
            }
        }
        
        describe("Configure NavBar right button") {
            var configuration: ALKConfiguration!
            var conversationVC: ALKConversationViewController!
            var navigationController: UINavigationController!
            
            func prepareController() {
                conversationVC = ALKConversationViewController(configuration: configuration)
                conversationVC.viewModel = ALKConversationViewModelMock(contactId: "demoUserId", channelKey: nil, localizedStringFileName: ALKConfiguration().localizedStringFileName)
                conversationVC.beginAppearanceTransition(true, animated: false)
                conversationVC.endAppearanceTransition()
                let contact = ALContact()
                contact.displayName = "demoDisplayName"
                conversationVC.updateDisplay(contact: contact, channel: nil)
                navigationController = ALKBaseNavigationViewController(rootViewController: conversationVC)
            }
            
            it("use system icon") {
                configuration = ALKConfiguration()
                configuration.rightNavBarSystemIconForConversationView = UIBarButtonItem.SystemItem.bookmarks
                
                prepareController()
                
                navigationController.navigationBar.snapshotView(afterScreenUpdates: true)
                expect(navigationController.navigationBar).to(haveValidSnapshot())
            }
            
            it("use image") {
                configuration = ALKConfiguration()
                configuration.rightNavBarImageForConversationView = UIImage(named: "close", in: Bundle.applozic, compatibleWith: nil)
                
                prepareController()
                
                navigationController.navigationBar.snapshotView(afterScreenUpdates: true)
                expect(navigationController.navigationBar).to(haveValidSnapshot())
            }
            
            it("hide button") {
                configuration = ALKConfiguration()
                configuration.hideRightNavBarButtonForConversationView = true
                prepareController()
                navigationController.navigationBar.snapshotView(afterScreenUpdates: true)
                expect(navigationController.navigationBar).to(haveValidSnapshot())
            }
        }
    }
}
