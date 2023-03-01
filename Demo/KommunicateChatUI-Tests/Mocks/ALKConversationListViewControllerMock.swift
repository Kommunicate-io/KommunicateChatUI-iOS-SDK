//
//  ALKConversationListViewControllerMock.swift
//
//  Created by Mukesh on 31/12/18.
//

import Foundation
import KommunicateCore_iOS_SDK
@testable import KommunicateChatUI_iOS_SDK

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
