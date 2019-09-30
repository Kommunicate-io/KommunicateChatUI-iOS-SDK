//
//  ALKMessageViewModel+Extension.swift
//  ApplozicSwift
//
//  Created by Shivam Pokhriyal on 20/05/19.
//

import Foundation

extension ALKMessageViewModel {
    private func messageDetails() -> Message {
        return Message(
            text: message,
            isMyMessage: isMyMessage,
            time: time!,
            displayName: displayName,
            status: messageStatus(),
            imageURL: avatarURL
        )
    }

    func imageMessage() -> ImageMessage? {
        let payload = payloadFromMetadata()
        precondition(payload != nil, "Payload cannot be nil")
        guard let imageData = payload?[0], let url = imageData["url"] as? String else {
            assertionFailure("Payload must contain url.")
            return nil
        }
        return ImageMessage(
            caption: imageData["caption"] as? String,
            url: url,
            message: messageDetails()
        )
    }

    func faqMessage() -> FAQMessage? {
        guard
            let metadata = self.metadata,
            let payload = metadata["payload"] as? String,
            let json = try? JSONSerialization.jsonObject(with: payload.data, options: .allowFragments),
            let msg = json as? [String: Any]
        else { return nil }

        var buttons = [String]()

        if let btns = msg["buttons"] as? [[String: Any]] {
            btns.forEach {
                if let name = $0["name"] as? String {
                    buttons.append(name)
                }
            }
        }

        return FAQMessage(
            message: messageDetails(),
            title: msg["title"] as? String,
            description: msg["description"] as? String,
            buttonLabel: msg["buttonLabel"] as? String,
            buttons: buttons
        )
    }

    func messageStatus() -> MessageStatus {
        if isAllRead {
            return .read
        } else if isAllReceived {
            return .delivered
        } else if isSent {
            return .sent
        } else {
            return .pending
        }
    }

    func allButtons() -> SuggestedReplyMessage? {
        guard let payload = payloadFromMetadata() else { return nil }
        var buttons = [SuggestedReplyMessage.Suggestion]()
        for object in payload {
            guard let name = object["name"] as? String,
                let action = object["action"] as? [String: Any],
                let type = action["type"] as? String
            else { continue }
            var buttonType = SuggestedReplyMessage.SuggestionType.normal
            if type == "link" {
                buttonType = .link
            }
            buttons.append(SuggestedReplyMessage.Suggestion(title: name, type: buttonType))
        }
        return SuggestedReplyMessage(suggestion: buttons, message: messageDetails())
    }
}
