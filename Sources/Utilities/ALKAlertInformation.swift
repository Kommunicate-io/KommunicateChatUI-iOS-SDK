//
//  AlertInformation.swift
//  
//
//  Created by Mukesh Thawani on 04/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import Foundation


struct ALKAlertText {
    struct Title {
        static let Discard = "Discard change"
    }
    
    struct Message {
        static let Discard = "If you go back now, your change will be discarded"
    }
}

enum ALKAlertInformation {
    case discardChange
    
    var title: String {
        get {
            switch self {
            case .discardChange:
                return ALKAlertText.Title.Discard
            }
        }
    }
    
    var message: String {
        get {
            switch self {
            case .discardChange:
                return ALKAlertText.Message.Discard
            }
        }
    }
}
