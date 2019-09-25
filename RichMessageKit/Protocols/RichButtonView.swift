//
//  RichButtonView.swift
//  ApplozicSwift
//
//  Created by Shivam Pokhriyal on 25/09/19.
//

import UIKit

public protocol RichButtonView: UIView {
    func buttonWidth() -> CGFloat
    func buttonHeight() -> CGFloat
    static func buttonSize(text: String, maxWidth: CGFloat, font: UIFont) -> CGSize
}
