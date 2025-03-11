//
//  KMConversationScreenConfiguration.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by sathyan elangovan on 19/04/23.
//

import Foundation
import UIKit

/// - NOTE: Customization for Conversation Screen
public enum KMConversationScreenConfiguration {
    // If you add message, it will be shown as top first message
    public static var staticTopMessage: String = ""
    // If you add image here, it will be shown along with static top message.
    public static var staticTopIcon: UIImage?
    // If true, Typing Indicator will be shown while bot fetching the response. By default its false/
    public static var showTypingIndicatorWhileFetchingResponse: Bool = false

}
