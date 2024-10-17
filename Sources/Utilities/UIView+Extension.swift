//
//  UIView+Extension.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by Mukesh Thawani on 04/05/17.
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

    func setBubbleStyle(_ style: ALKMessageStyle.Bubble, isReceiverSide: Bool) {
        layer.cornerRadius = style.cornerRadius
        tintColor = style.color
        if style.style == .round {
            layer.borderColor = style.border.color.cgColor
            layer.borderWidth = style.border.width
        }
        let appSettingsUserDefaults = ALKAppSettingsUserDefaults()
        backgroundColor = isReceiverSide ? appSettingsUserDefaults.getReceivedMessageBackgroundColor() : appSettingsUserDefaults.getSentMessageBackgroundColor()
    }
    
    func parentViewController() -> UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder?.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
