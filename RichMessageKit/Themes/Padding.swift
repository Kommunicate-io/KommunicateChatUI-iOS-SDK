//
//  Padding.swift
//  RichMessageKit
//
//  Created by Shivam Pokhriyal on 18/01/19.
//

import Foundation
import UIKit

/// It is used to set padding for a view
public struct Padding {
    public let left: CGFloat
    public let right: CGFloat
    public let top: CGFloat
    public let bottom: CGFloat

    public init(left: CGFloat, right: CGFloat, top: CGFloat, bottom: CGFloat) {
        self.left = left
        self.right = right
        self.top = top
        self.bottom = bottom
    }
}
