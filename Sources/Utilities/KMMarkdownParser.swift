//
//  KMMarkdownParser.swift
//  Pods
//
//  Created by Kommunicate on 18/02/26.
//

import UIKit

struct KMMarkdownParser {
    static func attributedString(
        from text: String,
        font: UIFont,
        textColor: UIColor
    ) -> NSAttributedString {
        if #available(iOS 15.0, *) {
            do {
                var attributed = try AttributedString(
                    markdown: text,
                    options: AttributedString.MarkdownParsingOptions(
                        interpretedSyntax: .inlineOnlyPreservingWhitespace
                    )
                )

                attributed.font = font
                attributed.foregroundColor = textColor

                return NSAttributedString(attributed)
            } catch {
                return NSAttributedString(
                    string: text,
                    attributes: [
                        .font: font,
                        .foregroundColor: textColor
                    ]
                )
            }
        } else {
            return NSAttributedString(
                string: text,
                attributes: [
                    .font: font,
                    .foregroundColor: textColor
                ]
            )
        }
    }
}
