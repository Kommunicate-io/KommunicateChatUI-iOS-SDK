//
//  ViewInterface.swift
//  RichMessageKit
//
//  Created by Shivam Pokhriyal on 06/02/19.
//

import Foundation

public protocol ViewInterface {
    associatedtype type

    func update(model: type)

    static func rowHeight(model: type, maxWidth: CGFloat, font: UIFont, padding: Padding?) -> CGFloat
}
