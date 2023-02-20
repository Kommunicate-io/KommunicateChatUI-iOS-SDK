//
//  ALKIdentityProtocol.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by Mukesh Thawani on 04/05/17.
//

import Foundation

public protocol ALKIdentityProtocol {
    var displayName: String { get }
    var displayPhoto: URL? { get }
    var userID: String { get }
    var mood: String? { get }
    var emailAddress: String? { get }
}

protocol ALKAccountProtocol {
    var ID: String { get }
}

protocol ALKAccountIdentityProtocol: ALKIdentityProtocol {
    var identityOnboard: Bool { get }
    var isRequireVerification: Bool { get }
}
