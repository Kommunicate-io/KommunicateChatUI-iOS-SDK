//
//  KMCoreMessageArrayWrapper+Extension.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by Shivam Pokhriyal on 20/03/19.
//

import KommunicateCore_iOS_SDK

extension KMCoreMessageArrayWrapper {
    func contains(message: KMCoreMessage) -> Bool {
        guard let messages = messageArray as? [KMCoreMessage] else {
            return false
        }
        return messages.contains(message)
    }
}
