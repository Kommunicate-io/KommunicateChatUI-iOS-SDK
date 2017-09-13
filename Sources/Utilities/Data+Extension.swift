//
//  Data+Extension.swift
//  ApplozicSwift
//
//  Created by Mukesh Thawani on 04/09/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import Foundation

extension Data {
    var attributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: self, options:[NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            print(error)
        }
        return nil
    }
}
