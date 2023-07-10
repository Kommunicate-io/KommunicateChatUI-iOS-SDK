//
//  ALKTemplateMessageCell.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by Mukesh Thawani on 27/12/17.
//

import UIKit

open class ALKTemplateMessageCell: UICollectionViewCell {
    // ALKTemplateMessageCell Can be customized via this.
    public enum Style {
        public static var borderColor : UIColor = UIColor.blue
        public static var textColor: UIColor = UIColor.black
        public static var cornorRadious: CGFloat = 10.0
        public static var textSize: CGFloat = 16.0
        public static var borderWidth: CGFloat = 1.0
        public static var backgroundColor: UIColor = UIColor.clear
    }
    
    open var textLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.textColor = Style.textColor
        label.contentMode = .center
        label.numberOfLines = 1
        label.font = Font.normal(size: Style.textSize).font()
        return label
    }()
    
    public let leftPadding: CGFloat = 5.0

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        layer.masksToBounds = true
        layer.cornerRadius = Style.cornorRadious
        layer.borderWidth = Style.borderWidth
        layer.borderColor = Style.borderColor.cgColor
        backgroundColor = Style.backgroundColor
        addViewsForAutolayout(views: [textLabel])

        textLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        textLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: leftPadding).isActive = true
        textLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        textLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }

    open func update(text: String) {
        textLabel.text = text
    }
}
