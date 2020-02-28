//
//  ConversationListDelegateMock.swift
//  ApplozicSwiftDemoTests
//
//  Created by Mukesh on 03/12/18.
//  Copyright © 2018 Applozic. All rights reserved.
//

import ApplozicSwift
import Foundation
import XCTest

class ConversationListTest: ALKConversationListDelegate {
    var selectItemExpectation: XCTestExpectation!

    func conversation(_: ALKChatViewModelProtocol, willSelectItemAt _: Int, viewController _: ALKConversationListViewController) {
        selectItemExpectation.fulfill()
    }
}
