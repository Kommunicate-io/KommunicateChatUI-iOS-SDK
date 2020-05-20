//
//  SentImageMessageViewSizeCalculator.swift
//  RichMessageKit
//
//  Created by Shivam Pokhriyal on 11/02/19.
//

import Foundation

class ImageMessageViewSizeCalculator {
    func rowHeight(model: ImageMessage, maxWidth: CGFloat) -> CGFloat {
        var messageViewPadding: Padding!
        var viewHeight: CGFloat = 0
        if model.message.isMyMessage {
            viewHeight = SentImageMessageCell.Config.TimeLabel.topPadding +
                SentImageMessageCell.Config.ImageBubbleView.topPadding
            if model.message.isMessageEmpty() {
                viewHeight += SentImageMessageCell.Config.MessageView.topPadding
            } else {
                messageViewPadding = Padding(
                    left: SentImageMessageCell.Config.MessageView.leftPadding,
                    right: SentImageMessageCell.Config.MessageView.rightPadding,
                    top: SentImageMessageCell.Config.MessageView.topPadding,
                    bottom: SentImageMessageCell.Config.MessageView.bottomPadding
                )
                viewHeight += SentMessageViewSizeCalculator().rowHeight(messageModel: model.message, maxWidth: maxWidth, padding: messageViewPadding)
            }
            viewHeight += model.message.time.rectWithConstrainedWidth(SentImageMessageCell.Config.TimeLabel.maxWidth, font: MessageTheme.sentMessage.time.font).height.rounded(.up)
        } else {
            viewHeight = ReceivedImageMessageCell.Config.DisplayName.topPadding + ReceivedImageMessageCell.Config.DisplayName.height +
                ReceivedImageMessageCell.Config.TimeLabel.topPadding +
                ReceivedImageMessageCell.Config.ImageBubbleView.topPadding
            if model.message.isMessageEmpty() {
                viewHeight += ReceivedImageMessageCell.Config.MessageView.topPadding
            } else {
                messageViewPadding = Padding(
                    left: ReceivedImageMessageCell.Config.MessageView.leftPadding,
                    right: ReceivedImageMessageCell.Config.MessageView.rightPadding,
                    top: ReceivedImageMessageCell.Config.MessageView.topPadding,
                    bottom: ReceivedImageMessageCell.Config.MessageView.bottomPadding
                )
                viewHeight += ReceivedMessageViewSizeCalculator().rowHeight(messageModel: model.message, maxWidth: maxWidth, padding: messageViewPadding)
            }
            viewHeight += model.message.time.rectWithConstrainedWidth(ReceivedImageMessageCell.Config.TimeLabel.maxWidth, font: MessageTheme.receivedMessage.time.font).height.rounded(.up)
        }

        let imageBubbleHeight = ImageBubbleSizeCalculator().rowHeight(model: model, maxWidth: maxWidth)
        return viewHeight + imageBubbleHeight
    }
}
