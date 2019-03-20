//
//  UIButton+Extension.swift
//  ApplozicSwift
//
//  Created by Shivam Pokhriyal on 19/03/19.
//

import MGSwipeTableCell

extension MGSwipeButton {

    func alignVertically(padding: CGFloat = 10.0) {
        guard let imageViewSize = self.imageView?.bounds.size else { return }
        self.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        self.imageEdgeInsets = UIEdgeInsets(
            top: -padding,
            left: (self.bounds.size.width - imageViewSize.width) / 2,
            bottom: padding,
            right: (self.bounds.size.width - imageViewSize.width) / 2
        )
        self.titleEdgeInsets = UIEdgeInsets(
            top: imageViewSize.height + padding,
            left: -imageViewSize.width,
            bottom: 0.0,
            right: 0.0
        )
    }

}
