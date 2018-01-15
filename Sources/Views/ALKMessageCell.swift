//
//  ALKMessageCell.swift
//  
//
//  Created by Mukesh Thawani on 04/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher
import Applozic

// MARK: - MessageType
public enum ALKMessageType {
    case text
    case photo
    case voice
    case location
    case information
    case video
    case html
}

// MARK: - MessageViewModel
public protocol ALKMessageViewModel {
    var message: String? { get }
    var isMyMessage: Bool { get }
    var messageType: ALKMessageType { get }
    var identifier: String { get }
    var date: Date { get }
    var time: String? { get }
    var avatarURL: URL? { get }
    var displayName: String? { get }
    var contactId: String? { get }
    var channelKey: NSNumber? { get }
    var conversationId: NSNumber? { get }
    var isSent: Bool { get }
    var isAllReceived: Bool { get }
    var isAllRead: Bool { get }
    var ratio: CGFloat { get }
    var size: Int64 { get }
    var thumbnailURL: URL? { get }
    var imageURL: URL? { get }
    var filePath: String? { get set }
    var geocode: Geocode? { get }
    var voiceData: Data? { get set }
    var voiceTotalDuration: CGFloat { get set }
    var voiceCurrentDuration: CGFloat { get set }
    var voiceCurrentState: ALKVoiceCellState { get set }
    var fileMetaInfo: ALFileMetaInfo? { get }
    var receiverId: String? { get }
}

// MARK: - ALKFriendMessageCell
final class ALKFriendMessageCell: ALKMessageCell {

    private var avatarImageView: UIImageView = {
        let imv = UIImageView()
        imv.contentMode = .scaleAspectFill
        imv.clipsToBounds = true
        let layer = imv.layer
        layer.cornerRadius = 18.5
        layer.masksToBounds = true
        imv.isUserInteractionEnabled = true
        return imv
    }()

    private var nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.isOpaque = true
        return label
    }()

    override func setupViews() {
        super.setupViews()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(avatarTappedAction))
        avatarImageView.addGestureRecognizer(tapGesture)

        contentView.addViewsForAutolayout(views: [avatarImageView,nameLabel])

        nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 57).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -57).isActive = true
        nameLabel.bottomAnchor.constraint(equalTo: messageView.topAnchor, constant: -10).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: 16).isActive = true

        avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 18).isActive = true
        avatarImageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: 0).isActive = true

        avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 9).isActive = true

        avatarImageView.trailingAnchor.constraint(equalTo: messageView.leadingAnchor, constant: -18).isActive = true

        avatarImageView.heightAnchor.constraint(equalToConstant: 37).isActive = true
        avatarImageView.widthAnchor.constraint(equalTo: avatarImageView.heightAnchor).isActive = true


        messageView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -57).isActive = true

        messageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -1 * ALKFriendMessageCell.bottomPadding()).isActive = true

        timeLabel.leadingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: 10).isActive = true

        bubbleView.topAnchor.constraint(equalTo: messageView.topAnchor, constant: -4).isActive = true
        bubbleView.bottomAnchor.constraint(equalTo: messageView.bottomAnchor, constant: 4).isActive = true

        bubbleView.leadingAnchor.constraint(equalTo: messageView.leadingAnchor, constant: -13).isActive = true
        bubbleView.trailingAnchor.constraint(equalTo: messageView.trailingAnchor, constant: 5).isActive = true

        timeLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: 2).isActive = true
        let image = UIImage.init(named: "chat_bubble_grey", in: Bundle.applozic, compatibleWith: nil)
        bubbleView.image = image?.imageFlippedForRightToLeftLayoutDirection()
        bubbleView.tintColor = UIColor(netHex: 0xF1F0F0)
    }

    override func setupStyle() {
        super.setupStyle()

        nameLabel.setStyle(style: ALKMessageStyle.displayName)
    }

    override func update(viewModel: ALKMessageViewModel) {
        super.update(viewModel: viewModel)
        

        let placeHolder = UIImage(named: "placeholder", in: Bundle.applozic, compatibleWith: nil)

        if let url = viewModel.avatarURL {

            let resource = ImageResource(downloadURL: url, cacheKey: url.absoluteString)
            self.avatarImageView.kf.setImage(with: resource, placeholder: placeHolder, options: nil, progressBlock: nil, completionHandler: nil)
        } else {

            self.avatarImageView.image = placeHolder
        }

        nameLabel.text = viewModel.displayName
    }

    override class func leftPadding() -> CGFloat {
        return 64//9+37+18
    }

    override class func rightPadding() -> CGFloat {
        return 57
    }

    override class func topPadding() -> CGFloat {
        return 32//6+16+10
    }

    override class func bottomPadding() -> CGFloat {
        return 6
    }

    // MARK: - ChatMenuCell
    override func menuWillShow(_ sender: Any) {
        super.menuWillShow(sender)
        self.bubbleView.image = UIImage.init(named: "chat_bubble_grey_hover", in: Bundle.applozic, compatibleWith: nil)
    }

    override func menuWillHide(_ sender: Any) {
        super.menuWillHide(sender)
        self.bubbleView.image = UIImage.init(named: "chat_bubble_grey", in: Bundle.applozic, compatibleWith: nil)
    }

    override class func rowHeigh(viewModel: ALKMessageViewModel,width: CGFloat) -> CGFloat {

        let minimumHeigh: CGFloat = 55.0
        let totalRowHeigh = super.rowHeigh(viewModel: viewModel, width: width)
        return totalRowHeigh < minimumHeigh ? minimumHeigh : totalRowHeigh
    }

    @objc private func avatarTappedAction() {
        avatarTapped?()
    }
}


