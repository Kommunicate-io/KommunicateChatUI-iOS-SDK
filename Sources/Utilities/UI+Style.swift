//
//  UI+Style.swift
//  ApplozicSwift
//
//  Created by Mukesh Thawani on 04/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    func setBackgroundColor(_ color: UIColor) {
        self.backgroundColor = color
    }
    
    func setTintColor(_ color: UIColor) {
        self.tintColor = color
    }
}

extension UINavigationBar {
    
    func setBarTinColor(_ color: UIColor) {
        self.barTintColor = color
    }
}

extension UITableView {
    
    func setSeparatorColor(_ color: UIColor) {
        self.separatorColor = color
    }
}

extension CALayer {
    
    func setBorderColor(_ color: UIColor) {
        self.borderColor = color.cgColor
    }
    
    func setBackgroundColor(_ color: UIColor) {
        self.backgroundColor = color.cgColor
    }
}

extension UILabel {
    
    func setStyle(_ style: Style) {
        setFont(style.font)
        setTextColor(style.text)
        setBackgroundColor(style.background)
    }
    
    func setTextColor(_ color: UIColor) {
        self.textColor = color
    }
    
    func setFont(_ font: UIFont) {
        self.font = font
    }
}

extension UITextView {
    
    func setStyle(_ style: Style) {
        setFont(style.font)
        setTextColor(style.text)
        setBackgroundColor(style.background)
    }
    
    func setTextColor(_ color: UIColor) {
        self.textColor = color
    }
    
    func setFont(_ font: UIFont) {
        self.font = font
    }
}

extension UITextField {
    
    func setStyle(_ style: Style) {
        setFont(style.font)
        setTextColor(style.text)
        setBackgroundColor(style.background)
    }
    
    func setTextColor(_ color: UIColor) {
        self.textColor = color
    }
    
    func setFont(_ font: UIFont) {
        self.font = font
    }
}

extension UIButton {
    
    func setStyle(style: Style, forState state: UIControlState) {
        setFont(font: style.font)
        setTextColor(color: style.text, forState: state)
        setBackgroundColor(style.background)
    }
    
    func setTextColor(color: UIColor, forState state: UIControlState) {
        setTitleColor(color, for: state)
    }
    
    func setFont(font: UIFont) {
        titleLabel?.font = font
    }
    
}
