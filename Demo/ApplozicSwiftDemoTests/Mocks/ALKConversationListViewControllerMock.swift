//
//  ALKConversationListViewControllerMock.swift
//  ApplozicSwiftDemoTests
//
//  Created by Mukesh on 31/12/18.
//  Copyright © 2018 Applozic. All rights reserved.
//

import Foundation
import Applozic
@testable import ApplozicSwift

class ALKConversationListViewControllerMock: ALKConversationListViewController {
    var isMuteCalled: Bool = false
    var onDeinitialized: (() -> Void)?

    required init(configuration: ALKConfiguration) {
        super.init(configuration: configuration)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        onDeinitialized?()
    }

    override func mute(conversation: ALMessage, forTime: Int64, atIndexPath: IndexPath) {
        isMuteCalled = true
    }
}
