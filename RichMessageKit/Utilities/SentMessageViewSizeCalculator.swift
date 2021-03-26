//
//  SentMessageViewSizeCalculator.swift
//  RichMessageKit
//
//  Created by Shivam Pokhriyal on 26/01/19.
//

import Foundation
import UIKit

public class SentMessageViewSizeCalculator {
    public init() {}
    public func rowHeight(messageModel: Message, maxWidth: CGFloat, padding: Padding) -> CGFloat {
        let totalWidthPadding = padding.left + padding.right

        let messageWidth = maxWidth - totalWidthPadding

        let messageHeight = MessageView.rowHeight(model: messageModel,
                                                  maxWidth: messageWidth,
                                                  font: MessageTheme.sentMessage.message.font,
                                                  padding: MessageTheme.sentMessage.bubble.padding)

        return messageHeight + padding.top + padding.bottom
    }
}