// MARK: - ALKFriendMessageCell
final class ALKMyMessageCell: ALKMessageCell {

    fileprivate var stateView: UIImageView = {
        let sv = UIImageView()
        sv.isUserInteractionEnabled = false
        sv.contentMode = .center
        return sv
    }()

    override func setupViews() {
        super.setupViews()

        contentView.addViewsForAutolayout(views: [stateView])

        messageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: ALKMessageCell.topPadding()).isActive = true
        messageView.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: ALKMessageCell.rightPadding()).isActive = true
        messageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -1*ALKMessageCell.leftPadding()).isActive = true
        messageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -1 * ALKMyMessageCell.bottomPadding()).isActive = true

        bubbleView.topAnchor.constraint(equalTo: messageView.topAnchor, constant: -4).isActive = true
        bubbleView.bottomAnchor.constraint(equalTo: messageView.bottomAnchor, constant: 4).isActive = true

        bubbleView.leadingAnchor.constraint(equalTo: messageView.leadingAnchor, constant: -5).isActive = true

        bubbleView.trailingAnchor.constraint(equalTo: messageView.trailingAnchor, constant: 10).isActive = true

        stateView.widthAnchor.constraint(equalToConstant: 17.0).isActive = true
        stateView.heightAnchor.constraint(equalToConstant: 9.0).isActive = true
        stateView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -1.0).isActive = true
        stateView.trailingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: -2.0).isActive = true

        timeLabel.trailingAnchor.constraint(equalTo: stateView.leadingAnchor, constant: -2.0).isActive = true
        timeLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: 2).isActive = true
    }

    override func update(viewModel: ALKMessageViewModel) {
        super.update(viewModel: viewModel)

        if viewModel.isAllRead {
            stateView.image = UIImage(named: "read_state_3", in: Bundle.applozic, compatibleWith: nil)
            stateView.tintColor = UIColor(netHex: 0x0578FF)
        } else if viewModel.isAllReceived {
            stateView.image = UIImage(named: "read_state_2", in: Bundle.applozic, compatibleWith: nil)
            stateView.tintColor = nil
        } else if viewModel.isSent {
            stateView.image = UIImage(named: "read_state_1", in: Bundle.applozic, compatibleWith: nil)
            stateView.tintColor = nil
        } else {
            stateView.image = UIImage(named: "seen_state_0", in: Bundle.applozic, compatibleWith: nil)
            stateView.tintColor = UIColor.red
        }
    }

    // MARK: - ChatMenuCell
    override func menuWillShow(_ sender: Any) {
        super.menuWillShow(sender)
        self.bubbleView.image = UIImage.init(named: "chat_bubble_red_hover", in: Bundle.applozic, compatibleWith: nil)
    }

    override func menuWillHide(_ sender: Any) {
        super.menuWillHide(sender)
        self.bubbleView.image = UIImage.init(named: "chat_bubble_red", in: Bundle.applozic, compatibleWith: nil)
    }
}

class ALKMessageCell: ALKChatBaseCell<ALKMessageViewModel>, ALKCopyMenuItemProtocol{

