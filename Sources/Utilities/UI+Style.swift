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
    
    func setBackgroundColor(color: Color.Background) {
        self.backgroundColor = .background(color)
    }
    
    func setTinColor(color: Color.Background) {
        self.tintColor = .background(color)
    }
}

extension UINavigationBar {
    
    func setBarTinColor(color: Color.Background) {
        self.barTintColor = .background(color)
    }
}

extension UITableView {
    
    func setSeparatorColor(color: Color.Border) {
        self.separatorColor = .border(color)
    }
}

extension CALayer {
    
    func setBorderColor(color: Color.Border) {
        self.borderColor = UIColor.border(color).cgColor
    }
    
    func setBackgroundColor(color: Color.Background) {
        self.backgroundColor = UIColor.background(color).cgColor
    }
}

extension UILabel {
    
    func setStyle(style: Style) {
        setFont(font: style.font)
        setTextColor(color: style.color)
        setBackgroundColor(color: style.background)
    }
    
    func setTextColor(color: Color.Text) {
        self.textColor = .color(color)
    }
    
    func setFont(font: Font) {
        self.font = .font(font)
    }
}

extension UITextView {
    
    func setStyle(style: Style) {
        setFont(font: style.font)
        setTextColor(color: style.color)
        setBackgroundColor(color: style.background)
    }
    
    func setTextColor(color: Color.Text) {
        self.textColor = .color(color)
    }
    
    func setFont(font: Font) {
        self.font = .font(font)
    }
}

extension UITextField {
    
    func setStyle(style: Style) {
        setFont(font: style.font)
        setTextColor(color: style.color)
        setBackgroundColor(color: style.background)
    }
    
    func setTextColor(color: Color.Text) {
        self.textColor = .color(color)
    }
    
    func setFont(font: Font) {
        self.font = .font(font)
    }
}

extension UIButton {
    
    func setStyle(style: Style, forState state: UIControlState) {
        setFont(font: style.font)
        setTextColor(color: style.color, forState: state)
        setBackgroundColor(color: style.background)
    }
    
    func setTextColor(color: Color.Text, forState state: UIControlState) {
        setTitleColor(.color(color), for: state)
    }
    
    func setFont(font: Font) {
        titleLabel?.font = .font(font)
    }
    
}
