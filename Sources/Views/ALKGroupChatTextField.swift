//
//  ALKGroupChatTextField.swift
//
//
//  Created by Mukesh Thawani on 04/05/17.
//

import UIKit

final class ALKGroupChatTextField: UITextField {
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        super.textRect(forBounds: bounds)
        return bounds.insetBy(dx: 14, dy: 9)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 14, dy: 9)
    }
}
