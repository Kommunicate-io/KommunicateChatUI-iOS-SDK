//
//  SentImageMessageViewSizeCalculator.swift
//  RichMessageKit
//
//  Created by Shivam Pokhriyal on 11/02/19.
//

import Foundation

class ImageMessageViewSizeCalculator {

    func rowHeight(model: MessageModel & ImageModel, maxWidth: CGFloat, padding: Padding) -> CGFloat {
        let messageViewPadding = Padding(left: padding.left,
                                         right: padding.right,
                                         top: padding.top,
                                         bottom: ImageMessageView.imageBubbleTopPadding)
        var messageViewHeight: CGFloat = 0
        if model.isMyMessage {
            messageViewHeight = SentMessageViewSizeCalculator().rowHeight(messageModel: model, maxWidth: maxWidth, padding: messageViewPadding)
        } else {
            messageViewHeight = ReceivedMessageViewSizeCalculator().rowHeight(messageModel: model, maxWidth: maxWidth, padding: messageViewPadding)
        }

        let imageBubbleHeight = ImageBubbleSizeCalculator().rowHeight(model: model, maxWidth: maxWidth)
        return messageViewHeight + imageBubbleHeight + padding.bottom // top will be already added in messageView
    }

}
