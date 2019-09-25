//
//  AutoCompleteItem.swift
//  ApplozicSwift
//
//  Created by Mukesh on 19/09/19.
//

import Foundation

public struct AutoCompleteItem {
    var key: String
    var content: String
    var displayImageURL: URL?

    /// A key used for referencing which substrings were autocompletes
    static let attributesKey = NSAttributedString.Key("com.applozicswift.autocompletekey")

    public init(key: String, content: String, displayImageURL: URL? = nil) {
        self.key = key
        self.content = content
        self.displayImageURL = displayImageURL
    }
}
