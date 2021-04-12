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

    public init(message: Message,
                title: String?,
                description: String?,
                buttonLabel: String?,
                buttons: [String])
    {
        self.message = message
        self.title = title
        self.description = description
        self.buttonLabel = buttonLabel
        self.buttons = buttons
    }
}

extension FAQMessage {
    func getSuggestion() -> [SuggestedReplyMessage.Suggestion] {
        var buttonTitles = [SuggestedReplyMessage.Suggestion]()
        buttons.forEach { button in
            buttonTitles
                .append(SuggestedReplyMessage.Suggestion(title: button, reply: button))
        }
        return buttonTitles
    }
}
