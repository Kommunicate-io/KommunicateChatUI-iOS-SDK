//
//  TypingNoticeView.swift
//  ApplozicSwift
//
//  Created by Mukesh Thawani on 04/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import UIKit

class TypingNotice: UIView {
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    private var lblName: UILabel = {
        let name = UILabel.init(frame: .zero)
        name.font =  UIFont(name: "HelveticaNeue-Italic", size: 12)
        name.textColor = UIColor.lightGray
        name.text = ""
        return name
    }()
    
    private var lblIsTyping:UILabel = {
        
        let isTypingString = NSLocalizedString("IsTyping", value: SystemMessage.Message.isTyping, comment: "")
        let isTypingWidth:CGFloat = isTypingString.evaluateStringWidth(textToEvaluate:isTypingString, fontSize: 12)
        
        let lblIsTyping = UILabel.init(frame: .zero)

        lblIsTyping.font =  UIFont(name: "HelveticaNeue-Italic", size: 12)!
        lblIsTyping.textColor = UIColor.lightGray
        lblIsTyping.text = isTypingString
        return lblIsTyping
        
    }()
    
    private var imgAnimate:UIImageView = {
        
        var animationImages = [UIImage]()
        for index in 0...31 {
            var numStr = ""
            if(index < 10)
            {
                numStr = "0"
            }
            
            if let img = UIImage(named: "animate-typing00\(numStr)\(index)", in: Bundle.applozic, compatibleWith: nil)
            {
                animationImages.append(img)
            }
        }
        
        let imgAnimate = UIImageView.init(frame: .zero)
        imgAnimate.contentMode = .scaleAspectFit
        imgAnimate.animationImages = animationImages;
        imgAnimate.animationDuration = TimeInterval(1.3);
        imgAnimate.animationRepeatCount = 0
        imgAnimate.startAnimating()
        return imgAnimate
        
    }()
    
    init() {
        super.init(frame: .zero)
        createUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createUI()
    {


        self.clipsToBounds = false
        self.backgroundColor = UIColor.white
        
        self.addViewsForAutolayout(views: [lblName,lblIsTyping,imgAnimate])
        
        lblName.topAnchor.constraint(equalTo: topAnchor).isActive = true
        lblName.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        lblName.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        
        lblIsTyping.topAnchor.constraint(equalTo: topAnchor).isActive = true
        lblIsTyping.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        lblIsTyping.leadingAnchor.constraint(equalTo: lblName.trailingAnchor).isActive = true
        lblIsTyping.widthAnchor.constraint(greaterThanOrEqualToConstant: 56).isActive = true
        
        imgAnimate.topAnchor.constraint(equalTo: topAnchor).isActive = true
        imgAnimate.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        imgAnimate.leadingAnchor.constraint(equalTo: lblIsTyping.trailingAnchor).isActive = true
        imgAnimate.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: 0).isActive = true
        imgAnimate.widthAnchor.constraint(equalToConstant: 44).isActive = true
        
    }
    
    func setDisplayName(displayName:String)
    {
        if(!displayName.isEmpty)
        {
            lblName.text = " " + displayName
            lblIsTyping.text = NSLocalizedString("IsTyping", value: SystemMessage.Message.isTyping, comment: "")
        }
        if UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft {
            lblIsTyping.text = NSLocalizedString("IsTypingForRTL",value: SystemMessage.Message.isTypingForRTL, comment: "")
        }
    }

    func setDisplayGroupTyping(number:Int)
    {
        if( number > 1)
        {
            lblName.text = "\(number) people"
            lblIsTyping.text = NSLocalizedString("AreTyping", value: SystemMessage.Message.areTyping, comment: "")
        }
    }
}
