//
//  ALKConversationViewControllerMock.swift
//  ApplozicSwiftDemoTests
//
//  Created by Shivam Pokhriyal on 25/10/18.
//  Copyright © 2018 Applozic. All rights reserved.
//

import Foundation
@testable import ApplozicSwift

class ALKConversationViewControllerMock: ALKConversationViewController {
    var testDisplayName: String!
    var onDeinitialized: (() -> Void)?

    required init(configuration: ALKConfiguration) {
        super.init(configuration: configuration)
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
