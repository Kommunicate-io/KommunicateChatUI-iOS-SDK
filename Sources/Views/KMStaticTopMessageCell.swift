//
//  KMStaticTopMessageCell.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by sathyan elangovan on 18/04/23.
//

import Foundation
import UIKit

class KMStaticTopMessageCell: ALKMessageCell {
    
    enum ViewPadding {
        static let topSpacing = 35.0
        static let bottomSpacing = 35.0
        
        enum View {
            static let cornorRadius = 8.0
            static let leading = 16.0
            static let trailing = -16.0
            static let top = 16.0
            static let bottom = -16.0
        }
        
        enum ContentLabel {
            static let top = 16.0
            static let bottom = -16.0
            static let leading = 50.0
            static let trailing = -10.0
        }
        
        enum LeftIcon {
            static let leading = 16.0
            static let width = 24.0
            static let height = 24.0
        }
    }
   
    let contentLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = Font.normal(size: 15).font()
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    private var leftIcon: UIImageView = {
        let imv = UIImageView()
        imv.contentMode = .scaleAspectFill
        imv.clipsToBounds = true
        imv.image = KMConversationScreenConfiguration.staticTopIcon
        return imv
    }()
    
    let view: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor(hexString: "E7EAF2")
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupStyle()
        addConstraints()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addConstraints() {
        self.backgroundColor = .clear
        addViewsForAutolayout(views: [view])
        view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: ViewPadding.View.leading).isActive = true
        view.trailingAnchor.constraint(equalTo: trailingAnchor, constant: ViewPadding.View.trailing).isActive = true
        view.topAnchor.constraint(equalTo: topAnchor, constant: ViewPadding.View.top).isActive = true
        view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: ViewPadding.View.bottom).isActive = true
        view.addViewsForAutolayout(views: [contentLabel, leftIcon])
        view.layer.cornerRadius = ViewPadding.View.cornorRadius
        
        contentLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: ViewPadding.ContentLabel.leading).isActive = true
        contentLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: ViewPadding.ContentLabel.trailing).isActive = true
        contentLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: ViewPadding.ContentLabel.top).isActive = true
        leftIcon.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: ViewPadding.LeftIcon.leading).isActive = true
        leftIcon.widthAnchor.constraint(equalToConstant: ViewPadding.LeftIcon.width).isActive = true
        leftIcon.heightAnchor.constraint(equalToConstant: ViewPadding.LeftIcon.height).isActive = true
        leftIcon.topAnchor.constraint(equalTo: contentLabel.topAnchor).isActive = true
    }
    
    public static func rowHeight(model: ALKMessageModel, width: CGFloat) -> CGFloat {
        let height =  super.messageHeight(viewModel: model, width: width - 100, font: ALKMessageStyle.staticTopMessage.font, mentionStyle: ALKMessageStyle.receivedMention, displayNames: nil)
        return height + ViewPadding.topSpacing + ViewPadding.bottomSpacing
    }
    
    public func updateMessage(viewModel: ALKMessageViewModel) {
        contentLabel.text = viewModel.message
    }
    
    override func setupStyle() {
        let style = ALKMessageStyle.staticTopMessage
        contentLabel.textColor = style.text
        contentLabel.font = style.font
    }
}
