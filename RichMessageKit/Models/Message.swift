//
//  MessageModel.swift
//  RichMessageKit
//
//  Created by Shivam Pokhriyal on 18/01/19.
//

import Foundation

/// Gives infomation about message status.
public enum ALKMessageStatus: CaseIterable {
    case pending
    case sent
    case delivered
    case read
}

/// It defines the properties that are used by cells to render views.
public struct Message {
    public enum ContentType: Int16 {
        case text = 0
        case attachment = 1
        case location = 2
        case html = 3
        case textUrl = 4
        case price = 5
        case contact = 7
        case audio = 8
        case video = 9
        case actionMessage = 10
    }

    public init(
        identifier: String,
        text: String?,
        isMyMessage: Bool,
        time: String,
        displayName: String?,
        status: ALKMessageStatus?,
        imageURL: URL?,
        contentType: Message.ContentType
    ) {
        self.identifier = identifier
        self.text = text
        self.isMyMessage = isMyMessage
        self.time = time
        self.displayName = displayName
        self.status = status
        self.imageURL = imageURL
        self.contentType = contentType
    }

    /// Identifier of the message
    public var identifier: String

    /// Text to be displayed as message.
    public var text: String?

    /// Indicates whether this method is at sender side or receiver side.
    ///
    /// Value For sender: 'true'. For receiver: 'false'.
    public var isMyMessage: Bool

    /// Time of message.
    public var time: String

    /// Display name of sender.
    ///
    /// - Important: Mandatory for received message.
    public var displayName: String?

    /// Status of message whether it is in pending/sent/delivered/read state.
    ///
    /// - Important: Mandatory for sent message.
    public var status: ALKMessageStatus?

    /// Image url of sender.
    public var imageURL: URL?

    /// To check if the message is empty
    func isMessageEmpty() -> Bool {
        guard let message = text, !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return true
        }
        return false
    }

    /// Content type of the message.
    public var contentType: Message.ContentType
}
