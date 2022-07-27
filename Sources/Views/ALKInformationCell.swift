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
    
    enum Padding {
        
        enum view {
            static let top: CGFloat = 8
            static let bottom: CGFloat = 8
        }
        
        enum CommentView {
            static let height: CGFloat = 30
        }
        
        enum HorizontalStackView {
            static let spacing: CGFloat = 10
            static let leading: CGFloat = 10
            static let trailing: CGFloat = -10
        }

        enum VerticalStackView {
            static let spacing: CGFloat = -5
        }
        
        enum MessageView {
            static let top: CGFloat = 8
            static let bottom: CGFloat = -8
            static let width: CGFloat = 300
            static let height: CGFloat = 17
        }
        
        enum LineView {
            static let width: CGFloat = 60
            static let height: CGFloat = 1
        }
    }

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
    
    fileprivate var lineViewLeft : UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()
    
    fileprivate var lineViewRight : UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()

    func setConfiguration(configuration: ALKConfiguration) {
        self.configuration = configuration
    }

    class func topPadding() -> CGFloat {
        return Padding.view.top
    }

    class func bottomPadding() -> CGFloat {
        return Padding.view.bottom
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
            //  Get feedback dictionary for view
            if let dictionary = ALKInformationCell().getFeedback(viewModel: viewModel),dictionary["comments"] != nil  {
                messageHeigh = (rect.height + Padding.MessageView.height + Padding.CommentView.height)
            } else {
                messageHeigh = rect.height + Padding.MessageView.height
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
        guard let feedback = getFeedback(viewModel: viewModel) else {
            messageView.text = viewModel.message
            commentTextView.text = ""
            lineViewLeft.isHidden = true
            lineViewRight.isHidden = true
            setupConstraints()
            return
        }
        
        var comment = ""
        var rating = 0
        if feedback["comments"] != nil {
            contentView.subviews.forEach { subview in
                subview.removeFromSuperview()
            }
            comment = feedback["comments"]! as! String
        }
        
        if feedback["rating"] != nil {
            contentView.subviews.forEach { subview in
                subview.removeFromSuperview()
            }
            rating = feedback["rating"]! as! Int
        }
        
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = RatingHelper().getRatingIconFor(rating: rating)
        guard let attachedImage = imageAttachment.image else {
            let textString = getFormattedFeedbackString(viewModel)
            setupViews(feedbackString: textString, comment: comment)
            return
        }
        imageAttachment.bounds = CGRect(x: 0, y: -5 , width: attachedImage.size.width, height: attachedImage.size.height)
        let imageString = NSAttributedString(attachment: imageAttachment)
        let textString = getFormattedFeedbackString(viewModel)
        textString.append(imageString)
        setupViews(feedbackString: textString, comment: comment)
    }
    
    fileprivate func setupViews(feedbackString: NSMutableAttributedString, comment: String){
        messageView.attributedText = feedbackString
        if !comment.isEmpty {
            commentTextView.text = "“\(comment)”"
        }else{
            commentTextView.text = ""
        }
        setupStyle()
        setUpConstraintsForRating()
    }
    
    
    fileprivate func getFormattedFeedbackString(_ viewModel: ALKMessageViewModel) -> NSMutableAttributedString {
        let userLabel = localizedString(forKey: "RatingLabelTitle", withDefaultValue: SystemMessage.Feedback.RatingLabelTitle, fileName: configuration.localizedStringFileName)
        return NSMutableAttributedString(string: userLabel + " " + viewModel.message! + "  ")
    }

    fileprivate func setupConstraints() {
        contentView.addViewsForAutolayout(views: [messageView])
        contentView.bringSubviewToFront(messageView)

        messageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Padding.MessageView.top).isActive = true
        messageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: Padding.MessageView.bottom).isActive = true
        messageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        messageView.widthAnchor.constraint(lessThanOrEqualToConstant: Padding.MessageView.width).isActive = true
    }
    
    fileprivate func setUpConstraintsForRating() {

        let horizontalStackView = UIStackView()
        let verticalStackView = UIStackView()
       
        verticalStackView.axis  = NSLayoutConstraint.Axis.vertical
        verticalStackView.distribution  = UIStackView.Distribution.equalSpacing
        verticalStackView.alignment = UIStackView.Alignment.center
        verticalStackView.spacing = Padding.VerticalStackView.spacing
        
        verticalStackView.addArrangedSubview(messageView)
        if !commentTextView.text.isEmpty {
            verticalStackView.addArrangedSubview(commentTextView)
        } else {
            verticalStackView.removeArrangedSubview(commentTextView)
        }
        
        horizontalStackView.axis  = NSLayoutConstraint.Axis.horizontal
        horizontalStackView.distribution  = UIStackView.Distribution.equalSpacing
        horizontalStackView.alignment = UIStackView.Alignment.center
        horizontalStackView.spacing = Padding.HorizontalStackView.spacing
        lineViewLeft.isHidden = false
        lineViewRight.isHidden = false
        horizontalStackView.addArrangedSubview(lineViewLeft)
        horizontalStackView.addArrangedSubview(verticalStackView)
        horizontalStackView.addArrangedSubview(lineViewRight)
        
        lineViewLeft.backgroundColor = .lightGray
        lineViewRight.backgroundColor = .lightGray
        
        contentView.addViewsForAutolayout(views: [horizontalStackView])
        contentView.bringSubviewToFront(messageView)
        
        horizontalStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Padding.HorizontalStackView.leading).isActive = true
        horizontalStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: Padding.HorizontalStackView.trailing).isActive = true
        
        lineViewLeft.widthAnchor.constraint(equalToConstant: Padding.LineView.width).isActive = true
        lineViewRight.widthAnchor.constraint(equalToConstant: Padding.LineView.width).isActive = true
        lineViewLeft.heightAnchor.constraint(equalToConstant: Padding.LineView.height).isActive = true
        lineViewRight.heightAnchor.constraint(equalToConstant: Padding.LineView.height).isActive = true
    }

    func setupStyle() {
        contentView.backgroundColor = UIColor.clear
        backgroundColor = UIColor.clear
        
        messageView.setFont(ALKMessageStyle.infoMessage.font)
        messageView.textColor = ALKMessageStyle.infoMessage.text
        commentTextView.setFont(ALKMessageStyle.feedbackComment.font)
        commentTextView.textColor = ALKMessageStyle.feedbackComment.text
    }
    
    func getFeedback(viewModel: ALKMessageViewModel) -> Dictionary<String,Any>? {
        guard let feedbackString = viewModel.metadata?["feedback"] as? String else { return nil }
        guard let data = feedbackString.data(using: .utf8),
            let dictionary = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] else { return nil }
        return dictionary
    }
}
