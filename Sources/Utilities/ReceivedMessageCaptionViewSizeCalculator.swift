//
//  ReceivedMessageCaptionViewSizeCalculator.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by Abhijeet Ranjan on 14/10/24.
//

import Foundation
import UIKit

public class ReceivedMessageCaptionViewSizeCalculator {
    public init() {}

    func calculateCaptionHeight(text: String, font: UIFont, width: CGFloat) -> CGFloat {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping

        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .paragraphStyle: paragraphStyle
        ]
        
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        
        let boundingBox = text.boundingRect(
            with: constraintRect,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: attributes,
            context: nil
        )
        
        return ceil(boundingBox.height)
    }
    
    func rowHeight(captionArray: [String?], maxWidth: CGFloat, padding: Padding) -> CGFloat {
        let totalWidthPadding = padding.left + padding.right

        let messageWidth = maxWidth - totalWidthPadding
        var messageHeight = 0.0
        for caption in captionArray {
            if let caption = caption {
                if messageHeight > 0.0 {
                    messageHeight -= 15
                }
                messageHeight += (calculateCaptionHeight(text: caption, font: Font.bold(size: 12).font(), width: messageWidth))
            }
        }
        return messageHeight
    }
}

