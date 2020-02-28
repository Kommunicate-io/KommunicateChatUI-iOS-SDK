//
//  ALKConversationViewModelTests.swift
//  ApplozicSwiftDemoTests
//
//  Created by Mukesh Thawani on 26/03/18.
//  Copyright © 2018 Applozic. All rights reserved.
//

import XCTest
@testable import ApplozicSwift

class ALKConversationViewModelTests: XCTestCase {
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testContentType_WhenSendingImage() {
        let conversationVM = ALKConversationViewModel(contactId: nil, channelKey: nil, localizedStringFileName: ALKConfiguration().localizedStringFileName)
        let testBundle = Bundle(for: ALKConversationViewModelTests.self)
        let (message, _) = conversationVM.send(photo: UIImage(named: "testImage.png", in: testBundle, compatibleWith: nil)!, metadata: nil)
        XCTAssertNotNil(message)
        XCTAssertNotNil(message?.fileMeta.contentType)
        XCTAssert(message!.fileMeta.contentType.hasPrefix("image"))
    }

    func testMessage_WhenSendingEmptyImage_isNil() {
        let conversationVM = ALKConversationViewModel(contactId: nil, channelKey: nil, localizedStringFileName: ALKConfiguration().localizedStringFileName)
        let (message, _) = conversationVM.send(photo: UIImage(), metadata: nil)
        XCTAssertNil(message)
    }
}
