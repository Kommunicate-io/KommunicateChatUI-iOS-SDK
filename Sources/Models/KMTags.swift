//
//  KMTags.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by sathyan elangovan on 21/11/22.
//

import Foundation

struct KMTags: Decodable {
    let id: Int
    let applicationID: String
    let name: String
    let createdBy: Int?
    let color: String?
    let createdAt, updatedAt: String?
    let deletedAt: String?
    enum CodingKeys: String, CodingKey {
        case id, name, createdBy, color
        case applicationID = "applicationId"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
}
