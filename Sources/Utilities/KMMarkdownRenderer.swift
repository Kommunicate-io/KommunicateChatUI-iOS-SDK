//
//  KMMarkdownRenderer.swift
//  Pods
//
//  Created by Kommunicate on 18/02/26.
//

import UIKit

enum KMMarkdownRenderer {
    static func attributedString(
        from text: String,
        baseFont: UIFont,
        baseAttributes: [NSAttributedString.Key: Any]
    ) -> NSAttributedString {
        if #available(iOS 15.0, *) {
            do {
                var attributed = try AttributedString(
                    markdown: text,
                    options: .init(
                        interpretedSyntax: .inlineOnlyPreservingWhitespace
                    )
                )
                attributed.font = baseFont
                return NSAttributedString(attributed)
            } catch {
                return NSAttributedString(
                    string: text,
                    attributes: baseAttributes
                )
            }
        } else {
            return NSAttributedString(
                string: text,
                attributes: baseAttributes
            )
        }
    }
}
