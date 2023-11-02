//
//  UIColor+ExtensionDarkMode.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by Abhijeet Ranjan on 19/10/23.
//

import Foundation

import UIKit

public extension UIColor {
    static func kmDynamicColor(light: UIColor, dark: UIColor) -> UIColor {
        return UIColor { $0.userInterfaceStyle == .dark ? light : light } /// disabled dark mode
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
