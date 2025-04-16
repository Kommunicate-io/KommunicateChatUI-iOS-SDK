//
//  KMFormConfiguration.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by Abhijeet Ranjan on 16/04/25.
//

import Foundation

/// A configuration structure for styling a form's appearance.
public struct KMFormConfiguration {

    /// The background color of the form.
    /// Uses a dynamic color that adapts to light and dark mode.
    public var formBackgroundColor: UIColor = UIColor.kmDynamicColor(
        light: .white,
        dark: UIColor.appBarDarkColor()
    )

    /// The border color of the form.
    /// Adapts to light and dark mode using dynamic color.
    public var formBorderColor: CGColor = UIColor.kmDynamicColor(
        light: UIColor(red: 230/255, green: 229/255, blue: 236/255, alpha: 1.0), // Light grey
        dark: UIColor.darkGray
    ).cgColor

    /// The width of the form's border.
    public var formBorderWidth: CGFloat = 1

    /// The radius of the shadow applied to the form.
    /// 0 means no shadow blur.
    public var formShadowRadius: CGFloat = 0

    /// The corner radius of the form.
    /// Controls how rounded the form corners appear.
    public var cornerRadius: CGFloat = 5

    /// The color of the shadow applied to the form.
    /// `clear` means the shadow is invisible by default.
    public var formShadowColor: CGColor = UIColor.clear.cgColor

    /// The opacity of the shadow.
    /// 0 means the shadow is fully transparent.
    public var formShadowOpacity: Float = 0
    
    /// The offset of the shadow applied to the form.
    /// Determines the horizontal and vertical displacement of the shadow.
    /// If this is `nil`, shadow will not be visible even if other shadow properties are set.
    public var formShadowOffset: CGSize?
}
