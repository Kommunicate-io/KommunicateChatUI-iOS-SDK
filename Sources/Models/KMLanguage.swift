//
//  KMLanguage.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by sathyan elangovan on 20/07/23.
//

import Foundation

public struct KMLanguage {
    var name: String
    var code: String
    var sendMessageOnClick: Bool
    var messageToSend: String?
    
    public init(name: String, code: String, sendMessageOnClick: Bool = false, messageToSend: String? = nil) {
        self.name = name
        self.code = code
        self.sendMessageOnClick = sendMessageOnClick
        self.messageToSend = messageToSend
    }
}
