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
    func getButtonTitles() -> [SuggestedReplyMessage.Button] {
        var buttonTitles = [SuggestedReplyMessage.Button]()
        buttons.map { buttonTitles.append(SuggestedReplyMessage.Button(title: $0)) }
        return buttonTitles
    }
}
