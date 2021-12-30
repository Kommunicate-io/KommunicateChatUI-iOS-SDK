//
//  ALKConversationListViewControllerMock.swift
//  ApplozicSwiftDemoTests
//
//  Created by Mukesh on 31/12/18.
//  Copyright © 2018 Applozic. All rights reserved.
//

import KommunicateCore_iOS_SDK
import Foundation
@testable import KommunicateChatUI_iOS_SDK_Demo

class ALKConversationListViewControllerMock: ALKConversationListViewController, Muteable {
    var isMuteCalled: Bool = false
    var onDeinitialized: (() -> Void)?

    required init(configuration: ALKConfiguration) {
        super.init(configuration: configuration)
    }

    deinit {
        onDeinitialized?()
    }

    func mute(conversation _: ALMessage, forTime _: Int64, atIndexPath _: IndexPath) {
        isMuteCalled = true
    }
}
