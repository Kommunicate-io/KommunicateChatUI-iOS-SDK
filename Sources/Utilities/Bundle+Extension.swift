//
//  Bundle+Extension.swift
//  Pods
//
//  Created by Mukesh Thawani on 08/09/17.
//
//

import Foundation

extension Bundle {
    static var applozic: Bundle {
        #if SWIFT_PACKAGE
            return Bundle.module
        #else
            return Bundle(for: ALKConversationListViewController.self)
        #endif
    }
}
