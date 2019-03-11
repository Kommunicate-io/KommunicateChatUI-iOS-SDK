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

    override func prepareController() {
        messageModels = ALKConversationViewModelMock.testMessages
        self.delegate?.loadingFinished(error: nil)
    }

    override func markConversationRead() {

    }

    override func currentConversationProfile(completion: @escaping (ALKConversationProfile?) -> ()) {
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
