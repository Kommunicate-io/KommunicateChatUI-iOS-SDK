//
//  ALKGenericCard.swift
//  Applozic
//
//  Created by Mukesh Thawani on 27/03/18.
//

import Foundation

public struct ALKGenericCardTemplate: Codable {

    public let cards: [ALKGenericCard]

    private enum CodingKeys: String, CodingKey {
        case cards = "elements"
    }
}

public struct ALKGenericCard: Codable {
    public let title: String
    public let subtitle: String
    public let description: String
    public let imageUrl: URL?
    public struct Button: Codable {
        public let type: String
        public let title: String
        public let url: URL?
        public let id: String?
    }
    public let buttons: [Button]?
    private enum CodingKeys: String, CodingKey {
        case title
        case subtitle
        case description
        case imageUrl = "image_url"
        case buttons
    }
}
