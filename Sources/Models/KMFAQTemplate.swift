//
//  KMFAQTemplate.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by Shivam Pokhriyal on 03/06/19.
//

import Foundation

public struct KMFAQTemplate: Codable {
    public let title: String?
    public let description: String?
    public let buttonLabel: String?
    public let buttons: [Button]?

    public struct Button: Codable {
        public let name: String
        public let type: String?
    }
}
