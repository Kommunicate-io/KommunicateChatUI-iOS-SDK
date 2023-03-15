//
//  UIApplication+Extension.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by sathyan elangovan on 07/02/23.
//

import Foundation
import UIKit

@available(iOSApplicationExtension, unavailable, message: "UIApplication.shared is unavailable in application extensions")
public extension UIApplication {
    #if !os(OSX) && !os(watchOS)
        static func sharedUIApplication() -> UIApplication? {
            guard let sharedApplication =
                    UIApplication.perform(NSSelectorFromString("sharedApplication"))?.takeUnretainedValue() as? UIApplication else {
                return nil
            }
            return sharedApplication
        }
    #endif
}
