//
//  ALKMessageBaseCell.swift
//  ApplozicSwift
//
//  Created by Shivam Pokhriyal on 12/06/19.
//

import UIKit
import Kingfisher
import Applozic


class ALKImageView: UIImageView {

    // To highlight when long pressed
    override open var canBecomeFirstResponder: Bool {
        return true
    }
}


open class ALKMessageCell: ALKChatBaseCell<ALKMessageViewModel>, ALKCopyMenuItemProtocol, ALKReplyMenuItemProtocol {

    /// Dummy view required to calculate height for normal text.
    fileprivate static var dummyMessageView: ALKTextView = {
        let textView = ALKTextView.init(frame: .zero)
        textView.isUserInteractionEnabled = true
        textView.isSelectable = true
        textView.isEditable = false
        textView.dataDetectorTypes = .link
        textView.linkTextAttributes = [.foregroundColor: UIColor.blue,
                                       .underlineStyle: NSUnderlineStyle.single.rawValue]
        textView.isScrollEnabled = false
        textView.delaysContentTouches = false
        textView.textContainerInset = MessageInsets.normal
        textView.textContainer.lineFragmentPadding = 0
        textView.contentInset = .zero
        return textView
    }()

    /// Dummy view required to calculate height for attributed text.
    /// Required because we are using static textview which doesn't clear attributes
    /// once attributed string is used.
    /// See this question https://stackoverflow.com/q/21731207/6671572
    fileprivate static var dummyAttributedMessageView: ALKTextView = {
        let textView = ALKTextView.init(frame: .zero)
        textView.isUserInteractionEnabled = true
        textView.isSelectable = true
        textView.isEditable = false
        textView.dataDetectorTypes = .link
        textView.linkTextAttributes = [.foregroundColor: UIColor.blue,
                                       .underlineStyle: NSUnderlineStyle.single.rawValue]
        textView.isScrollEnabled = false
        textView.delaysContentTouches = false
        textView.textContainerInset = MessageInsets.html
        textView.textContainer.lineFragmentPadding = 0
        textView.contentInset = .zero
        return textView
    }()

    let messageView: ALKTextView = {
        let textView = ALKTextView.init(frame: .zero)
        textView.isUserInteractionEnabled = true
        textView.isSelectable = true
        textView.isEditable = false
        textView.dataDetectorTypes = .link
        textView.linkTextAttributes = [.foregroundColor: UIColor.blue,
                                       .underlineStyle: NSUnderlineStyle.single.rawValue]
        textView.isScrollEnabled = false
        textView.delaysContentTouches = false
        textView.textContainerInset = MessageInsets.normal
        textView.textContainer.lineFragmentPadding = 0
        textView.contentInset = .zero
        return textView
    }()

    struct MessageInsets {
        static let normal = UIEdgeInsets.zero
        static let html = UIEdgeInsets(top: 5, left: 0, bottom: -15, right: 0)
    }

    var timeLabel: UILabel = {
        let lb = UILabel()
        lb.isOpaque = true
        return lb
    }()

    var bubbleView: ALKImageView = {
        let bv = ALKImageView()
        bv.clipsToBounds = true
        bv.isUserInteractionEnabled = true
        bv.isOpaque = true
        return bv
    }()

    var replyView: UIView = {
        let view = UIView(frame: CGRect.zero)
        view.backgroundColor = UIColor.darkGray
        view.isUserInteractionEnabled = true
        return view
    }()

