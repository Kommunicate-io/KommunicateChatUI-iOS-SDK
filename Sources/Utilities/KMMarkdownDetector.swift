//
//  KMMarkdownDetector.swift
//  Pods
//
//  Created by Kommunicate on 18/02/26.
//

import UIKit

enum KMMarkdownDetector {
    static func containsMarkdown(_ text: String) -> Bool {
        let pattern = #"(\*\*|__|\*|_|~~|`|\[.*?\]\(.*?\)|^>\s|^\s*[-*+]\s)"#
        
        guard let regex = try? NSRegularExpression(
            pattern: pattern,
            options: [.anchorsMatchLines]
        ) else {
            return false
        }
        
        let range = NSRange(location: 0, length: text.utf16.count)
        return regex.firstMatch(in: text, options: [], range: range) != nil
    }
}


