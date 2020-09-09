//
//  ReceivedMessageViewSizeCalculator.swift
//  RichMessageKit
//
//  Created by Shivam Pokhriyal on 26/01/19.
//

import Foundation

class ReceivedMessageViewSizeCalculator {
    func rowHeight(messageModel: Message, maxWidth: CGFloat, padding: Padding) -> CGFloat {
        let totalWidthPadding = padding.left + padding.right

        let messageWidth = maxWidth - totalWidthPadding

        let messageHeight = MessageView.rowHeight(model: messageModel,
                                                  maxWidth: messageWidth,
                                                  font: MessageTheme.receivedMessage.message.font,
                                                  padding: MessageTheme.receivedMessage.bubble.padding)

        let totalHeightPadding = padding.top + padding.bottom
        let calculatedHeight = messageHeight + totalHeightPadding
        return calculatedHeight
    }
}
