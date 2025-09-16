//
//  KMChatMessageBaseCell.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by Shivam Pokhriyal on 12/06/19.
//

import Kingfisher
import KommunicateCore_iOS_SDK
import UIKit
import WebKit
#if canImport(RichMessageKit)
    import RichMessageKit
#endif
class KMChatImageView: UIImageView {
    // To highlight when long pressed
    override open var canBecomeFirstResponder: Bool {
        return true
    }
}

public protocol KMChatMessageCellDelegate: AnyObject {
    func urlTapped(url: URL, message: KMChatMessageViewModel)
}

// swiftlint:disable:next type_body_length
open class KMChatMessageCell: KMChatChatBaseCell<KMChatMessageViewModel> {
    enum ConstraintIdentifier {
        enum ReplyNameLabel {
            static let height = "ReplyNameHeight"
        }

        enum ReplyMessageLabel {
            static let height = "ReplyMessageHeight"
        }

        enum PreviewImage {
            static let height = "ReplyPreviewImageHeight"
            static let width = "ReplyPreviewImageWidth"
        }

        static let replyViewHeightIdentifier = "ReplyViewHeight"
    }

    weak var delegate: KMChatMessageCellDelegate?

    /// Dummy view required to calculate height for normal text.
    fileprivate static var dummyMessageView: KMChatTextView = {
        let textView = KMChatTextView(frame: .zero)
        textView.isUserInteractionEnabled = true
        textView.isSelectable = true
        textView.isEditable = false
        textView.dataDetectorTypes = .link
        textView.linkTextAttributes = [.foregroundColor: UIColor.blue,
                                       .underlineStyle: NSUnderlineStyle.single.rawValue]
        textView.isScrollEnabled = false
        textView.delaysContentTouches = false
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.contentInset = .zero
        return textView
    }()

    /// Dummy view required to calculate height for attributed text.
    /// Required because we are using static textview which doesn't clear attributes
    /// once attributed string is used.
    /// See this question https://stackoverflow.com/q/21731207/6671572
    fileprivate static var dummyAttributedMessageView: KMChatTextView = {
        let textView = KMChatTextView(frame: .zero)
        textView.isUserInteractionEnabled = true
        textView.isSelectable = true
        textView.isEditable = false
        textView.dataDetectorTypes = .link
        textView.linkTextAttributes = [.foregroundColor: UIColor.blue,
                                       .underlineStyle: NSUnderlineStyle.single.rawValue]
        textView.isScrollEnabled = false
        textView.delaysContentTouches = false
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.contentInset = .zero
        return textView
    }()

    fileprivate static var attributedStringCache = NSCache<NSString, NSAttributedString>()

    let messageView: KMChatTextView = {
        let textView = KMChatTextView(frame: .zero)
        textView.isUserInteractionEnabled = true
        textView.isSelectable = true
        textView.isEditable = false
        textView.dataDetectorTypes = .link
        textView.linkTextAttributes = [.foregroundColor: UIColor.blue,
                                       .underlineStyle: NSUnderlineStyle.single.rawValue]
        textView.isScrollEnabled = false
        textView.delaysContentTouches = false
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.contentInset = .zero
        return textView
    }()
    
    var iframeView: WKWebView = {
        let webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.isUserInteractionEnabled = true
        webView.isOpaque = true
        webView.scrollView.isScrollEnabled = false
        return webView
    }()

    var timeLabel: UILabel = {
        let lb = UILabel()
        lb.isOpaque = true
        return lb
    }()

