//
//  Bundle+Extension.swift
//  RichMessageKit
//
//  Created by Shivam Pokhriyal on 18/01/19.
//

import Foundation

extension Bundle {
    static var richMessageKit: Bundle {
        #if SWIFT_PACKAGE
            return Bundle.module
        #else
            return Bundle(for: SuggestedReplyView.self)
        #endif
    }
}
