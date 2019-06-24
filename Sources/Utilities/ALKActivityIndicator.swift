//
//  ALKActivityIndicator.swift
//  ApplozicSwift
//
//  Created by Shivam Pokhriyal on 21/06/19.
//

import UIKit

class ALKActivityIndicator: UIView {

    struct Size {
        let width: CGFloat
        let height: CGFloat
    }

    let size: Size

    fileprivate var indicator = UIActivityIndicatorView(style: .whiteLarge)

    init(frame: CGRect, backgroundColor: UIColor, indicatorColor: UIColor, size: Size) {
        self.size = size
        super.init(frame: frame)
        self.backgroundColor = backgroundColor
        indicator.color = indicatorColor
        setupView()
        self.isHidden = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func startAnimating() {
        self.isHidden = false
        indicator.startAnimating()
    }

    func stopAnimating() {
        self.isHidden = true
        indicator.stopAnimating()
    }

    private func setupView() {
        layer.cornerRadius = 10
        clipsToBounds = true

        addViewsForAutolayout(views: [indicator])
        bringSubviewToFront(indicator)

        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: centerYAnchor),
            indicator.widthAnchor.constraint(equalToConstant: size.width / 2),
            indicator.heightAnchor.constraint(equalToConstant: size.height / 2)
            ])
    }
}
