//
//  KMMultipleSelectionConfiguration.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by sathyan elangovan on 21/03/23.
//

import Foundation
import UIKit

public struct KMMultipleSelectionConfiguration {
    public static var shared = KMMultipleSelectionConfiguration()

    public var enableMultipleSelectionOnCheckbox: Bool = false
    /// Font for text inside view.
    public var normalfont: UIFont = Font.normal(size: 16).font()
    
    public var image : UIImage? =  UIImage(named: "checked", in: Bundle.km, compatibleWith: nil)
    
    public var backgroundColor: UIColor = UIColor.clear
    
    public var selectedBackgroundColor: UIColor = UIColor(hexString: "D4F3F8")
    
    public var selectedFont: UIFont = Font.bold(size: 15).font()
    
    public var cornorRadius: CGFloat = 7
    
    public var borderWidth: CGFloat = 2
    
    public var borderColor: UIColor = UIColor(hexString: "00A4BF")
    
    public var titleColor: UIColor = UIColor(hexString: "00A4BF")
    
    public var topPadding : CGFloat = 12
    
    public var bottomPadding: CGFloat = 12
    
}
