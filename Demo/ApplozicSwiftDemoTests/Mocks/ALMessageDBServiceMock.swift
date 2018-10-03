//
//  ALMessageDBServiceMock.swift
//  ApplozicSwiftDemoTests
//
//  Created by Mukesh Thawani on 25/09/18.
//  Copyright © 2018 Applozic. All rights reserved.
//

import Foundation
import Applozic

class ALMessageDBServiceMock: ALMessageDBService {

    override func getMessages(_ subGroupList: NSMutableArray!) {

        delegate.getMessagesArray([getMessageToPost()])
    }

    private func getMessageToPost() -> ALMessage {
        let alMessage = ALMessage()
        alMessage.to = "testexample"
        alMessage.contactIds = "testexample"
        alMessage.message = "hello there"
        alMessage.type = "5"
        let date = Date().timeIntervalSince1970*1000
        alMessage.createdAtTime = NSNumber(value: date)
        alMessage.sendToDevice = false
        alMessage.deviceKey = ALUserDefaultsHandler.getDeviceKeyString()
        alMessage.shared = false
        alMessage.fileMeta = nil
        alMessage.storeOnDevice = false
        alMessage.contentType = Int16(ALMESSAGE_CONTENT_DEFAULT)
        alMessage.key = UUID().uuidString
        alMessage.source = Int16(SOURCE_IOS)
        alMessage.conversationId = nil
        alMessage.groupId = nil
        return alMessage
    }
}

