//
//  ALKConversationViewControllerMock.swift
//  ApplozicSwiftDemoTests
//
//  Created by Shivam Pokhriyal on 25/10/18.
//  Copyright © 2018 Applozic. All rights reserved.
//

import Foundation
@testable import KommunicateChatUI_iOS_SDK_Demo

class ALKConversationViewControllerMock: ALKConversationViewController {
    var testDisplayName: String!
    var onDeinitialized: (() -> Void)?

    override public init(configuration: ALKConfiguration,
                         individualLaunch: Bool)
    {
        super.init(configuration: configuration, individualLaunch: individualLaunch)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    deinit {
        onDeinitialized?()
    }

    override func setTypingNoticeDisplayName(displayName: String) {
        testDisplayName = displayName
    }
}
