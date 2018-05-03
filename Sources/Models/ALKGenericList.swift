//
//  ALKGenericList.swift
//  Applozic
//
//  Created by Mukesh Thawani on 19/04/18.
//

import Foundation

public struct ALKGenericListTemplate: Codable {
        public let headerImage: String
        public let headerText: String
        public struct Element: Codable {
            public let title: String
            public let description: String
            public let imageUrl: String
            public let defaultActionType: String
            public let defaultActionUrl: String
        }
        public let elements: [Element]
        public struct Button: Codable {
            public let type: String
            public let title: String
            public let url: URL?
            public let id: String?
        }
        public let buttons: [Button]
}
