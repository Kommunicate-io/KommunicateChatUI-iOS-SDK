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
