//
//  ALKMessageViewModel+Extension.swift
//  ApplozicSwift
//
//  Created by Shivam Pokhriyal on 20/05/19.
//

import Foundation

extension ALKMessageViewModel {

    func imageMessage() -> ImageMessage? {
        let payload = self.payloadFromMetadata()
        precondition(payload != nil, "Payload cannot be nil")
        guard let imageData = payload?[0], let url = imageData["url"] as? String else {
            assertionFailure("Payload must contain url.")
            return nil
        }
        let message = Message(
            text: self.message,
            isMyMessage: self.isMyMessage,
            time: self.time!,
            displayName: self.displayName,
            status: self.messageStatus(),
            imageURL: self.avatarURL)

        return ImageMessage(
            caption: imageData["caption"] as? String,
            url: url,
            message: message)
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
}
