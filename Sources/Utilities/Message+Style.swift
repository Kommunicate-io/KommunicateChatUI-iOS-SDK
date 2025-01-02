//
//  Message+Style.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by Mukesh Thawani on 04/05/17.
//

import Foundation
import UIKit
#if canImport(RichMessageKit)
    import RichMessageKit
#endif
public enum ALKMessageStyle {
    private static let syncQueue = DispatchQueue(label: "com.kommunicate.ALKMessageStyle.syncQueue")

    private static var _displayName = Style(font: UIFont.font(.normal(size: 14)), text: .text(.gray9B))
    public static var displayName: Style {
        get { syncQueue.sync { _displayName } }
        set { syncQueue.sync { _displayName = newValue } }
    }

    private static var _playTime = Style(font: UIFont.font(.normal(size: 16)), text: .text(.black00))
    public static var playTime: Style {
        get { syncQueue.sync { _playTime } }
        set { syncQueue.sync { _playTime = newValue } }
    }

    private static var _time = Style(font: UIFont.font(.medium(size: 12)), text: UIColor(hexString: "67757E"))
    public static var time: Style {
        get { syncQueue.sync { _time } }
        set { syncQueue.sync { _time = newValue } }
    }

    private static var _receivedMessage = Style(font: UIFont.font(.normal(size: 14)), text: UIColor.kmDynamicColor(light: .text(.black00), dark: .text(.white)))
    public static var receivedMessage: Style {
        get { syncQueue.sync { _receivedMessage } }
        set { syncQueue.sync { _receivedMessage = newValue } }
    }

    private static var _sentMessage = Style(font: UIFont.font(.normal(size: 14)), text: .text(.white))
    public static var sentMessage: Style {
        get { syncQueue.sync { _sentMessage } }
        set { syncQueue.sync { _sentMessage = newValue } }
    }

    private static var _infoMessage = Style(font: UIFont.font(.bold(size: 12.0)), text: UIColor.white, background: UIColor.gray)
    public static var infoMessage: Style {
        get { syncQueue.sync { _infoMessage } }
        set { syncQueue.sync { _infoMessage = newValue } }
    }

    private static var _dateSeparator = Style(font: UIFont.font(.bold(size: 12.0)), text: UIColor.white, background: UIColor.gray)
    public static var dateSeparator: Style {
        get { syncQueue.sync { _dateSeparator } }
        set { syncQueue.sync { _dateSeparator = newValue } }
    }

    private static var _feedbackMessage = Style(font: UIFont.font(.normal(size: 12)), text: UIColor.gray, background: UIColor.gray)
    public static var feedbackMessage: Style {
        get { syncQueue.sync { _feedbackMessage } }
        set { syncQueue.sync { _feedbackMessage = newValue } }
    }

    private static var _assignmentMessage = Style(font: UIFont.font(.normal(size: 12)), text: UIColor.gray, background: UIColor.gray)
    public static var assignmentMessage: Style {
        get { syncQueue.sync { _assignmentMessage } }
        set { syncQueue.sync { _assignmentMessage = newValue } }
    }

    private static var _summaryMessage = Style(font: UIFont.font(.normal(size: 12.0)), text: UIColor.white, background: UIColor.gray)
    public static var summaryMessage: Style {
        get { syncQueue.sync { _summaryMessage } }
        set { syncQueue.sync { _summaryMessage = newValue } }
    }

    private static var _feedbackComment = Style(font: UIFont.font(.italic(size: 12)), text: UIColor.lightGray, background: UIColor.clear)
    public static var feedbackComment: Style {
        get { syncQueue.sync { _feedbackComment } }
        set { syncQueue.sync { _feedbackComment = newValue } }
    }

    private static var _staticTopMessage = Style(font: UIFont.font(.normal(size: 15.0)), text: UIColor.black)
    public static var staticTopMessage: Style {
        get { syncQueue.sync { _staticTopMessage } }
        set { syncQueue.sync { _staticTopMessage = newValue } }
    }

    private static var _receivedMention = Style(font: UIFont.systemFont(ofSize: 14), text: UIColor.blue, background: UIColor.blue.withAlphaComponent(0.1))
    public static var receivedMention: Style {
        get { syncQueue.sync { _receivedMention } }
        set { syncQueue.sync { _receivedMention = newValue } }
    }
    
    private static var _sentMention = Style(font: UIFont.systemFont(ofSize: 14), text: UIColor.blue, background: UIColor.blue.withAlphaComponent(0.1))
    public static var sentMention: Style {
        get { syncQueue.sync { _sentMention } }
        set { syncQueue.sync { _sentMention = newValue } }
    }
    
    public static var message: Style {
        get { syncQueue.sync { Style(font: UIFont.font(.normal(size: 14)), text: .text(.black00)) } }
        set {
            syncQueue.sync {
                _receivedMessage = newValue
                _sentMessage = newValue
            }
        }
    }

    public enum BubbleStyle {
        case edge
        case round
    }

    public struct Bubble {
        public struct Border {
            public var color = UIColor.clear
            public var width: CGFloat = 0
        }

        public var color: UIColor
        public var cornerRadius: CGFloat
        public var style: BubbleStyle
        public var border = Border()
        public let widthPadding: CGFloat = 10.0

        public init(color: UIColor, style: BubbleStyle) {
            self.color = color
            self.style = style
            self.cornerRadius = 12
        }
    }

    private static var _sentBubble: Bubble = Bubble(color: UIColor(netHex: 0x5553B7), style: .edge)
    public static var sentBubble: Bubble {
        get { syncQueue.sync { _sentBubble } }
        set {
            syncQueue.sync {
                _sentBubble = newValue
                let appSettingsUserDefaults = ALKAppSettingsUserDefaults()
                appSettingsUserDefaults.setSentMessageBackgroundColor(color: _sentBubble.color)
            }
        }
    }

    private static var _receivedBubble: Bubble = Bubble(color: UIColor.kmDynamicColor(light: UIColor(netHex: 0xF1F0F0), dark: UIColor.appBarDarkColor()), style: .edge)
    public static var receivedBubble: Bubble {
        get { syncQueue.sync { _receivedBubble } }
        set {
            syncQueue.sync {
                _receivedBubble = newValue
                let appSettingsUserDefaults = ALKAppSettingsUserDefaults()
                appSettingsUserDefaults.setReceivedMessageBackgroundColor(color: _receivedBubble.color)
            }
        }
    }

    public static var messageStatus = SentMessageStatus()
}
