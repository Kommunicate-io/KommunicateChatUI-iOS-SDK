//
//  ReceivedMessageViewSizeCalculator.swift
//  RichMessageKit
//
//  Created by Shivam Pokhriyal on 26/01/19.
//

import Foundation

class ReceivedMessageViewSizeCalculator {
    func rowHeight(messageModel: Message, maxWidth: CGFloat, padding: Padding) -> CGFloat {
        let message = messageModel.text ?? ""

        let totalWidthPadding = padding.left + padding.right

        let messageWidth = maxWidth - totalWidthPadding
        let messageHeight = MessageViewSizeCalculator().rowHeight(
            text: message,
            font: MessageTheme.receivedMessage.message.font,
            maxWidth: messageWidth,
            padding: MessageTheme.receivedMessage.bubble.padding
        )

        let totalHeightPadding = padding.top + padding.bottom
        let calculatedHeight = messageHeight + totalHeightPadding
        return calculatedHeight
    }
}
