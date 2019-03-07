//
//  ALKConversationViewModelMock.swift
//  ApplozicSwiftDemoTests
//
//  Created by Mukesh Thawani on 26/09/18.
//  Copyright © 2018 Applozic. All rights reserved.
//

import Foundation
import Applozic
@testable import ApplozicSwift

class ALKConversationViewModelMock: ALKConversationViewModel {

    static var testMessages: [ALKMessageModel] = []

    static func getMessageToPost() -> ALMessage {
        let alMessage = ALMessage()
        alMessage.to = "testexample"
        alMessage.contactIds = "testexample"
        alMessage.message = "hello there"
        alMessage.type = "5"
        let date = Date(timeIntervalSince1970: -123456789.0).timeIntervalSince1970*1000
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
        alMessage.status = NSNumber(integerLiteral: Int(SENT.rawValue))
        return alMessage
    }

    override func prepareController() {
        messageModels = ALKConversationViewModelMock.testMessages
        self.delegate?.loadingFinished(error: nil)
    }

    override func markConversationRead() {

    }

    override func currentConversationProfile(completion: @escaping (ALKConversationProfile?) -> ()) {
        var conversationProfile = ALKConversationProfile()
        conversationProfile.name = "demoDisplayName"
        conversationProfile.status = ALKConversationProfile.Status(isOnline: false, lastSeenAt: nil)
        completion(conversationProfile)
    }
}
