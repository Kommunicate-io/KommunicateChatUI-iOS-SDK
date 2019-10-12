//
//  CustomSearchBar.swift
//  Kommunicate Chat
//
//  Created by Shivam Pokhriyal on 02/07/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit

class CustomSearchBar: UIView {
    let searchBar: UISearchBar

    init(searchBar: UISearchBar) {
        self.searchBar = searchBar
        super.init(frame: CGRect(x: 0, y: 0, width: searchBar.frame.width, height: 44))
        backgroundColor = .clear
        self.searchBar.barTintColor = .white
        for view in searchBar.subviews[0].subviews {
            if let cancelButton = view as? UIButton {
                cancelButton.setTitleColor(.gray, for: .normal)
            }
        }
        addSubview(searchBar)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        searchBar.frame = bounds
    }

    func show(_ show: Bool) {
        alpha = show ? 1 : 0
        searchBar.alpha = show ? 1 : 0
    }

    @discardableResult
    override func becomeFirstResponder() -> Bool {
        searchBar.becomeFirstResponder()
        return super.becomeFirstResponder()
    }

    @discardableResult
    override func resignFirstResponder() -> Bool {
        searchBar.resignFirstResponder()
        return super.resignFirstResponder()
    }
}
