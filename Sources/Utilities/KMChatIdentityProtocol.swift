//
//  KMChatIdentityProtocol.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by Mukesh Thawani on 04/05/17.
//

import Foundation

public protocol KMChatIdentityProtocol {
    var displayName: String { get }
    var displayPhoto: URL? { get }
    var userID: String { get }
    var mood: String? { get }
    var emailAddress: String? { get }
}

protocol KMChatAccountProtocol {
    var ID: String { get }
}

protocol KMChatAccountIdentityProtocol: KMChatIdentityProtocol {
    var identityOnboard: Bool { get }
    var isRequireVerification: Bool { get }
}
