
//
//  ALKMessageCell.swift
//  
//
//  Created by Mukesh Thawani on 04/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import Foundation
import UIKit

final class ALKInformationCell: UITableViewCell {
    
    fileprivate var messageView: UITextView = {
        let tv = UITextView()
        tv.setFont(font: .bold(size: 12.0))
        tv.isEditable = false
        tv.backgroundColor = .clear
        tv.isSelectable = false
        tv.setTextColor(color: .gray9B)
        tv.isScrollEnabled = false
        tv.isUserInteractionEnabled = false
        tv.textAlignment = .center
        return tv
    }()
    
    fileprivate var bubbleView: UIView = {
        let bv = UIView()
        bv.backgroundColor = UIColor.clear
        bv.layer.cornerRadius = 12
        bv.layer.borderColor = UIColor(netHex: 0xF3F3F3).cgColor
        bv.layer.borderWidth = 1.0
        bv.isUserInteractionEnabled = false
        return bv
    }()
    
    class func topPadding() -> CGFloat {
        return 8
    }
    
    class func bottomPadding() -> CGFloat {
        return 8
    }
    
    class func rowHeigh(viewModel: ALKMessageViewModel,width: CGFloat) -> CGFloat {
        
        let widthNoPadding: CGFloat = 300
        var messageHeigh: CGFloat = 0
        if let message = viewModel.message {
            
            let nomalizedMessage = message.replacingOccurrences(of: " ", with: "d")
            
            let rect = (nomalizedMessage as NSString).boundingRect(with: CGSize.init(width: widthNoPadding, height: CGFloat.greatestFiniteMagnitude),
                                                                   options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                                   attributes: [NSAttributedStringKey.font:UIFont.font(.bold(size: 12))],
                                                                   context: nil)
            messageHeigh = rect.height + 17
            
            messageHeigh = ceil(messageHeigh)
        }
        
        return topPadding()+messageHeigh+bottomPadding()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupConstraints()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate var viewModel: ALKMessageViewModel?
    
    func update(viewModel: ALKMessageViewModel) {
        
        self.viewModel = viewModel
        
        messageView.text = viewModel.message
    }
    
    fileprivate func setupConstraints() {
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        contentView.addViewsForAutolayout(views: [messageView,bubbleView])
        contentView.bringSubview(toFront: messageView)
        
        messageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
        messageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8).isActive = true
        messageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        messageView.widthAnchor.constraint(lessThanOrEqualToConstant: 300).isActive = true
        
        bubbleView.topAnchor.constraint(equalTo: messageView.topAnchor, constant: 3).isActive = true
        bubbleView.bottomAnchor.constraint(equalTo: messageView.bottomAnchor, constant: -3).isActive = true
        bubbleView.leftAnchor.constraint(equalTo: messageView.leftAnchor, constant: -4).isActive = true
        bubbleView.rightAnchor.constraint(equalTo: messageView.rightAnchor, constant: 4).isActive = true
        
    }
}

