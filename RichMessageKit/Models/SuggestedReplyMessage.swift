//
//  QuickReplyModel.swift
//  RichMessageKit
//
//  Created by Shivam Pokhriyal on 05/02/19.
//

import Foundation

public struct SuggestedReplyMessage {

    public enum ButtonType {
        case link
        case normal
    }

    public struct Button {
        let title: String
        let type: ButtonType 

        public init(title: String, type: ButtonType = .normal) {
            self.title = title
            self.type = type
        }
    }

    /// Title to be displayed in the view.
    /// Dictionary of name and type.
    public var title: [Button]

    /// Reply that should be given when title is clicked
    /// If nil, then title will be used as reply
    public var reply: [String?]

    public var message: Message
}
