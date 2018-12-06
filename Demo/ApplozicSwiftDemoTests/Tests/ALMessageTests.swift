//
//  ALMessageTests.swift
//  ApplozicSwiftDemoTests
//
//  Created by Mukesh Thawani on 25/03/18.
//  Copyright © 2018 Applozic. All rights reserved.
//

import XCTest

import Applozic
@testable import ApplozicSwift

class ALMessageTests: XCTestCase {

    let mockMessage: ALMessage = {
        let alMessage = ALMessage()
        alMessage.message = ""
        alMessage.type = "5"
        let date = Date().timeIntervalSince1970 * 1000
        alMessage.createdAtTime = NSNumber(value: date)
        alMessage.sendToDevice = false
        alMessage.deviceKey = ALUserDefaultsHandler.getDeviceKeyString()
        alMessage.shared = false
        alMessage.fileMeta = nil
        alMessage.storeOnDevice = false
        alMessage.contentType = Int16(ALMESSAGE_CONTENT_DEFAULT)
        alMessage.key = UUID().uuidString
        alMessage.source = Int16(SOURCE_IOS)
        return alMessage
    }()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    func testMyMessage_WhenTypeIsMyMessage() {
        let message = mockMessage
        message.type = myMessage
        XCTAssertTrue(message.isMyMessage)
    }

    func testMyMessage_WhenTypeIsNil() {
        let message = mockMessage
        message.type = nil
        XCTAssertFalse(message.isMyMessage)
    }

    func testMessageType_WhenTypeIsText() {
        let message = mockMessage
        message.contentType = Int16(ALMESSAGE_CONTENT_DEFAULT)
        XCTAssert(message.messageType == .text)
        //TODO: Check if imageURL, path and other items are nil or empty as it's a text message
    }

    func testMessageType_WhenTypeIsImage() {
        let message = mockMessage
        message.contentType = Int16(ALMESSAGE_CONTENT_ATTACHMENT)
        let fileMetaInfo = ALFileMetaInfo()
        fileMetaInfo.contentType = "image/xyz"
        message.fileMeta = fileMetaInfo
        XCTAssert(message.messageType == .photo)
    }

    func testMessageType_WhenGenericCard() {
        let message = mockMessage
        let mockMetaData = NSMutableDictionary()
        mockMetaData["templateId"] = "2"
        message.metadata = mockMetaData
        XCTAssert(message.messageType == .genericCard)
    }

    func testMessageType_WhenGenericList() {
        let message = mockMessage
        let mockMetaData = NSMutableDictionary()
        mockMetaData["templateId"] = "8"
        message.metadata = mockMetaData
        XCTAssert(message.messageType == .genericList)
    }
}
