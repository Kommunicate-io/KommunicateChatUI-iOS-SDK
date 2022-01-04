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
    var configuration = ALKConfiguration()

    fileprivate var messageView: UITextView = {
        let tv = UITextView()
        tv.isEditable = false
        tv.backgroundColor = .clear
        tv.isSelectable = false
        tv.isScrollEnabled = false
        tv.isUserInteractionEnabled = false
        tv.textAlignment = .center
        return tv
    }()
    
    fileprivate var commentTextView: UITextView = {
        let tv = UITextView()
        tv.isEditable = false
        tv.backgroundColor = .clear
        tv.isSelectable = false
        tv.isScrollEnabled = false
        tv.isUserInteractionEnabled = false
        tv.textAlignment = .center
        tv.textContainer.lineBreakMode = .byWordWrapping
        return tv
    }()

    func setConfiguration(configuration: ALKConfiguration) {
        self.configuration = configuration
    }

    class func topPadding() -> CGFloat {
        return 8
    }

    class func bottomPadding() -> CGFloat {
        return 8
    }

    class func rowHeigh(viewModel: ALKMessageViewModel, width _: CGFloat) -> CGFloat {
        let widthNoPadding: CGFloat = 300
        var messageHeigh: CGFloat = 0
        if let message = viewModel.message {
            let nomalizedMessage = message.replacingOccurrences(of: " ", with: "d")

            let rect = (nomalizedMessage as NSString).boundingRect(with: CGSize(width: widthNoPadding, height: CGFloat.greatestFiniteMagnitude),
                                                                   options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                                   attributes: [NSAttributedString.Key.font: ALKMessageStyle.infoMessage.font],
                                                                   context: nil)
            //get feedback dictionary for view
            guard let dictionary = ALKInformationCell().getFeedback(viewModel: viewModel) else { return 0 }
            if dictionary["comments"] != nil {
                messageHeigh = rect.height + 80
            } else {
                messageHeigh = rect.height + 17
            }
            messageHeigh = ceil(messageHeigh)
        }
        return topPadding() + messageHeigh + bottomPadding()
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupConstraints()
        setupStyle()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate var viewModel: ALKMessageViewModel?

    func update(viewModel: ALKMessageViewModel) {
        self.viewModel = viewModel
        
        guard let dictionary = getFeedback(viewModel: viewModel) else { return }
        var ratingImage = UIImage()
        var comment = ""
        var rating = 0
        
        if dictionary["comments"] != nil {
            contentView.subviews.forEach { subview in
                subview.removeFromSuperview()
            }
            setUpConstraintsForRating()
            setupStyle()
            comment = dictionary["comments"]! as! String
        }

        if dictionary["rating"] != nil {
            rating = dictionary["rating"]! as! Int
        }
        
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = Feedback().getRatingIconFor(rating: rating)
        guard let attachedImage = imageAttachment.image else { return }
        imageAttachment.bounds = CGRect(x: 0, y: -5 , width: attachedImage.size.width, height: attachedImage.size.height)
        let imageString = NSAttributedString(attachment: imageAttachment)
        let userLabel = localizedString(forKey: "RatingLabelTitle", withDefaultValue: SystemMessage.Feedback.ratingLabelTitle, fileName: configuration.localizedStringFileName)
        let textString = NSMutableAttributedString(string: userLabel + " " + viewModel.message! + "  ")
        textString.append(imageString)
        messageView.attributedText = textString
    }

    fileprivate func setupConstraints() {
        contentView.addViewsForAutolayout(views: [messageView, bubbleView])
        contentView.bringSubviewToFront(messageView)

        messageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
        messageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8).isActive = true
        messageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        messageView.widthAnchor.constraint(lessThanOrEqualToConstant: 300).isActive = true

        bubbleView.topAnchor.constraint(equalTo: messageView.topAnchor, constant: 3).isActive = true
        bubbleView.bottomAnchor.constraint(equalTo: messageView.bottomAnchor, constant: -3).isActive = true
        bubbleView.leftAnchor.constraint(equalTo: messageView.leftAnchor, constant: -4).isActive = true
        bubbleView.rightAnchor.constraint(equalTo: messageView.rightAnchor, constant: 4).isActive = true
    }
    
    fileprivate func setUpConstraintsForRating() {
        contentView.addViewsForAutolayout(views: [messageView, commentTextView])
        contentView.bringSubviewToFront(messageView)

        messageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
        messageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8).isActive = true
        messageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        messageView.widthAnchor.constraint(lessThanOrEqualToConstant: 300).isActive = true
        
        commentTextView.topAnchor.constraint(equalTo: messageView.topAnchor, constant: 15).isActive = true
        commentTextView.bottomAnchor.constraint(equalTo: messageView.bottomAnchor, constant: -8).isActive = true
        commentTextView.centerXAnchor.constraint(equalTo: messageView.centerXAnchor).isActive = true
        commentTextView.widthAnchor.constraint(lessThanOrEqualToConstant: 300).isActive = true
    }

    func setupStyle() {
        contentView.backgroundColor = UIColor.clear
        backgroundColor = UIColor.clear

        bubbleView.backgroundColor = ALKMessageStyle.infoMessage.background
        messageView.setFont(ALKMessageStyle.infoMessage.font)
        messageView.textColor = ALKMessageStyle.infoMessage.text
    }
    
    func getFeedback(viewModel: ALKMessageViewModel) -> Dictionary<String,Any>? {
        guard let feedbackString = viewModel.metadata?["feedback"] as? String else { return nil }
        guard let dictionary = try? JSONSerialization.jsonObject(with: feedbackString.data(using: .utf8)!, options: []) as? [String:Any] else { return nil }
        return dictionary
    }
}
