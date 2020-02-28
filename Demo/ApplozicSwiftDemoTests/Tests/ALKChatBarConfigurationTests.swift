//
//  ALKChatBarConfigTests.swift
//  ApplozicSwiftDemoTests
//
//  Created by Mukesh on 09/07/19.
//  Copyright © 2019 Applozic. All rights reserved.
//

import XCTest
@testable import ApplozicSwift

class ALKChatBarConfigurationTests: XCTestCase {
    var chatBarConfig: ALKChatBarConfiguration!

    override func setUp() {
        chatBarConfig = ALKChatBarConfiguration()
    }

    func testDefaultAttachmentIconCount() {
        XCTAssert(chatBarConfig.attachmentIcons.count == AttachmentType.allCases.count)
    }

    func testAttachmentIcon_whenImageIsNil() {
        chatBarConfig.set(attachmentIcon: nil, for: .camera)
        XCTAssert(chatBarConfig.attachmentIcons.count == AttachmentType.allCases.count)
        let cameraIcon = chatBarConfig.attachmentIcons[.camera] ?? nil
        // Default icon should be present.
        XCTAssertNotNil(cameraIcon)
    }
}
