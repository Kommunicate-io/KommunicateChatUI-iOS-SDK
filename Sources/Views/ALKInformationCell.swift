//
//  ALKMessageCell.swift
//
//
//  Created by Mukesh Thawani on 04/05/17.
//

import Foundation
import UIKit
import KommunicateCore_iOS_SDK

final class ALKInformationCell: UITableViewCell, Localizable {
    var configuration = ALKConfiguration()
    
    enum Padding {
        
        enum View {
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
    
    fileprivate var summaryUILable: UILabel = {
        let lbl = UILabel()
        lbl.font = .boldSystemFont(ofSize: 14)
        lbl.textColor = .black
        lbl.numberOfLines = 0
        return lbl
    }()
    
    fileprivate var summaryMessageView: UITextView = {
        let tv = UITextView()
        tv.isEditable = false
        tv.backgroundColor = .clear
        tv.isSelectable = false
        tv.isScrollEnabled = false
        tv.isUserInteractionEnabled = false
        tv.textAlignment = .left
        return tv
    }()
    
    fileprivate var summaryBubbleView: UIView = {
        let bv = UIView()
        bv.backgroundColor = UIColor(netHex: 0xEFEFEF)
        bv.layer.cornerRadius = 12
        bv.isUserInteractionEnabled = false
        return bv
    }()
    
    fileprivate var summaryReadMoreButton: KMExtendedTouchAreaButton = {
        let btn = KMExtendedTouchAreaButton()
        btn.extraTouchArea = UIEdgeInsets(top: -20, left: -20, bottom: -10, right: -20)
        btn.backgroundColor = .clear
        btn.isUserInteractionEnabled = true
        return btn
    }()

    fileprivate var summaryMessage = ""
    