    fileprivate lazy var messageView: UITextView = {
        let textView = UITextView.init(frame: .zero)
        textView.isUserInteractionEnabled = true
        textView.isEditable = false
        textView.sizeToFit()
        textView.isScrollEnabled = false
        textView.dataDetectorTypes = .all
        return textView
    }()

    fileprivate var timeLabel: UILabel = {
        let lb = UILabel()
        lb.isOpaque = true
        return lb
    }()

    fileprivate var bubbleView: UIImageView = {
        let bv = UIImageView()
        let image = UIImage.init(named: "chat_bubble_red", in: Bundle.applozic, compatibleWith: nil)
        bv.tintColor = UIColor(netHex: 0xF1F0F0)
        bv.image = image?.imageFlippedForRightToLeftLayoutDirection()
        bv.isUserInteractionEnabled = false
        bv.isOpaque = true
        return bv
    }()

    override func update(viewModel: ALKMessageViewModel) {
        self.viewModel = viewModel

        self.messageView.attributedText = nil
        self.messageView.text = nil
        guard let message = viewModel.message else { return }
        if viewModel.messageType == .text {
            self.messageView.text = message
        } else if viewModel.messageType == .html {

            let style = NSMutableParagraphStyle.init()
            style.lineBreakMode = .byWordWrapping
            style.headIndent = 0
            style.tailIndent = 0
            style.firstLineHeadIndent = 0
            style.minimumLineHeight = 17
            style.maximumLineHeight = 17

            let attributes: [String : Any] = [NSParagraphStyleAttributeName: style]
            guard let htmlText = message.data.attributedString else { return }
            let mutableText = NSMutableAttributedString(attributedString: htmlText)
            mutableText.addAttributes(attributes, range: NSMakeRange(0,mutableText.length))
            self.messageView.attributedText = mutableText
        }
        self.timeLabel.text   = viewModel.time
    }

    override func setupViews() {
        super.setupViews()

        contentView.addViewsForAutolayout(views: [messageView,bubbleView,timeLabel])
        contentView.bringSubview(toFront: messageView)
    }

    override func setupStyle() {
        super.setupStyle()

        timeLabel.setStyle(style: ALKMessageStyle.time)
        messageView.setStyle(style: ALKMessageStyle.message)

    }

    class func leftPadding() -> CGFloat {
        return 16
    }

    class func rightPadding() -> CGFloat {
        return 65
    }

    class func topPadding() -> CGFloat {
        return 10
    }

    class func bottomPadding() -> CGFloat {
        return 10
    }


    override class func rowHeigh(viewModel: ALKMessageViewModel,width: CGFloat) -> CGFloat {

        var messageHeigh: CGFloat = 0

        if let message = viewModel.message {


            let widthNoPadding = width - leftPadding() - rightPadding()
            let maxSize = CGSize.init(width: widthNoPadding, height: CGFloat.greatestFiniteMagnitude)

            let font = Font.normal(size: 14).font()
            let color = UIColor.color(ALKMessageStyle.message.color)

            let style = NSMutableParagraphStyle.init()
            style.lineBreakMode = .byWordWrapping
            style.headIndent = 0
            style.tailIndent = 0
            style.firstLineHeadIndent = 0
            style.minimumLineHeight = 17
            style.maximumLineHeight = 17

            let attributes: [String : Any] = [NSFontAttributeName: font,
                                              NSForegroundColorAttributeName: color,
                                              NSParagraphStyleAttributeName: style
            ]
            var size = CGRect()
            if viewModel.messageType == .html {
                guard let htmlText = message.data.attributedString else { return 30}
                let mutableText = NSMutableAttributedString(attributedString: htmlText)
                let attributes: [String : Any] = [NSParagraphStyleAttributeName: style]
                mutableText.addAttributes(attributes, range: NSMakeRange(0,mutableText.length))
                size = mutableText.boundingRect(with: maxSize, options: [NSStringDrawingOptions.usesFontLeading, NSStringDrawingOptions.usesLineFragmentOrigin], context: nil)
            } else {
                size = message.boundingRect(with: maxSize, options: [NSStringDrawingOptions.usesFontLeading, NSStringDrawingOptions.usesLineFragmentOrigin],attributes: attributes, context: nil)
            }
            messageHeigh = ceil(size.height) + 15 // due to textview's bottom pading

        }

        return topPadding()+messageHeigh+bottomPadding()
    }

    func menuCopy(_ sender: Any) {
        UIPasteboard.general.string = self.viewModel?.message ?? ""
    }
}
