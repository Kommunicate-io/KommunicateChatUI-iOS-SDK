//
//  Data+Extension.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by Mukesh Thawani on 04/09/17.
//

import Foundation

extension Data {
    var attributedString: NSAttributedString? {
        do {
            return try NSAttributedString(
                data: self,
                options: [
                    NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html,
                    NSAttributedString.DocumentReadingOptionKey.characterEncoding: String.Encoding.utf8.rawValue
                ],
                documentAttributes: nil
            )
        } catch {
            print(error)
        }
        return nil
    }
}
