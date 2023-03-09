//
//  ALKChatBarConfigTests.swift
//
//  Created by Mukesh on 09/07/19.
//

import XCTest
@testable import KommunicateChatUI_iOS_SDK


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
