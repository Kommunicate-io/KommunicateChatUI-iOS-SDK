//
//  QuickReplyConfig.swift
//  ApplozicSwift
//
//  Created by Shivam Pokhriyal on 09/01/19.
//
import Foundation

struct ChatCellPadding {
    struct SentMessage {
        struct Message {
            static let left: CGFloat = 95
            static let right: CGFloat = 10
        }

        struct QuickReply {
            static let left: CGFloat = 75
            static let top: CGFloat = 5
            static let right: CGFloat = 10
            static let bottom: CGFloat = 5
        }

        struct MessageButton {
            static let left: CGFloat = 75
            static let right: CGFloat = 10
            static let top: CGFloat = 5
            static let bottom: CGFloat = 5
        }
    }

    struct ReceivedMessage {
        struct Message {
            static let left: CGFloat = 10
            static let right: CGFloat = 95
            static let top: CGFloat = 2
        }

        struct QuickReply {
            static let left: CGFloat = 5
            static let top: CGFloat = 5
            static let right: CGFloat = 10
            static let bottom: CGFloat = 5
        }

        struct MessageButton {
            static let left: CGFloat = 60
            static let right: CGFloat = 40
            static let top: CGFloat = 5
            static let bottom: CGFloat = 5
        }
    }
}
