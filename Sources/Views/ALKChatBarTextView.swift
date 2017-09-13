//
//  ALChatBarTextView.swift
//  ApplozicSwift
//
//  Created by Mukesh Thawani on 04/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import UIKit

class ALKChatBarTextView: UITextView {
    
    weak var overrideNextResponder: UIResponder?
    
    override var next: UIResponder? {
        get {
            if let overrideNextResponder = self.overrideNextResponder {
                return overrideNextResponder
            }
            
            return super.next
        }
        
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if let _ = self.overrideNextResponder {
            return false
        }
        
        return super.canPerformAction(action, withSender: sender)
    }
}
