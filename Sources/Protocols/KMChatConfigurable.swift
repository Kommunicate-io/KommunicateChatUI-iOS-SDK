//
//  KMChatConfigurable.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by Mukesh Thawani on 13/06/18.
//

import Foundation

public protocol KMChatConfigurable {
    var configuration: KMChatConfiguration! { get }
    init(configuration: KMChatConfiguration)
}