    var bubbleView: KMChatImageView = {
        let bv = KMChatImageView()
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

    let emailTopView = KMChatEmailTopView(frame: .zero)
    let emailBottomView = KMChatEmailBottomView(frame: .zero)

    lazy var emailTopHeight = emailTopView.heightAnchor.constraint(equalToConstant: 0)
    lazy var emailBottomViewHeight = emailBottomView.heightAnchor.constraint(equalToConstant: 0)
    lazy var iframeWidth = iframeView.widthAnchor.constraint(equalToConstant: 0)

    fileprivate static let paragraphStyle: NSMutableParagraphStyle = {
        let style = NSMutableParagraphStyle()
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

    var replyViewAction: (() -> Void)?
    var displayNames: ((Set<String>) -> ([String: String]?))?

    func update(
        viewModel: KMChatMessageViewModel,
        messageStyle: Style,
        mentionStyle: Style
    ) {
        self.viewModel = viewModel
        iframeView.isHidden = true
        iframeWidth.isActive = false
        if viewModel.isReplyMessage {
            guard
                let metadata = viewModel.metadata,
                let replyId = metadata[AL_MESSAGE_REPLY_KEY] as? String,
                let actualMessage = getMessageFor(key: replyId)
            else { return }
            replyNameLabel.text = actualMessage.isMyMessage ?
                selfNameText : actualMessage.displayName
            setReplyMessageText(viewModel: actualMessage, mentionStyle: mentionStyle)

            if let imageURL = getURLForPreviewImage(message: actualMessage) {
                setImageFrom(url: imageURL, to: previewImageView)
            } else {
                previewImageView.image = placeholderForPreviewImage(message: actualMessage)
            }
        } else {
            replyNameLabel.text = ""
            replyMessageLabel.text = ""
            previewImageView.image = nil
            replyMessageLabel.attributedText = nil
        }

        timeLabel.text = viewModel.time
        resetTextView(messageStyle)
        emailView(show: false)
        guard let message = viewModel.message else { return }

        switch viewModel.messageType {
        case .text:
            emailTopHeight.constant = 0
            emailBottomViewHeight.constant = 0
            setMessageText(viewModel: viewModel, mentionStyle: mentionStyle)
            return
        case .html:
            if let html = viewModel.message, html.contains("<iframe") && html.contains("</iframe>") {
                var modifiedHTML = html
                if !html.contains("<meta name=\"viewport\"") {
                    modifiedHTML = "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">" + html
                }
                iframeView.isHidden = false
                iframeWidth.isActive = true
                iframeWidth.constant = CGFloat(KMChatMessageCell.extractIframeWidth(from: html) ?? 250)
                iframeView.loadHTMLString(modifiedHTML, baseURL: nil)
                return
            }
            emailTopHeight.constant = 0
            emailBottomViewHeight.constant = 0
        case .email:
            emailTopHeight.constant = KMChatEmailTopView.height
            emailBottomViewHeight.constant = KMChatEmailBottomView.Padding.View.height
            emailView(show: true)
        default:
            print("😱😱😱Shouldn't come here.😱😱😱")
            return
        }
        /// Comes here for html and email
        DispatchQueue.global(qos: .utility).async {
            guard let attributedText = KMChatMessageCell.attributedStringFrom(message, for: viewModel.identifier) else { return }
            let htmlMessage = NSMutableAttributedString(attributedString: attributedText)

            if let frontColor = htmlMessage.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? UIColor {
                let frontCGColor = frontColor.cgColor
                let frontUIColor = UIColor(cgColor: frontCGColor)
                
                if let targetColorSpace = CGColorSpace(name: CGColorSpace.sRGB), let targetCGColor = CGColor(colorSpace: targetColorSpace, components: [0, 0, 0, 1]) {
                    let targetColor = UIColor(cgColor: targetCGColor)
                    if frontUIColor.isEqual(targetColor) {
                        htmlMessage.addAttribute(.foregroundColor, value: UIColor.kmDynamicColor(light: .black, dark: .white), range: NSRange(location: 0, length: htmlMessage.length))
                    }
                }
            }

            print("message og html \(message)  att : \(attributedText)")
            
            /// Check for a condition where the user has not passed a font. In this scenario, set the font to the system's default font.
            if !message.contains("font-family") {
                htmlMessage.setBaseFont(baseFont: messageStyle.font)
            }
            DispatchQueue.main.async {
                self.messageView.attributedText = htmlMessage
            }
        }
    }

    override func setupViews() {
        super.setupViews()
        contentView.addViewsForAutolayout(views:
            [messageView,
             bubbleView,
             emailTopView,
             emailBottomView,
             replyView,
             replyNameLabel,
             replyMessageLabel,
             iframeView,
             previewImageView,
             timeLabel])
        contentView.bringSubviewToFront(iframeView)
        contentView.bringSubviewToFront(messageView)
        contentView.bringSubviewToFront(emailTopView)
        contentView.bringSubviewToFront(emailBottomView)

        bubbleView.addGestureRecognizer(longPressGesture)
        let replyTapGesture = UITapGestureRecognizer(target: self, action: #selector(replyViewTapped))
        replyView.addGestureRecognizer(replyTapGesture)
    }

    override func setupStyle() {
        super.setupStyle()
        timeLabel.setStyle(KMChatMessageStyle.time)
    }

    class func messageHeight(viewModel: KMChatMessageViewModel,
                             width: CGFloat,
                             font: UIFont,
                             mentionStyle: Style,
                             displayNames: ((Set<String>) -> ([String: String]?))?) -> CGFloat {
        dummyMessageView.font = font

        /// Check if message is nil
        guard let message = viewModel.message else {
            return 0
        }

        switch viewModel.messageType {
        case .text, .staticTopMessage:
            if let attributedText = viewModel
                .attributedTextWithMentions(
                    defaultAttributes: dummyMessageView.typingAttributes,
                    mentionAttributes: mentionStyle.toAttributes,
                    displayNames: displayNames
                ) {
                return TextViewSizeCalculator.height(dummyMessageView, attributedText: attributedText, maxWidth: width)
            }
            return TextViewSizeCalculator.height(dummyMessageView, text: message, maxWidth: width)
        case .html:
            guard let attributedText = attributedStringFrom(message, for: viewModel.identifier) else {
                return 0
            }
            if let html = viewModel.message, html.contains("<iframe") && html.contains("</iframe>") {
                return CGFloat(extractIframeHeight(from: html) ?? 150) /// default value of iframe height
            }
            let htmlMessage = NSMutableAttributedString(attributedString: attributedText)
            htmlMessage.setBaseFont(baseFont: font)
            dummyAttributedMessageView.font = font
            let height = TextViewSizeCalculator.height(
                dummyAttributedMessageView,
                attributedText: htmlMessage,
                maxWidth: width
            )
            return height
        case .email:
            guard let attributedText = attributedStringFrom(message, for: viewModel.identifier) else {
                return KMChatEmailTopView.height
            }
            let htmlMessage = NSMutableAttributedString(attributedString: attributedText)
            htmlMessage.setBaseFont(baseFont: font)
            dummyAttributedMessageView.font = font
            let height = KMChatEmailTopView.height + KMChatEmailBottomView.Padding.View.height +
                TextViewSizeCalculator.height(
                    dummyAttributedMessageView,
                    attributedText: htmlMessage,
                    maxWidth: width
                )
            return height
        default:
            print("😱😱😱Shouldn't come here.😱😱😱")
            return 0
        }
    }

    class func extractIframeHeight(from htmlMessage: String) -> Int? {
        let regexPattern = "(?i)height=(?:\"(.*?)\"|'(.*?)'|(\\d+))"
        guard let regex = try? NSRegularExpression(pattern: regexPattern, options: []) else {
            return nil
        }
        let range = NSRange(htmlMessage.startIndex..<htmlMessage.endIndex, in: htmlMessage)
                    
        if let match = regex.firstMatch(in: htmlMessage, options: [], range: range) {
            for captureGroupIndex in 1...3 {
                if let captureRange = Range(match.range(at: captureGroupIndex), in: htmlMessage) {
                    let heightInString = String(htmlMessage[captureRange])
                    if heightInString.contains("%") {
                        return 150
                    }
                    return extractIntFromString(heightInString)
                }
            }
        }
        return nil
    }
    
    class func extractIframeWidth(from htmlMessage: String) -> Int? {
        let regexPattern = "(?i)width=(?:\"(.*?)\"|'(.*?)'|(\\d+))"
        guard let regex = try? NSRegularExpression(pattern: regexPattern, options: []) else {
            return nil
        }
        let range = NSRange(htmlMessage.startIndex..<htmlMessage.endIndex, in: htmlMessage)
                    
        if let match = regex.firstMatch(in: htmlMessage, options: [], range: range) {
            for captureGroupIndex in 1...3 {
                if let captureRange = Range(match.range(at: captureGroupIndex), in: htmlMessage) {
                    let widthInString = String(htmlMessage[captureRange])
                    if widthInString.contains("%") {
                        return 250
                    }
                    return extractIntFromString(widthInString)
                }
            }
        }
        return nil
    }
    
    class func extractIntFromString(_ input: String) -> Int? {
        do {
            let regex = try NSRegularExpression(pattern: "(\\d+)", options: [])
            let matches = regex.matches(in: input, options: [], range: NSRange(location: 0, length: input.utf16.count))
            if let match = matches.first {
                if let range = Range(match.range(at: 1), in: input) {
                    return Int(input[range])
                }
            }
        } catch {
            print("Regex Error: \(error)")
        }
        return nil
    }

    func getMessageFor(key: String) -> KMChatMessageViewModel? {
        let messageService = KMCoreMessageService()
        return messageService.getKMCoreMessage(byKey: key)?.messageModel
    }

    @objc func replyViewTapped() {
        replyViewAction?()
    }

    private func emailView(show: Bool) {
        emailTopView.show(show)
        emailBottomView.show(show)
    }

    // MARK: - Private helper methods

    private class func attributedStringFrom(_ text: String, for id: String) -> NSAttributedString? {
        if !id.isEmpty, let attributedString = attributedStringCache.object(forKey: id as NSString) {
            return attributedString
        }
        guard !text.isEmpty, let htmlText = text.data(using: .utf8, allowLossyConversion: false) else {
            print("🤯🤯🤯Could not create UTF8 formatted data from \(text)")
            return nil
        }
        do {
            let attributedString = try NSAttributedString(
                data: htmlText,
                options: [
                    .documentType: NSAttributedString.DocumentType.html,
                    .characterEncoding: String.Encoding.utf8.rawValue
                ],
                documentAttributes: nil
            )
            attributedStringCache.setObject(attributedString, forKey: id as NSString)
            return attributedString
        } catch {
            print("😢😢😢 Error \(error) while creating attributed string")
            return nil
        }
    }

    private func getMessageTextFrom(viewModel: KMChatMessageViewModel) -> String? {
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
                } else if ges.isKind(of: UITapGestureRecognizer.self) {
                    (ges as? UITapGestureRecognizer)?.numberOfTapsRequired = 1
                }
            }
        }
    }

