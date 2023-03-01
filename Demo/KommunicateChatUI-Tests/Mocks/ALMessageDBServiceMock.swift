//
//  ALMessageDBServiceMock.swift
//
//  Created by Mukesh Thawani on 25/09/18.
//

import Foundation
import KommunicateCore_iOS_SDK

class ALMessageDBServiceMock: ALMessageDBService {
    static var lastMessage: ALMessage! = MockMessage().message

    override func getMessages(_: NSMutableArray!) {
        delegate.getMessagesArray([ALMessageDBServiceMock.lastMessage as Any])
    }
}
