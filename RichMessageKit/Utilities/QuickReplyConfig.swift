//
//  QuickReplyConfig.swift
//  ApplozicSwift
//
//  Created by Shivam Pokhriyal on 09/01/19.
//
import Foundation
import UIKit

public enum ChatCellPadding {
    public enum SentMessage {
        public enum Message {
            public static let left: CGFloat = 95
            public static let right: CGFloat = 10
        }

        public enum QuickReply {
            public static let left: CGFloat = 75
            public static let top: CGFloat = 5
            public static let right: CGFloat = 10
            public static let bottom: CGFloat = 5
        }

        public enum MessageButton {
            public static let left: CGFloat = 75
            public static let right: CGFloat = 10
            public static let top: CGFloat = 5
            public static let bottom: CGFloat = 5
        }
    }

    public enum ReceivedMessage {
        public enum Message {
            public static let left: CGFloat = 10
            public static let right: CGFloat = 95
            public static let top: CGFloat = 2
        }

        public enum QuickReply {
            public static let left: CGFloat = 5
            public static let top: CGFloat = 5
            public static let right: CGFloat = 10
            public static let bottom: CGFloat = 5
        }

        public enum MessageButton {
            public static let left: CGFloat = 60
            public static let right: CGFloat = 40
            public static let top: CGFloat = 5
            public static let bottom: CGFloat = 5
        }
    }
}
