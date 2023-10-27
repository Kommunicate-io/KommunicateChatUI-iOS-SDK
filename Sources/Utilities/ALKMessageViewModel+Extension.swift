//
//  ALKMessageViewModel+Extension.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by Shivam Pokhriyal on 20/05/19.
//

import Foundation
import UIKit
import KommunicateCore_iOS_SDK
#if canImport(RichMessageKit)
    import RichMessageKit
#endif

extension ALKMessageViewModel {
    func messageDetails() -> Message {
        return Message(
            identifier: identifier,
            text: message,
            isMyMessage: isMyMessage,
            time: time!,
            displayName: fetchDisplayName(),
            status: messageStatus(),
            imageURL: avatarURL,
            contentType: contentType
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
    
    func fetchCustomBotName(userId: String) -> String? {
        guard let customBotId = ALApplozicSettings.getCustomizedBotId(),
              customBotId == userId,
              let customBotName = ALApplozicSettings.getCustomBotName()
        else { return nil }
        return customBotName
    }
    
    func fetchDisplayName() -> String? {
        guard let contactId = contactId, let customBotName = fetchCustomBotName(userId: contactId), !customBotName.isEmpty  else {
            return displayName
        }
        return customBotName
    }
    
    func faqMessage() -> FAQMessage? {
        guard
            let metadata = metadata,
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

    func messageStatus() -> ALKMessageStatus {
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
        let isActionButtonHidden = isActionButtonHidden()
        guard let payload = payloadFromMetadata() else { return nil }
        var buttons = [SuggestedReplyMessage.Suggestion]()
        for object in payload {
            guard let name = object["name"] as? String,
                  let action = object["action"] as? [String: Any],
                  let type = action["type"] as? String
            else { continue }
            
            if type == "link" {
                buttons.append(SuggestedReplyMessage.Suggestion(title: name, type: .link))
            } else if type == "submit" {
                buttons.append(SuggestedReplyMessage.Suggestion(title: name, type: .submit))
            } else if !isActionButtonHidden {
                buttons.append(SuggestedReplyMessage.Suggestion(title: name, type: .normal))
            }
        }
        return SuggestedReplyMessage(suggestion: buttons, message: messageDetails())
    }

    func suggestedReply() -> SuggestedReplyMessage? {
        let isActionButtonHidden = isActionButtonHidden()
        guard let payload = payloadFromMetadata() else { return nil }
        var buttons = [SuggestedReplyMessage.Suggestion]()
        if isActionButtonHidden {
            return SuggestedReplyMessage(suggestion: buttons, message: messageDetails())
        }
        for object in payload {
            guard let name = object["title"] as? String else { continue }
            let reply = object["message"] as? String
            buttons.append(SuggestedReplyMessage.Suggestion(title: name, reply: reply))
        }
        return SuggestedReplyMessage(suggestion: buttons, message: messageDetails())
    }

    func linkOrSubmitButton() -> SuggestedReplyMessage? {
        let isActionButtonHidden = isActionButtonHidden()
        guard let payload = payloadFromMetadata() else { return nil }
        var buttons = [SuggestedReplyMessage.Suggestion]()
        for object in payload {
            guard let name = object["name"] as? String else { continue }
            if let type = object["type"] as? String, type == "link" {
                buttons.append(SuggestedReplyMessage.Suggestion(title: name, type: .link))
            } else if let type = object["type"] as? String, type == "submit" {
                buttons.append(SuggestedReplyMessage.Suggestion(title: name, type: .submit))
            } else if !isActionButtonHidden {
                buttons.append(SuggestedReplyMessage.Suggestion(title: name))
            }
        }
        return SuggestedReplyMessage(suggestion: buttons, message: messageDetails())
    }

    func formTemplate() -> FormTemplate? {
        guard let payload = payloadFromMetadata() else { return nil }
        do {
            return try FormTemplate(payload: payload)
        } catch {
            print("Error while decoding form template: \(error.localizedDescription)")
            return nil
        }
    }
    
    func videoTemplate() -> [VideoTemplate]? {
        guard let payload = payloadFromMetadata() else { return nil }
        do {
            let json = try JSONSerialization.data(withJSONObject: payload)
            let videoTemplate = try JSONDecoder().decode([VideoTemplate].self, from: json)
            return videoTemplate
        } catch {
            print("Error while decoding video template \(error.localizedDescription)")
            return nil
        }
    }
    
    func isSuggestedReply() -> Bool {
        return self.messageType == .allButtons || self.messageType == .quickReply
    }
    
    func isActionButtonHidden() -> Bool {
        
        guard UserDefaults.standard.bool(forKey: SuggestedReplyView.hidePostCTA),
              self.messageType != .button else {
            return false
        }

        guard self.isSuggestedReply(),
              let currentMessageTime = self.createdAtTime,
              let lastSentMessageTime = ALKConversationViewModel.lastSentMessage?.createdAtTime,
              currentMessageTime .int64Value < lastSentMessageTime .int64Value else {
            return false
        }
        return true
    }
}
