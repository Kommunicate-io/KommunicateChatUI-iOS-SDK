//
//  ConversationListDelegateMock.swift
//  ApplozicSwiftDemoTests
//
//  Created by Mukesh on 03/12/18.
//  Copyright © 2018 Applozic. All rights reserved.
//

import Foundation
import XCTest
import ApplozicSwift

class ConversationListTest: ALKConversationListDelegate {

    var selectItemExpectation: XCTestExpectation!

    func conversation(_ message: ALKChatViewModelProtocol, willSelectItemAt index: Int, viewController: ALKConversationListViewController) {
        selectItemExpectation.fulfill()
    }
}
