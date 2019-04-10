//
//  MessageModel.swift
//  RichMessageKit
//
//  Created by Shivam Pokhriyal on 18/01/19.
//

import Foundation

/// Gives infomation about message status.
public enum MessageStatus {
    case pending
    case sent
    case delivered
    case read
}

/// It defines the properties that are used by cells to render views.
public protocol MessageModel {

    /// Text to be displayed as message.
    var message: String? { get }

    /// Indicates whether this method is at sender side or receiver side.
    ///
    /// Value For sender: 'true'. For receiver: 'false'.
    var isMyMessage: Bool { get }

    /// Time of message.
    var time: String { get }

    /// Display name of sender.
    ///
    /// - Important: Mandatory for received message.
    var displayName: String? { get }

    /// Status of message whether it is in pending/sent/delivered/read state.
    ///
    /// - Important: Mandatory for sent message.
    var status: MessageStatus? { get }

    /// Image url of sender.
    var imageURL: URL? { get }

    /// True, if current message is a reply to some other message.
    var isReplyMessage: Bool { get }

    /// This is the original message for which the current one is a reply.
    var originalMessage: MessageModel? { get }

    /// Metadata for message. It basically contains additional information if message is of differnet type.
    ///
    /// - Important: Pass json array as string in `payload` field.
    var metadata: Dictionary<String, Any>? { get }

}
