//
//  MessageViewSizeCalculator.swift
//  RichMessageKit
//
//  Created by Shivam Pokhriyal on 21/01/19.
//

import Foundation

class MessageViewSizeCalculator {
    func height(_ textView: UITextView,
                text: String,
                maxWidth: CGFloat,
                padding: Padding) -> CGFloat
    {
        textView.text = text
        let messageWidth = maxWidth - (padding.left + padding.right)
        let size = textView.sizeThatFits(CGSize(width: messageWidth, height: CGFloat.greatestFiniteMagnitude))
        return ceil(size.height) + padding.top + padding.bottom
    }

    func height(_ textView: UITextView,
                attributedText: NSAttributedString,
                maxWidth: CGFloat,
                padding: Padding) -> CGFloat
    {
        let messageWidth = maxWidth - (padding.left + padding.right)
        textView.attributedText = attributedText
        let size = textView.sizeThatFits(CGSize(width: messageWidth, height: CGFloat.greatestFiniteMagnitude))
        return ceil(size.height) + padding.top + padding.bottom
    }
}
