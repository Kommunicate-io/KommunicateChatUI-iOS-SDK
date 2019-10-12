//
//  UIView+Extension.swift
//  ApplozicSwift
//
//  Created by Mukesh Thawani on 04/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func setBottomBorderColor(color: UIColor, height: CGFloat) {
        let bottomBorderRect = CGRect(x: 0, y: frame.height, width: frame.width, height: height)
        let bottomBorderView = UIView(frame: bottomBorderRect)
        bottomBorderView.backgroundColor = color
        addSubview(bottomBorderView)
    }

    func constraint(withIdentifier: String) -> NSLayoutConstraint? {
        return constraints.filter { $0.identifier == withIdentifier }.first
    }

    func setBubbleStyle(_ style: ALKMessageStyle.Bubble) {
        layer.cornerRadius = style.cornerRadius
        tintColor = style.color
        backgroundColor = style.color
        layer.borderColor = style.border.color.cgColor
        layer.borderWidth = style.border.width
    }
}
