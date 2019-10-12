//
//  QuickReplyModel.swift
//  RichMessageKit
//
//  Created by Shivam Pokhriyal on 05/02/19.
//

import Foundation

public struct SuggestedReplyMessage {
    public enum SuggestionType {
        case link
        case normal
    }

    public struct Suggestion {
        let title: String
        let type: SuggestionType
        /// Reply that should be given when title is clicked
        /// If nil, then title will be used as reply
        public var reply: String?

        public init(title: String, reply: String? = nil, type: SuggestionType = .normal) {
            self.title = title
            self.reply = reply
            self.type = type
        }
    }

    /// Title to be displayed in the view.
    /// Dictionary of name and type.
    public var suggestion: [Suggestion]

    public var message: Message
}
