//
//  Tappable.swift
//  RichMessageKit
//
//  Created by Shivam Pokhriyal on 18/01/19.
//

public protocol Tappable: class {

    /// Called when the view is tapped
    ///
    /// - Parameters:
    ///   - index: Index passed to the view
    ///   - title: Text passed to the view
    func didTap(index: Int?, title: String)

}
