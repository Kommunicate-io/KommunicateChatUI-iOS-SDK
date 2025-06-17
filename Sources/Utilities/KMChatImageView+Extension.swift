//
//  KMChatImageView+Extension.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by Shivam Pokhriyal on 10/10/19.
//

import Foundation
import Kingfisher
import UIKit

extension KMChatImageView {
    func setStyle(_ bubbleStyle: KMChatMessageStyle.Bubble, isReceiverSide: Bool) {
        if bubbleStyle.style == .edge {
            let appSettingsUserDefaults = KMChatAppSettingsUserDefaults()
            tintColor = isReceiverSide ? appSettingsUserDefaults.getReceivedMessageBackgroundColor() : appSettingsUserDefaults.getSentMessageBackgroundColor()
            image = imageBubble(for: bubbleStyle.style, isReceiverSide: isReceiverSide, showHangOverImage: false)
        } else {
            super.setBubbleStyle(bubbleStyle, isReceiverSide: isReceiverSide)
        }
    }

    func imageBubble(for _: KMChatMessageStyle.BubbleStyle,
                     isReceiverSide: Bool,
                     showHangOverImage: Bool) -> UIImage? {
        var imageTitle = showHangOverImage ? "chat_bubble_red_hover" : "chat_bubble_red"
        // We can rotate the above image but loading the required
        // image would be faster and we already have both the images.
        if isReceiverSide { imageTitle = showHangOverImage ? "chat_bubble_grey_hover" : "chat_bubble_grey" }

        guard let bubbleImage = UIImage(named: imageTitle, in: Bundle.km, compatibleWith: nil)
        else { return nil }

        // This API is from the Kingfisher so instead of directly using
        // imageFlippedForRightToLeftLayoutDirection() we are using this as it handles
        // platform availability and future updates for us.
        let modifier = FlipsForRightToLeftLayoutDirectionImageModifier()
        return modifier.modify(bubbleImage)
    }
}