    var replyNameLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.numberOfLines = 1
        return label
    }()

    var replyMessageLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.numberOfLines = 1
        return label
    }()

    let previewImageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect.zero)
        imageView.backgroundColor = .clear
        return imageView
    }()

    fileprivate static let paragraphStyle: NSMutableParagraphStyle = {
        let style = NSMutableParagraphStyle.init()
        style.lineBreakMode = .byWordWrapping
        style.headIndent = 0
        style.tailIndent = 0
        style.firstLineHeadIndent = 0
        style.minimumLineHeight = 17
        style.maximumLineHeight = 17
        return style
    }()

    lazy var selfNameText: String = {
        let text = localizedString(forKey: "You", withDefaultValue: SystemMessage.LabelName.You, fileName: localizedStringFileName)
        return text
    }()

    var replyViewAction: (()->())? = nil

    override func update(viewModel: ALKMessageViewModel) {
        self.viewModel = viewModel

        if viewModel.isReplyMessage {
            guard
                let metadata = viewModel.metadata,
                let replyId = metadata[AL_MESSAGE_REPLY_KEY] as? String,
                let actualMessage = getMessageFor(key: replyId)
                else { return }
            replyNameLabel.text = actualMessage.isMyMessage ?
                selfNameText : actualMessage.displayName
            replyMessageLabel.text =
                getMessageTextFrom(viewModel: actualMessage)
            if let imageURL = getURLForPreviewImage(message: actualMessage) {
                setImageFrom(url: imageURL, to: previewImageView)
            } else {
                previewImageView.image = placeholderForPreviewImage(message: actualMessage)
            }
        } else {
            replyNameLabel.text = ""
            replyMessageLabel.text = ""
            previewImageView.image = nil
        }

        self.timeLabel.text   = viewModel.time
        self.messageView.attributedText = nil
        self.messageView.text = nil
        guard let message = viewModel.message else { return }

        switch viewModel.messageType {
        case .text, .quickReply:
            self.messageView.textContainerInset = MessageInsets.normal
            self.messageView.text = message
        case .html:
            self.messageView.textContainerInset = MessageInsets.html
            let attributes: [NSAttributedString.Key : Any] =
                [.paragraphStyle: ALKMessageCell.paragraphStyle]
            guard let htmlText = message.data.attributedString else { return }
            let mutableText = NSMutableAttributedString(attributedString: htmlText)
            mutableText.addAttributes(attributes, range: NSMakeRange(0,mutableText.length))
            self.messageView.attributedText = mutableText
        default:
            print("Not possible")
        }
    }

    override func setupViews() {
        super.setupViews()
        contentView.addViewsForAutolayout(views: [messageView,bubbleView,replyView, replyNameLabel, replyMessageLabel,previewImageView,timeLabel])
        contentView.bringSubviewToFront(messageView)

        bubbleView.addGestureRecognizer(longPressGesture)
        let replyTapGesture = UITapGestureRecognizer(target: self, action: #selector(replyViewTapped))
        replyView.addGestureRecognizer(replyTapGesture)
    }

    override func setupStyle() {
        super.setupStyle()
        timeLabel.setStyle(ALKMessageStyle.time)
    }

    class func messageHeight(viewModel: ALKMessageViewModel,
                             width: CGFloat,
                             font: UIFont) -> CGFloat {
        let messageHeight: CGFloat = 0
        dummyMessageView.font = font

        /// Check if message is nil
        guard let message = viewModel.message else { return messageHeight }

        /// Check if messagetype is text or html
        guard viewModel.messageType == .html else {
            return messageHeight + TextViewSizeCalculator.height(dummyMessageView, text: message, maxWidth: width)
        }

        /// Check if html message is correct or not.
        guard let htmlText = message.data.attributedString else { return 30 }
        let mutableText = NSMutableAttributedString(attributedString: htmlText)
        let attributes: [NSAttributedString.Key : Any]
            = [.paragraphStyle: ALKMessageCell.paragraphStyle]
        mutableText.addAttributes(attributes, range: NSMakeRange(0, mutableText.length))
        return messageHeight + TextViewSizeCalculator.height(dummyAttributedMessageView, attributedText: mutableText, maxWidth: width)
    }

    func menuCopy(_ sender: Any) {
        UIPasteboard.general.string = self.viewModel?.message ?? ""
    }

    func menuReply(_ sender: Any) {
        menuAction?(.reply)
    }

    func getMessageFor(key: String) -> ALKMessageViewModel? {
        let messageService = ALMessageService()
        return messageService.getALMessage(byKey: key)?.messageModel
    }

    @objc func replyViewTapped() {
        replyViewAction?()
    }

    func bubbleViewImage(for style: ALKMessageStyle.BubbleStyle, isReceiverSide: Bool = false,showHangOverImage:Bool) -> UIImage? {

        var imageTitle = showHangOverImage ? "chat_bubble_red_hover":"chat_bubble_red"
        // We can rotate the above image but loading the required
        // image would be faster and we already have both the images.
        if isReceiverSide {imageTitle = showHangOverImage ? "chat_bubble_grey_hover":"chat_bubble_grey"}

        guard let bubbleImage = UIImage.init(named: imageTitle, in: Bundle.applozic, compatibleWith: nil)
            else {return nil}

        // This API is from the Kingfisher so instead of directly using
        // imageFlippedForRightToLeftLayoutDirection() we are using this as it handles
        // platform availability and future updates for us.
        let modifier = FlipsForRightToLeftLayoutDirectionImageModifier()
        return modifier.modify(bubbleImage)

    }

    private func getMessageTextFrom(viewModel: ALKMessageViewModel) -> String? {
        switch viewModel.messageType {
        case .text, .html:
            return viewModel.message
        default:
            return viewModel.messageType.rawValue
        }
    }

    private func removeDefaultLongPressGestureFrom(_ textView: UITextView) {
        if let gestures = textView.gestureRecognizers {
            for ges in gestures {
                if ges.isKind(of: UILongPressGestureRecognizer.self) {
                    ges.isEnabled = false

                }
                else if ges.isKind(of: UITapGestureRecognizer.self) {
                    (ges as? UITapGestureRecognizer)?.numberOfTapsRequired = 1
                }
            }
        }
    }

    private func setImageFrom(url: URL?, to imageView: UIImageView) {
        imageView.kf.setImage(with: url)
    }

    private func getURLForPreviewImage(message: ALKMessageViewModel) -> URL? {
        switch message.messageType {
        case .photo, .video:
            return getImageURL(for: message)
        case .location:
            return getMapImageURL(for: message)
        default:
            return nil
        }
    }

    private func getImageURL(for message: ALKMessageViewModel) -> URL? {
        guard message.messageType == .photo else {return nil}
        if let filePath = message.filePath {
            let docDirPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let path = docDirPath.appendingPathComponent(filePath)
            return path
        } else if let thumnailURL = message.thumbnailURL {
            return thumnailURL
        }
        return nil
    }

    private func getMapImageURL(for message: ALKMessageViewModel) -> URL?  {
        guard message.messageType == .location else {return nil}
        guard let lat = message.geocode?.location.latitude,
            let lon = message.geocode?.location.longitude
            else { return nil }

        let latLonArgument = String(format: "%f,%f", lat, lon)
        guard let apiKey = ALUserDefaultsHandler.getGoogleMapAPIKey()
            else { return nil }
        let urlString = "https://maps.googleapis.com/maps/api/staticmap?center=\(latLonArgument)&zoom=17&size=375x295&maptype=roadmap&format=png&visual_refresh=true&markers=\(latLonArgument)&key=\(apiKey)"
        return URL(string: urlString)

    }

    private func placeholderForPreviewImage(message: ALKMessageViewModel) -> UIImage? {
        switch message.messageType {
        case .video:
            if let filepath = message.filePath {
                let docDirPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let path = docDirPath.appendingPathComponent(filepath)
                return getThumbnail(filePath: path)
            }
            return UIImage(named: "VIDEO", in: Bundle.applozic, compatibleWith: nil)
        case .location:
            return UIImage(named: "map_no_data", in: Bundle.applozic, compatibleWith: nil)
        default:
            return nil
        }
    }

    private func getThumbnail(filePath: URL) -> UIImage? {
        do {
            let asset = AVURLAsset(url: filePath , options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            return UIImage(cgImage: cgImage)

        } catch let error {
            print("*** Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }
}
