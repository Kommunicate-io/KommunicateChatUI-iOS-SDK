//
//  KMAutoCompleteItem.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by Mukesh on 19/09/19.
//

import Foundation

public struct KMAutoCompleteItem {
    public let key: String
    public let content: String
    public let displayImageURL: URL?
    public let supportsRichMessage: Bool?

    public init(key: String, content: String, displayImageURL: URL? = nil, supportsRichMessage : Bool? = nil) {
        self.key = key
        self.content = content
        self.displayImageURL = displayImageURL
        self.supportsRichMessage = supportsRichMessage
    }
}

public extension KMAutoCompleteItem {
    /// A key used for referencing which substrings were autocompletes
    static let attributesKey = NSAttributedString.Key("com.kommunicatechatui.autocompletekey")
}
