//
//  ALKMessageCell.swift
//
//
//  Created by Mukesh Thawani on 04/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import Foundation
import UIKit

final class ALKInformationCell: UITableViewCell, Localizable {
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
                messageHeigh = (rect.height + 17 + 30)
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
            comment = dictionary["comments"]! as! String
        }

        if dictionary["rating"] != nil {
            contentView.subviews.forEach { subview in
                subview.removeFromSuperview()
            }
            rating = dictionary["rating"]! as! Int
        }
        
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = RatingHelper().getRatingIconFor(rating: rating)
        guard let attachedImage = imageAttachment.image else { return }
        imageAttachment.bounds = CGRect(x: 0, y: -5 , width: attachedImage.size.width, height: attachedImage.size.height)
        let imageString = NSAttributedString(attachment: imageAttachment)
        let userLabel = localizedString(forKey: "RatingLabelTitle", withDefaultValue: SystemMessage.Feedback.RatingLabelTitle, fileName: configuration.localizedStringFileName)
        let textString = NSMutableAttributedString(string: userLabel + " " + viewModel.message! + "  ")
        textString.append(imageString)
        messageView.attributedText = textString
        commentTextView.text = comment
        
        setUpConstraintsForRating()
        setupStyle()
    }

    fileprivate func setupConstraints() {
        contentView.addViewsForAutolayout(views: [messageView])
        contentView.bringSubviewToFront(messageView)

        messageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
        messageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8).isActive = true
        messageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        messageView.widthAnchor.constraint(lessThanOrEqualToConstant: 300).isActive = true
    }
    
    fileprivate func setUpConstraintsForRating() {
        
        let horizontalStackView = UIStackView()
        let verticalStackView = UIStackView()
        let lineViewLeft = UIView()
        let lineViewRight = UIView()
        
        verticalStackView.axis  = NSLayoutConstraint.Axis.vertical
        verticalStackView.distribution  = UIStackView.Distribution.equalSpacing
        verticalStackView.alignment = UIStackView.Alignment.center
        verticalStackView.spacing   = -5
        
        verticalStackView.addArrangedSubview(messageView)
        if !commentTextView.text.isEmpty {
            verticalStackView.addArrangedSubview(commentTextView)
        }
        
        horizontalStackView.axis  = NSLayoutConstraint.Axis.horizontal
        horizontalStackView.distribution  = UIStackView.Distribution.equalSpacing
        horizontalStackView.alignment = UIStackView.Alignment.center
        horizontalStackView.spacing   = 10

        horizontalStackView.addArrangedSubview(lineViewLeft)
        horizontalStackView.addArrangedSubview(verticalStackView)
        horizontalStackView.addArrangedSubview(lineViewRight)
        
        lineViewLeft.backgroundColor = .lightGray
        lineViewRight.backgroundColor = .lightGray
        
        contentView.addViewsForAutolayout(views: [horizontalStackView])
        contentView.bringSubviewToFront(messageView)
        
        horizontalStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        horizontalStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        
        lineViewLeft.widthAnchor.constraint(equalToConstant: 60).isActive = true
        lineViewRight.widthAnchor.constraint(equalToConstant: 60).isActive = true
        lineViewLeft.heightAnchor.constraint(equalToConstant: 1).isActive = true
        lineViewRight.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }

    func setupStyle() {
        contentView.backgroundColor = UIColor.clear
        backgroundColor = UIColor.clear
        
        messageView.setFont(ALKMessageStyle.infoMessage.font)
        messageView.textColor = ALKMessageStyle.infoMessage.text
    }
    
    func getFeedback(viewModel: ALKMessageViewModel) -> Dictionary<String,Any>? {
        guard let feedbackString = viewModel.metadata?["feedback"] as? String else { return nil }
        guard let dictionary = try? JSONSerialization.jsonObject(with: feedbackString.data(using: .utf8)!, options: []) as? [String:Any] else { return nil }
        return dictionary
    }
}
