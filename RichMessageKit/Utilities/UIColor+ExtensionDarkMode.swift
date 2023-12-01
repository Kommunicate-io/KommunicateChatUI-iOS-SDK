//
//  UIColor+ExtensionDarkMode.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by Abhijeet Ranjan on 19/10/23.
//

import Foundation

import UIKit

public extension UIColor {
    static var isKMDarkModeEnabled = false
    
    static func kmDynamicColor(light: UIColor, dark: UIColor) -> UIColor {
        if self.isKMDarkModeEnabled {
            return UIColor { $0.userInterfaceStyle == .dark ? dark : light }
        } else {
            /// isDarkMode is not enabled in this condition the only light color is passed
            return UIColor { $0.userInterfaceStyle == .dark ? light : light }
        }
    }
    
    func toHexString() -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb = Int(r * 255) << 16 | Int(g * 255) << 8 | Int(b * 255) << 0
        return String(format: "%06x", rgb)
    }
}

extension UIApplication {
    var userInterfaceStyle: UIUserInterfaceStyle? {
        if let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0 is UIWindowScene }) as? UIWindowScene {
            return windowScene.traitCollection.userInterfaceStyle
        }
        return nil
    }
}
