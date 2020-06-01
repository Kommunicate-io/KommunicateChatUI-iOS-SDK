//
//  UIView+Extension.swift
//  RichMessageKit
//
//  Created by Shivam Pokhriyal on 18/01/19.
//

import UIKit

extension UIView {
    func addViewsForAutolayout(views: [UIView]) {
        for view in views {
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
        }
    }

    func constraint(withIdentifier: String) -> NSLayoutConstraint? {
        return constraints.filter { $0.identifier == withIdentifier }.first
    }
}