    private func setImageFrom(url: URL?, to imageView: UIImageView) {
        guard let url = url else { return }
        let provider = LocalFileImageDataProvider(fileURL: url)
        imageView.kf.setImage(with: provider)
    }

    private func getURLForPreviewImage(message: KMChatMessageViewModel) -> URL? {
        switch message.messageType {
        case .photo, .video:
            return getImageURL(for: message)
        case .location:
            return getMapImageURL(for: message)
        default:
            return nil
        }
    }

    private func getImageURL(for message: KMChatMessageViewModel) -> URL? {
        guard message.messageType == .photo else { return nil }
        if let filePath = message.filePath {
            let docDirPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let path = docDirPath.appendingPathComponent(filePath)
            return path
        } else if let thumnailURL = message.thumbnailURL {
            return thumnailURL
        }
        return nil
    }

    private func getMapImageURL(for message: KMChatMessageViewModel) -> URL? {
        guard message.messageType == .location else { return nil }
        guard let lat = message.geocode?.location.latitude,
              let lon = message.geocode?.location.longitude
        else { return nil }

        let latLonArgument = String(format: "%f,%f", lat, lon)
        guard let apiKey = KMCoreUserDefaultsHandler.getGoogleMapAPIKey()
        else {
            print("⚠️ Warning: Please add the Google Map API key, or Map Image will not work as expected. Use `KMCoreUserDefaultsHandler.setGoogleMapAPIKey(<Your-Google-Map-Api-Key>)`.")
            return nil
        }
        let urlString = "https://maps.googleapis.com/maps/api/staticmap?center=\(latLonArgument)&zoom=17&size=375x295&maptype=roadmap&format=png&visual_refresh=true&markers=\(latLonArgument)&key=\(apiKey)"
        return URL(string: urlString)
    }

