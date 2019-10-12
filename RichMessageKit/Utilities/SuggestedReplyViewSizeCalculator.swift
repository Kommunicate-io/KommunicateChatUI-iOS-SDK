//
//  QuickReplyViewSizeCalculator.swift
//  RichMessageKit
//
//  Created by Shivam Pokhriyal on 21/01/19.
//

import Foundation

class SuggestedReplyViewSizeCalculator {
    func rowHeight(model: SuggestedReplyMessage, maxWidth: CGFloat, font _: UIFont) -> CGFloat {
        var width: CGFloat = 0
        var totalHeight: CGFloat = 0
        var size = CGSize(width: 0, height: 0)
        var prevHeight: CGFloat = 0

        for suggestion in model.suggestion {
            let title = suggestion.title
            if suggestion.type == .link {
                let image = UIImage(named: "link", in: Bundle.richMessageKit, compatibleWith: nil)
                size = CurvedImageButton.buttonSize(text: title, image: image, maxWidth: maxWidth)
            } else {
                size = CurvedImageButton.buttonSize(text: title, maxWidth: maxWidth)
            }
            let currWidth = size.width
            if currWidth > maxWidth {
                totalHeight += size.height + prevHeight + 10 // 10 padding between buttons
                width = 0
                prevHeight = 0
                continue
            }
            if width + currWidth > maxWidth {
                totalHeight += prevHeight + 10 // 10 padding between buttons
                width = currWidth + 10
                prevHeight = size.height
            } else {
                width += currWidth + 10 // 10 padding between buttons
                prevHeight = size.height
            }
        }
        totalHeight += prevHeight
        return totalHeight
    }
}
