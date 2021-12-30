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

    fileprivate var bubbleView: UIView = {
        let bv = UIView()
        bv.backgroundColor = UIColor.clear
        bv.layer.cornerRadius = 12
        bv.layer.borderColor = UIColor(netHex: 0xF3F3F3).cgColor
        bv.layer.borderWidth = 1.0
        bv.isUserInteractionEnabled = false
        return bv
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
            messageHeigh = rect.height + 17
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
        
        //adding rating icons to the label
        var ratingImage = UIImage()
        guard let feedbackString =  viewModel.metadata? ["feedback"] as? String else { return }
        do {
            let feedbackDictionary = try? JSONSerialization.jsonObject(with: feedbackString.data(using: .utf8)!, options: []) as? [String:Int]
            guard let rating = feedbackDictionary?["rating"] else { return }
            switch rating {
            case 1:
                ratingImage = UIImage(named: "sadEmoji", in: Bundle.applozic, compatibleWith: nil)!
            case 5:
                ratingImage = UIImage(named: "confusedEmoji", in: Bundle.applozic, compatibleWith: nil)!
            case 10:
                ratingImage = UIImage(named: "happyEmoji", in: Bundle.applozic, compatibleWith: nil)!
            default:
                print("incoreect data")
            }
        }
        catch {
           print(error)
        }

        let imageAttachment = NSTextAttachment()
        imageAttachment.image = ratingImage
        guard let attachedImage = imageAttachment.image else { return }
        imageAttachment.bounds = CGRect(x: 0, y: -5 , width: attachedImage.size.width, height: attachedImage.size.height)
        let imageString = NSAttributedString(attachment: imageAttachment)
        let userLabel = localizedString(forKey: "RatingLabelTitle", withDefaultValue: SystemMessage.Feedback.ratingLabelTitle, fileName: configuration.localizedStringFileName)
        var textString = NSMutableAttributedString(string: userLabel + " " + viewModel.message! + "  ")
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

    func setupStyle() {
        contentView.backgroundColor = UIColor.clear
        backgroundColor = UIColor.clear

        bubbleView.backgroundColor = ALKMessageStyle.infoMessage.background
        messageView.setFont(ALKMessageStyle.infoMessage.font)
        messageView.textColor = ALKMessageStyle.infoMessage.text
    }
}
