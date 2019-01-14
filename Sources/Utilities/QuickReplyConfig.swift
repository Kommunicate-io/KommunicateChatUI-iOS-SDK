//
//  QuickReplyConfig.swift
//  ApplozicSwift
//
//  Created by Shivam Pokhriyal on 09/01/19.
//
import Foundation

struct QuickReplyConfig {

    struct SentMessage {
        struct MessagePadding {
            static let left: CGFloat = 95
            static let right: CGFloat = 25
        }
        struct QuickReplyPadding {
            static let left: CGFloat = 75
            static let top: CGFloat = 10
            static let right: CGFloat = 25
        }
    }

    struct ReceivedMessage {
        struct MessagePadding {
            static let left: CGFloat = 0
            static let right: CGFloat = 95
            static let top: CGFloat = 4
        }
        struct QuickReplyPadding {
            static let left: CGFloat = 60
            static let top: CGFloat = 10
            static let right: CGFloat = 40
        }
    }
}
