//
//  GenericCardsMessageView.swift
//  ApplozicSwift
//
//  Created by Shivam Pokhriyal on 03/12/18.
//

import Foundation
import Applozic
import Kingfisher

class GenericCardsMessageView: UIView {
    
    private var widthPadding: CGFloat = CGFloat(ALKMessageStyle.receivedBubble.widthPadding)
    
    fileprivate lazy var messageView: ALHyperLabel = {
        let label = ALHyperLabel.init(frame: .zero)
        label.isUserInteractionEnabled = true
        label.numberOfLines = 0
        return label
    }()
    
    fileprivate var timeLabel: UILabel = {
        let lb = UILabel()
        lb.isOpaque = true
        return lb
    }()
    
    public var bubbleView: UIImageView = {
        let bv = UIImageView()
        let image = UIImage.init(named: "chat_bubble_rounded", in: Bundle.applozic, compatibleWith: nil)
        bv.tintColor = UIColor(netHex: 0xF1F0F0)
        bv.image = image?.imageFlippedForRightToLeftLayoutDirection()
        bv.isUserInteractionEnabled = false
        bv.isOpaque = true
        return bv
    }()
    
    public var avatarImageView: UIImageView = {
        let imv = UIImageView()
        imv.contentMode = .scaleAspectFill
        imv.clipsToBounds = true
        let layer = imv.layer
        layer.cornerRadius = 18.5
        layer.masksToBounds = true
        imv.isUserInteractionEnabled = true
        return imv
    }()
    
    fileprivate var nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.isOpaque = true
        return label
    }()
    
    enum Padding {
        enum MessageView {
            static let top: CGFloat = 4
        }
    }
    
    init() {
        super.init(frame: CGRect.zero)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        
        self.addViewsForAutolayout(views: [avatarImageView, nameLabel, bubbleView, messageView, timeLabel])
        self.bringSubview(toFront: messageView)
        
        nameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 6).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 57).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -57).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: 16).isActive = true
        
        avatarImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 18).isActive = true
        avatarImageView.bottomAnchor.constraint(lessThanOrEqualTo: self.bottomAnchor, constant: 0).isActive = true
        
        avatarImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 9).isActive = true
        
        avatarImageView.trailingAnchor.constraint(equalTo: messageView.leadingAnchor, constant: -18).isActive = true
        
        avatarImageView.heightAnchor.constraint(equalToConstant: 37).isActive = true
        avatarImageView.widthAnchor.constraint(equalTo: avatarImageView.heightAnchor).isActive = true
        
        
        messageView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: Padding.MessageView.top).isActive = true
        messageView.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor).isActive = true
        
        messageView.bottomAnchor.constraint(lessThanOrEqualTo: self.bottomAnchor, constant: -2).isActive = true
        messageView.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 18).isActive = true
        
        
        bubbleView.topAnchor.constraint(equalTo: messageView.topAnchor, constant: -2).isActive = true
        bubbleView.bottomAnchor.constraint(equalTo: messageView.bottomAnchor, constant: 2).isActive = true
        
        bubbleView.leadingAnchor.constraint(equalTo: messageView.leadingAnchor, constant: -widthPadding).isActive = true
        bubbleView.trailingAnchor.constraint(equalTo: messageView.trailingAnchor, constant: widthPadding).isActive = true
        
        timeLabel.leadingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: 10).isActive = true
        timeLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: 2).isActive = true
    }
    
    func update(viewModel: ALKMessageViewModel) {
        
        let placeHolder = UIImage(named: "placeholder", in: Bundle.applozic, compatibleWith: nil)
        
        if let url = viewModel.avatarURL {
            let resource = ImageResource(downloadURL: url, cacheKey: url.absoluteString)
            self.avatarImageView.kf.setImage(with: resource, placeholder: placeHolder, options: nil, progressBlock: nil, completionHandler: nil)
        } else {
            self.avatarImageView.image = placeHolder
        }
        
        nameLabel.text = viewModel.displayName
        nameLabel.setStyle(ALKMessageStyle.displayName)
        messageView.text = viewModel.message ?? ""
        messageView.setStyle(ALKMessageStyle.message)
        timeLabel.text = viewModel.time
        timeLabel.setStyle(ALKMessageStyle.time)
    }
    
    class func rowHeigh(viewModel: ALKMessageViewModel,widthNoPadding: CGFloat) -> CGFloat {
        var messageHeigh: CGFloat = 0
        
        if let message = viewModel.message {
            let maxSize = CGSize.init(width: widthNoPadding, height: CGFloat.greatestFiniteMagnitude)
            
            let font = ALKMessageStyle.message.font
            let color = ALKMessageStyle.message.text
            
            let style = NSMutableParagraphStyle.init()
            style.lineBreakMode = .byWordWrapping
            style.headIndent = 0
            style.tailIndent = 0
            style.firstLineHeadIndent = 0
            style.minimumLineHeight = 17
            style.maximumLineHeight = 17
            
            let attributes: [NSAttributedStringKey: Any] = [
                NSAttributedStringKey.font: font,
                NSAttributedStringKey.foregroundColor: color]
            
            var size = CGSize()
            if viewModel.messageType == .html {
                guard let htmlText = message.data.attributedString else { return 30}
                let mutableText = NSMutableAttributedString(attributedString: htmlText)
                let attributes: [NSAttributedStringKey : Any] = [NSAttributedStringKey.paragraphStyle: style]
                mutableText.addAttributes(attributes, range: NSMakeRange(0,mutableText.length))
                size = mutableText.boundingRect(with: maxSize, options: [NSStringDrawingOptions.usesFontLeading, NSStringDrawingOptions.usesLineFragmentOrigin], context: nil).size
            } else {
                let attrbString = NSAttributedString(string: message,attributes: attributes)
                let framesetter = CTFramesetterCreateWithAttributedString(attrbString)
                size =  CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRange(location: 0,length: 0), nil, maxSize, nil)
            }
            messageHeigh = ceil(size.height) + 10
            return messageHeigh
        }
        return messageHeigh + 50
    }
}
