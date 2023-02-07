//
//  UIApplication+Extension.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by sathyan elangovan on 07/02/23.
//

import Foundation

public extension UIApplication {
    static var main: UIApplication? { UIApplication.value(forKeyPath: #keyPath(UIApplication.shared)) as? UIApplication }
}
