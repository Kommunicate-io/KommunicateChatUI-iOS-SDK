//
//  Message+Style.swift
//  ApplozicSwift
//
//  Created by Mukesh Thawani on 04/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import Foundation
public enum ALKMessageStyle {
    public static var displayName = Style(
        font: UIFont.font(.normal(size: 14)),
        text: .text(.gray9B)
    )

    public static var playTime = Style(
        font: UIFont.font(.normal(size: 16)),
        text: .text(.black00)
    )

    public static var time = Style(
        font: UIFont.font(.italic(size: 12)),
        text: .text(.grayCC)
    )

    // Received message text style
    public static var receivedMessage = Style(
        font: UIFont.font(.normal(size: 14)),
        text: .text(.black00)
    )

    // Sent message text style
    public static var sentMessage = Style(
        font: UIFont.font(.normal(size: 14)),
        text: .text(.black00)
    )

    /// Style for mentions in sent message text
    public static var sentMention = Style(
        font: UIFont.systemFont(ofSize: 14),
        text: UIColor.blue,
        background: UIColor.blue.withAlphaComponent(0.1)
    )

    /// Style for mentions in received message text
    public static var receivedMention = Style(
        font: UIFont.systemFont(ofSize: 14),
        text: UIColor.blue,
        background: UIColor.blue.withAlphaComponent(0.1)
    )

    /// Style for channel info messages in chat
    public static var infoMessage = Style(
        font: UIFont.font(.bold(size: 12.0)),
        text: UIColor.white,
        background: UIColor.gray
    )

    /// Style for date cell in chat
    public static var dateSeparator = Style(
        font: UIFont.font(.bold(size: 12.0)),
        text: UIColor.white,
        background: UIColor.gray
    )

    @available(*, deprecated, message: "Use `receivedMessage` and `sentMessage`")
    public static var message = Style(
        font: UIFont.font(.normal(size: 14)),
        text: .text(.black00)
    ) {
        didSet {
            receivedMessage = message
            sentMessage = message
        }
    }

    public enum BubbleStyle {
        case edge
        case round
    }

    public struct Bubble {
        enum DefaultColor {
            static let sentBubbleColor = UIColor(netHex: 0xF1F0F0)
            static let receivedBubbleColor = UIColor(netHex: 0xF1F0F0)
        }

        public struct Border {
            public var color = UIColor.clear
            public var width: CGFloat = 0
        }

        /// Message bubble's background color.
        public var color: UIColor

        /// Message bubble corner Radius
        public var cornerRadius: CGFloat

        /// BubbleStyle of the message bubble.
        public var style: BubbleStyle

        /// For setting border to bubble.
        /// Note: Only works when `BubbleStyle` is `round`
        public var border = Border()

        /// Width padding which will be used for message view's
        /// right and left padding.
        public let widthPadding: CGFloat

        public init(color: UIColor, style: BubbleStyle) {
            self.color = color
            self.style = style
            widthPadding = 10.0
            cornerRadius = 12
        }
    }

    public static var sentBubble = Bubble(color: UIColor(netHex: 0xF1F0F0), style: .edge) {
        didSet {
            let appSettingsUserDefaults = ALKAppSettingsUserDefaults()
            appSettingsUserDefaults.setSentMessageBackgroundColor(color: sentBubble.color)
        }
    }

    public static var receivedBubble = Bubble(color: UIColor(netHex: 0xF1F0F0), style: .edge) {
        didSet {
            let appSettingsUserDefaults = ALKAppSettingsUserDefaults()
            appSettingsUserDefaults.setReceivedMessageBackgroundColor(color: receivedBubble.color)
        }
    }

    /// Style for sent message status icon like read, delivered etc.
    public static var messageStatus = SentMessageStatus()
}
