//
//  ALKRegexValidator.swift
//  ApplozicSwift
//
//  Created by Sunil on 07/10/20.
//

import Foundation

struct ALKRegexValidator {
    static func matchPattern(text: String, pattern: String) throws -> Bool {
        let range = NSRange(text.startIndex ..< text.endIndex, in: text)
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let matches = regex.numberOfMatches(in: text, options: [], range: range)
            print("Match for pattern found matches: \(matches)")
            return matches > 0
        } catch {
            throw error
        }
    }
}