    private func placeholderForPreviewImage(message: KMChatMessageViewModel) -> UIImage? {
        switch message.messageType {
        case .video:
            if let filepath = message.filePath {
                let docDirPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let path = docDirPath.appendingPathComponent(filepath)
                let fileUtills = KMChatFileUtils()
                return fileUtills.getThumbnail(filePath: path)
            }
            return UIImage(named: "VIDEO", in: Bundle.km, compatibleWith: nil)
        case .location:
            return UIImage(named: "map_no_data", in: Bundle.km, compatibleWith: nil)
        default:
            return nil
        }
    }

    /// This hack is required cuz textView won't clear its attributes.
    /// See this: https://stackoverflow.com/q/21731207/6671572
    private func resetTextView(_ style: Style) {
        messageView.attributedText = nil
        messageView.text = nil
        messageView.typingAttributes = [:]
        messageView.setStyle(style)
    }

    private func setReplyMessageText(
        viewModel: KMChatMessageViewModel,
        mentionStyle: Style
    ) {
        if viewModel.messageType == .text,
           let attributedText = viewModel
           .attributedTextWithMentions(
               defaultAttributes: [:],
               mentionAttributes: mentionStyle.toAttributes,
               displayNames: displayNames
           ) {
            replyMessageLabel.attributedText = attributedText
        } else {
            replyMessageLabel.text =
                getMessageTextFrom(viewModel: viewModel)
        }
    }

    private func setMessageText(
        viewModel: KMChatMessageViewModel,
        mentionStyle: Style
    ) {
        if let attributedText = viewModel
            .attributedTextWithMentions(
                defaultAttributes: messageView.typingAttributes,
                mentionAttributes: mentionStyle.toAttributes,
                displayNames: displayNames
            ) {
            messageView.attributedText = attributedText
        } else {
            messageView.text = viewModel.message
        }
    }
}
