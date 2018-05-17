//
//  Font.swift
//  ApplozicSwift
//
//  Created by Mukesh Thawani on 04/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import Foundation
import UIKit

public enum Font {
    
    case ultraLight(size: CGFloat)
    case ultraLightItalic(size: CGFloat)
    
    case thin(size: CGFloat)
    case thinItalic(size: CGFloat)
    
    case light(size: CGFloat)
    case lightItalic(size: CGFloat)
    
    case medium(size: CGFloat)
    case mediumItalic(size: CGFloat)
    
    case normal(size: CGFloat)
    case italic(size: CGFloat)
    
    case bold(size: CGFloat)
    case boldItalic(size: CGFloat)
    
    case condensedBlack(size: CGFloat)
    case condensedBold(size: CGFloat)
    
    func font() -> UIFont {
        
        var option: String = ""
        var fontSize: CGFloat = 0
        
        switch self {
        case .ultraLight(let size): option = "-UltraLight"
        fontSize = size
            
        case .ultraLightItalic(let size): option = "-UltraLightItalic"
        fontSize = size
            
        case .thin(let size): option = "-Thin"
        fontSize = size
            
        case .thinItalic(let size): option = "-ThinItalic"
        fontSize = size
            
        case .light(let size): option = "-Light"
        fontSize = size
            
        case .lightItalic(let size): option = "-LightItalic"
        fontSize = size
            
        case .medium(let size): option = "-Medium"
        fontSize = size
            
        case .mediumItalic(let size): option = "-MediumItalic"
        fontSize = size
            
        case .normal(let size): option = ""
        fontSize = size
            
        case .italic(let size): option = "-Italic"
        fontSize = size
            
        case .bold(let size): option = "-Bold"
        fontSize = size
            
        case .boldItalic(let size): option = "-BoldItalic"
        fontSize = size
            
        case .condensedBlack(let size): option = "-CondensedBlack"
        fontSize = size
            
        case .condensedBold(let size): option = "-CondensedBold"
        fontSize = size
        }
        
        return UIFont.init(name: "HelveticaNeue\(option)", size: CGFloat(fontSize)) ?? UIFont.systemFont(ofSize: fontSize)
    }
}

public enum Color {
    
    
    public enum Text: Int64 {
        
        case white  = 0xFFFFFFFF
        case main = 0xFFE00909
        case redC0  = 0xFFF7C0C0
        case grayCC = 0xFFCCCCCC
        case gray9B = 0xFF9B9B9B
        case grayC1 = 0xFFC1C1C1
        case gray66 = 0xFF666666
        case gray99 = 0xFF999999
        case blueFF = 0xFF007AFF
        case black00 = 0xFF000000
        case grayD4 = 0xC3CDD4
    }
    
    public enum Background: Int64 {
        
        case none   = 0x00FFFFFF
        case white  = 0xFFFFFFFF
        case main   = 0xFFE00909
        case redC0  = 0xFFF7C0C0
        case gray9B = 0xFF9B9B9B
        case grayF2 = 0xFFF2F2F2
        case grayEF = 0xFFEFEFEF
        case grayC1 = 0xFFC1C1C1
        case gray99 = 0xFF999999
        case grayEC = 0xFFECECEC
        case grayCC = 0xFFCCCCCC
        case gray66 = 0xFF666666
        case grayF1 = 0xFFF1F1F1
    }
    
    public enum Border: Int64 {
        
        case main = 0xFFE00909
        case redC0  = 0xFFF7C0C0
        
        case white  = 0xFFFFFFFF
        case black = 0xFF9000000
        
        case gray9B = 0xFF9B9B9B
        case grayF2 = 0xFFF2F2F2
        case grayEF = 0xFFEFEFEF
        case grayC1 = 0xFFC1C1C1
        case gray99 = 0xFF999999
        
    }
}

public struct Style {
    
    public let font: Font
    public let text: UIColor
    public let background: UIColor
    
    public init(font: Font, text: UIColor, background: UIColor) {
        self.font = font
        self.text = text
        self.background = background
    }
    
    public init(font: Font, text: UIColor) {
        self.font = font
        self.text = text
        self.background = .color(.none)
    }
    
}

extension UIFont {
    static func font(_ font: Font) -> UIFont {
        return font.font()
    }
}

extension UIColor {
    
    static func text(_ color: Color.Text) -> UIColor {
        return .hex8(color.rawValue)
    }
    
    static func background(_ color: Color.Background) -> UIColor {
        
        return .hex8(color.rawValue)
    }
    
    static func border(_ color: Color.Border) -> UIColor {
        
        return .hex8(color.rawValue)
    }
    
    static func color(_ color: Color.Text) -> UIColor {
        return .hex8(color.rawValue)
    }
    
    static func color(_ color: Color.Background) -> UIColor {
        
        return .hex8(color.rawValue)
    }
    
    static func color(_ color: Color.Border) -> UIColor {
        
        return .hex8(color.rawValue)
    }
}

