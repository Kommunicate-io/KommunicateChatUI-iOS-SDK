//
//  FAQMessage.swift
//  ApplozicSwift
//
//  Created by Shivam Pokhriyal on 03/06/19.
//

import Foundation

public struct FAQMessage {
    public var message: Message

    public var title: String?

    public var description: String?

    public var buttonLabel: String?

    public var buttons: [String]
}

extension FAQMessage {
    func getSuggestion() -> [SuggestedReplyMessage.Suggestion] {
        var buttonTitles = [SuggestedReplyMessage.Suggestion]()
        buttons.map { buttonTitles.append(SuggestedReplyMessage.Suggestion(title: $0, reply: $0)) }
        return buttonTitles
    }
}
