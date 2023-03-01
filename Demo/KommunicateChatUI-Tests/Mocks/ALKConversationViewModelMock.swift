//
//  ALKConversationViewModelMock.swift
//
//  Created by Mukesh Thawani on 26/09/18.
//

import Foundation
import KommunicateCore_iOS_SDK
@testable import KommunicateChatUI_iOS_SDK

class ALKConversationViewModelMock: ALKConversationViewModel {
    static var testMessages: [ALKMessageModel] = []

    override func prepareController() {
        messageModels = ALKConversationViewModelMock.testMessages
        delegate?.loadingFinished(error: nil)
    }

    override func markConversationRead() {}

    override func currentConversationProfile(completion: @escaping (ALKConversationProfile?) -> Void) {
        guard contactId != nil else {
            completion(nil)
            return
        }
        var conversationProfile = ALKConversationProfile()
        conversationProfile.name = "demoDisplayName"
        conversationProfile.status = ALKConversationProfile.Status(isOnline: false, lastSeenAt: nil)
        completion(conversationProfile)
    }
}
