//
//  ALKTemplateMessageCell.swift
//  ApplozicSwift
//
//  Created by Mukesh Thawani on 27/12/17.
//

import UIKit

open class ALKTemplateMessageCell: UICollectionViewCell {

    open var textLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.textColor = UIColor.black
        label.contentMode = .center
        label.numberOfLines = 1
        label.font = Font.normal(size: 16.0).font()
        return label
    }()

    public let leftPadding: CGFloat = 5.0

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {

        self.layer.masksToBounds = true
        self.layer.cornerRadius = 10.0
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.gray.cgColor
        self.backgroundColor = UIColor.clear
        self.addViewsForAutolayout(views: [textLabel])

        textLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        textLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: leftPadding).isActive = true
        textLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        textLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }

    open func update(text: String) {
        textLabel.text = text
    }
}
