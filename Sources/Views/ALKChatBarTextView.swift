//
//  ALChatBarTextView.swift
//  ApplozicSwift
//
//  Created by Mukesh Thawani on 04/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import UIKit

open class ALKChatBarTextView: UITextView {
    
    weak var overrideNextResponder: UIResponder?
    
    override open var next: UIResponder? {
        get {
            if let overrideNextResponder = self.overrideNextResponder {
                return overrideNextResponder
            }
            
            return super.next
        }
        
    }
    
    override open func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if let _ = self.overrideNextResponder {
            return false
        }
        
        return super.canPerformAction(action, withSender: sender)
    }
}