    fileprivate var assignTextView: UITextView = {
        let tv = UITextView()
        tv.isEditable = false
        tv.backgroundColor = .clear
        tv.isSelectable = false
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
    
    fileprivate var lineViewLeft: UIView = {
        let view = UIView()
        return view
    }()
    
    fileprivate var lineViewRight: UIView = {
        let view = UIView()
        return view
    }()

    func setConfiguration(configuration: ALKConfiguration) {
        self.configuration = configuration
    }

    class func topPadding() -> CGFloat {
        return Padding.View.top
    }

    class func bottomPadding() -> CGFloat {
        return Padding.View.bottom
    }

    class func rowHeigh(viewModel: ALKMessageViewModel, width _: CGFloat) -> CGFloat {
        if ALApplozicSettings.isAgentAppConfigurationEnabled(),
           let metadata = viewModel.metadata,
           let summaryValue = metadata["KM_SUMMARY"] as? String,
           summaryValue == "true" {
            return 150
        }
        let widthNoPadding: CGFloat = 300
        var messageHeigh: CGFloat = 0
        if let message = viewModel.message {
            let nomalizedMessage = message.replacingOccurrences(of: " ", with: "d")

            let rect = (nomalizedMessage as NSString).boundingRect(with: CGSize(width: widthNoPadding, height: CGFloat.greatestFiniteMagnitude),
                                                                   options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                                   attributes: [NSAttributedString.Key.font: ALKMessageStyle.infoMessage.font],
                                                                   context: nil)
            //  Get feedback dictionary for view
            if let dictionary = ALKInformationCell().getFeedback(viewModel: viewModel), dictionary["comments"] != nil {
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
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate var viewModel: ALKMessageViewModel?

    func update(viewModel: ALKMessageViewModel) {
        self.viewModel = viewModel
        guard let feedback = getFeedback(viewModel: viewModel) else {
            if !ALApplozicSettings.isAgentAppConfigurationEnabled() {
                let assignmentTitle = localizedString(forKey: "AssignedLabel", withDefaultValue: SystemMessage.AssignedInfo.AssignedLabel, fileName: configuration.localizedStringFileName)
                let message = viewModel.message?.replacingOccurrences(of: "Assigned to", with: assignmentTitle, options: .literal, range: nil)
                assignTextView.text = message
                bubbleView.isHidden = true
                messageView.text = ""
                commentTextView.text = ""
                setupConstraintsForAssignedTo()
            } else {
                if let metadata = viewModel.metadata,
                   let summaryValue = metadata["KM_SUMMARY"] as? String,
                   summaryValue == "true", let summary = viewModel.message {
                    hideSummaryView(isHidden: false)
                    setupSummaryUILableText()
                    setSummaryMessageText(summary, characterLimit: 70)
                    lineViewLeft.isHidden = true
                    lineViewRight.isHidden = true
                    summaryReadMoreButton.addTarget(self, action: #selector(readMoreButtonTapped), for: .touchUpInside)
                    summaryMessage = summary
                    setupSummaryConstraints()
                } else {
                    hideSummaryView(isHidden: true)
                    messageView.text = viewModel.message
                    commentTextView.text = ""
                    lineViewLeft.isHidden = true
                    lineViewRight.isHidden = true
                    setupConstraints()
                }
            }
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
        let userDefaults = UserDefaults(suiteName: "group.kommunicate.sdk") ?? .standard
        let csatBaseValue = userDefaults.integer(forKey: "CSAT_RATTING_BASE")
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = csatBaseValue == 5 ? RatingHelper().getRatingIconForFiveStar(rating: rating) : RatingHelper().getRatingIconFor(rating: rating)
        guard let attachedImage = imageAttachment.image else {
            let textString = getFormattedFeedbackString(viewModel)
            setupViews(feedbackString: textString, comment: comment)
            return
        }
        imageAttachment.bounds = CGRect(x: 0, y: -5, width: attachedImage.size.width, height: attachedImage.size.height)
        let imageString = NSAttributedString(attachment: imageAttachment)
        let textString = getFormattedFeedbackString(viewModel)
        textString.append(imageString)
        setupViews(feedbackString: csatBaseValue == 5 ?  NSMutableAttributedString(attributedString: imageString) : textString, comment: comment)
    }
    
    func hideSummaryView(isHidden: Bool) {
        summaryUILable.isHidden = isHidden
        summaryBubbleView.isHidden = isHidden
        summaryMessageView.isHidden = isHidden
        summaryReadMoreButton.isHidden = isHidden
    }
    
    fileprivate func setupViews(feedbackString: NSMutableAttributedString, comment: String) {
        messageView.attributedText = feedbackString
        if !comment.isEmpty {
            commentTextView.text = "“\(comment)”"
        } else {
            commentTextView.text = ""
        }
        setupStyle()
        setUpConstraintsForRating()
    }
    
    fileprivate func setupSummaryUILableText() {
        summaryUILable.text = localizedString(forKey: "SummaryInfoLabel", withDefaultValue: SystemMessage.SummaryUI.SummaryInfoLabel, fileName: configuration.localizedStringFileName)
        let title = localizedString(forKey: "SummaryReadMoreLabel", withDefaultValue: SystemMessage.SummaryUI.SummaryReadMoreLabel, fileName: configuration.localizedStringFileName)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14, weight: .medium),
            .foregroundColor: UIColor.black,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        let attributedTitle = NSAttributedString(string: title, attributes: attributes)
        summaryReadMoreButton.setAttributedTitle(attributedTitle, for: .normal)
    }
    
    fileprivate func getFormattedFeedbackString(_ viewModel: ALKMessageViewModel) -> NSMutableAttributedString {
        let userLabel = localizedString(forKey: "RatingLabelTitle", withDefaultValue: SystemMessage.Feedback.RatingLabelTitle, fileName: configuration.localizedStringFileName)
        return NSMutableAttributedString(string: userLabel + " " + viewModel.message! + "  ")
    }

    fileprivate func setupConstraints() {
        contentView.addViewsForAutolayout(views: [messageView, bubbleView])
        contentView.bringSubviewToFront(messageView)

        messageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Padding.MessageView.top).isActive = true
        messageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: Padding.MessageView.bottom).isActive = true
        messageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        messageView.widthAnchor.constraint(lessThanOrEqualToConstant: Padding.MessageView.width).isActive = true
      
        bubbleView.topAnchor.constraint(equalTo: messageView.topAnchor, constant: 3).isActive = true
        bubbleView.bottomAnchor.constraint(equalTo: messageView.bottomAnchor, constant: -3).isActive = true
        bubbleView.leftAnchor.constraint(equalTo: messageView.leftAnchor, constant: -4).isActive = true
        bubbleView.rightAnchor.constraint(equalTo: messageView.rightAnchor, constant: 4).isActive = true
        
        bubbleView.backgroundColor = ALKMessageStyle.infoMessage.background
        messageView.setFont(ALKMessageStyle.infoMessage.font)
        contentView.backgroundColor = UIColor.clear
        backgroundColor = UIColor.clear
    }
    
    fileprivate func setupSummaryConstraints() {
        contentView.addViewsForAutolayout(views: [summaryBubbleView, summaryUILable, summaryMessageView, summaryReadMoreButton])

        summaryBubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        summaryBubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
        summaryBubbleView.leftAnchor.constraint(equalTo: messageView.leftAnchor, constant: -5).isActive = true
        summaryBubbleView.rightAnchor.constraint(equalTo: messageView.rightAnchor, constant: 5).isActive = true

        summaryUILable.topAnchor.constraint(equalTo: summaryBubbleView.topAnchor, constant: 10).isActive = true
        summaryUILable.centerXAnchor.constraint(equalTo: summaryBubbleView.centerXAnchor).isActive = true
        summaryUILable.widthAnchor.constraint(lessThanOrEqualTo: summaryBubbleView.widthAnchor, constant: -10).isActive = true
        
        summaryMessageView.topAnchor.constraint(equalTo: summaryUILable.bottomAnchor, constant: Padding.MessageView.top).isActive = true
        summaryMessageView.leadingAnchor.constraint(equalTo: summaryBubbleView.leadingAnchor, constant: 10).isActive = true
        summaryMessageView.trailingAnchor.constraint(equalTo: summaryBubbleView.trailingAnchor, constant: -5).isActive = true
        summaryMessageView.heightAnchor.constraint(equalToConstant: 45).isActive = true

        summaryReadMoreButton.topAnchor.constraint(equalTo: summaryMessageView.bottomAnchor).isActive = true
        summaryReadMoreButton.centerXAnchor.constraint(equalTo: summaryBubbleView.centerXAnchor).isActive = true
        summaryReadMoreButton.bottomAnchor.constraint(equalTo: summaryBubbleView.bottomAnchor, constant: -10).isActive = true

        summaryMessageView.font = ALKMessageStyle.summaryMessage.font
        contentView.backgroundColor = .clear
        backgroundColor = .clear
    }

    func setSummaryMessageText(_ text: String, characterLimit: Int = 30) {
        if text.count > characterLimit {
            let truncatedText = String(text.prefix(characterLimit)) + "..."
            summaryMessageView.text = truncatedText
        } else {
            summaryMessageView.text = text
        }
    }
    
    @objc func readMoreButtonTapped() {
        if let parentVC = self.parentViewController() {
            let popupVC = KMTextViewPopUPVC()
            popupVC.modalPresentationStyle = .overFullScreen
            popupVC.update(title: localizedString(forKey: "SummaryPopUpTitle", withDefaultValue: SystemMessage.SummaryUI.SummaryPopUpTitle, fileName: configuration.localizedStringFileName), content: summaryMessage)
            parentVC.present(popupVC, animated: false, completion: nil)
        }
    }
    
    fileprivate func setupConstraintsForAssignedTo() {
        let horizontalStackView = UIStackView()
        
        horizontalStackView.axis  = NSLayoutConstraint.Axis.horizontal
        horizontalStackView.distribution  = UIStackView.Distribution.equalSpacing
        horizontalStackView.alignment = UIStackView.Alignment.center
        lineViewLeft.isHidden = false
        lineViewRight.isHidden = false
        horizontalStackView.spacing = Padding.HorizontalStackView.spacing
        horizontalStackView.addArrangedSubview(lineViewLeft)
        horizontalStackView.addArrangedSubview(assignTextView)
        horizontalStackView.addArrangedSubview(lineViewRight)
      
        lineViewLeft.backgroundColor = .lightGray
        lineViewRight.backgroundColor = .lightGray
        
        contentView.addViewsForAutolayout(views: [horizontalStackView])
        contentView.bringSubviewToFront(assignTextView)
        
        horizontalStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Padding.HorizontalStackView.leading).isActive = true
        horizontalStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: Padding.HorizontalStackView.trailing).isActive = true
        
        lineViewLeft.widthAnchor.constraint(equalToConstant: Padding.LineView.width).isActive = true
        lineViewRight.widthAnchor.constraint(equalToConstant: Padding.LineView.width).isActive = true
        lineViewLeft.heightAnchor.constraint(equalToConstant: Padding.LineView.height).isActive = true
        lineViewRight.heightAnchor.constraint(equalToConstant: Padding.LineView.height).isActive = true
        
        assignTextView.setFont(ALKMessageStyle.assignmentMessage.font)
        assignTextView.setTextColor(ALKMessageStyle.assignmentMessage.text)
        contentView.backgroundColor = UIColor.clear
        backgroundColor = UIColor.clear
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
        
        messageView.setFont(ALKMessageStyle.feedbackMessage.font)
        messageView.textColor = ALKMessageStyle.feedbackMessage.text
        commentTextView.setFont(ALKMessageStyle.feedbackComment.font)
        commentTextView.textColor = ALKMessageStyle.feedbackComment.text
    }
    
    func getFeedback(viewModel: ALKMessageViewModel) -> [String: Any]? {
        guard let feedbackString = viewModel.metadata?["feedback"] as? String else { return nil }
        guard let data = feedbackString.data(using: .utf8),
            let dictionary = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else { return nil }
        return dictionary
    }
}
