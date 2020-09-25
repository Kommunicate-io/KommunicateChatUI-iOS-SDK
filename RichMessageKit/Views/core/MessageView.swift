//
//  MessageView.swift
//  RichMessageKit
//
//  Created by Shivam Pokhriyal on 18/01/19.
//

import UIKit

/// Its a view that displays text on top of a bubble.
public class MessageView: UIView {
    enum ConstraintIdentifier {
        enum MessageLabel {
            static let height = "MessageLabelHeight"
        }
    }

    enum ViewPadding {
        enum BubbleView {
            static let top: CGFloat = 3
        }
    }

    // MARK: Internal Properties

    let maxWidth: CGFloat

    /// Dummy view required to calculate height for normal text.
    fileprivate static var dummyMessageView: ALKTextView = {
        let textView = ALKTextView(frame: .zero)
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
    fileprivate static var dummyAttributedMessageView: ALKTextView = {
        let textView = ALKTextView(frame: .zero)
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

    let messageTextView: ALKTextView = {
        let textView = ALKTextView(frame: .zero)
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

    let bubbleView: UIView = {
        let view = UIView()
        return view
    }()

    let bubbleStyle: MessageBubbleStyle
    var padding: Padding
    var messageStyle: Style

    // MARK: Initializers

    /// Initializer for `MessageView`
    ///
    /// - Parameters:
    ///   - bubbleStyle: Configuration for message bubble like color and corner radius.
    ///   - messageStyle: Configuration for message text.
    ///   - maxWidth: Maximum width to constrain current view.
    public init(bubbleStyle: MessageBubbleStyle,
                messageStyle: Style,
                maxWidth: CGFloat)
    {
        self.bubbleStyle = bubbleStyle
        padding = bubbleStyle.padding
        self.messageStyle = messageStyle
        self.maxWidth = maxWidth
        super.init(frame: .zero)
        setupBubbleView()
        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public methods

    /// It sets message in `MessageView
    /// - Parameter model: This will have details for message
    public func update(model: Message) {
        /// Set frame size.
        let height = MessageView.rowHeight(model: model, maxWidth: maxWidth, font: messageStyle.font, padding: bubbleStyle.padding)
        frame.size = CGSize(width: maxWidth, height: height)

        messageTextView.backgroundColor = messageStyle.background
        messageTextView.font = messageStyle.font
        messageTextView.textColor = messageStyle.text

        switch model.contentType {
        case Message.ContentType.text:
            messageTextView.text = model.text
            layoutIfNeeded()
            return;
        case Message.ContentType.html:
            /// Comes here for html
            DispatchQueue.global(qos: .utility).async {
                let attributedText = MessageView.attributedStringFrom(model.text ?? "", for: model.identifier)
                DispatchQueue.main.async {
                    self.messageTextView.attributedText = attributedText
                    self.layoutIfNeeded()
                }
            }
        default:
            return
        }
    }

    /// It calculates height for `MessageView` based on the text passed and maximum width allowed for the view
    /// - Parameters:
    ///   - model: Message for which height is to be calculated..
    ///   - maxWidth: Maximum allowable width for the view.
    ///   - font: message text font. Use same as passed while initialization in `messageStyle`.
    ///   - padding: message bubble padding. Use the same passed while initialization in `bubbleStyle`.
    /// - Returns: Height for `MessageView` based on passed parameters

    public static func rowHeight(model: Message,
                                 maxWidth: CGFloat,
                                 font: UIFont,
                                 padding: Padding?) -> CGFloat
    {
        guard let padding = padding else {
            print("❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌")
            print("😱😱😱😱😱😱😱😱 Padding is not passed from outside.")
            print("Use the padding of bubbleStyle that is passed while initialization")
            print("❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌")
            return 0
        }

        switch model.contentType {
        case Message.ContentType.text:
            dummyMessageView.font = font
            return MessageViewSizeCalculator().height(dummyMessageView, text: model.text ?? "", maxWidth: maxWidth, padding: padding) +
                ViewPadding.BubbleView.top
        case Message.ContentType.html:
            guard let attributedText = attributedStringFrom(model.text ?? "", for: model.identifier) else {
                return 0
            }

            dummyAttributedMessageView.font = font

            return MessageViewSizeCalculator().height(dummyAttributedMessageView, attributedText: attributedText, maxWidth: maxWidth, padding: padding) +
                ViewPadding.BubbleView.top
        default:
            return 0
        }
    }

    public func updateHeighOfView(hideView: Bool, model: Message) {
        let messageHeight = hideView ? 0 :
            MessageView.rowHeight(model: model,
                                  maxWidth: maxWidth,
                                  font: messageStyle.font,
                                  padding: bubbleStyle.padding)

        messageTextView
            .constraint(withIdentifier: ConstraintIdentifier.MessageLabel.height)?.constant = messageHeight
    }

    // MARK: Private methods

    private func setupBubbleView() {
        bubbleView.backgroundColor = bubbleStyle.color
        bubbleView.layer.cornerRadius = bubbleStyle.cornerRadius
        bubbleView.clipsToBounds = true
    }

    private func setupConstraints() {
        addViewsForAutolayout(views: [messageTextView, bubbleView])
        bringSubviewToFront(messageTextView)

        NSLayoutConstraint.activate([
            bubbleView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bubbleView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bubbleView.bottomAnchor.constraint(equalTo: bottomAnchor),
            bubbleView.topAnchor.constraint(equalTo: topAnchor, constant: ViewPadding.BubbleView.top),
            messageTextView.topAnchor.constraint(equalTo: topAnchor, constant: padding.top),
            messageTextView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1 * padding.bottom),
            messageTextView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding.left),
            messageTextView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -1 * padding.right),
            messageTextView.heightAnchor.constraintEqualToAnchor(constant: 0, identifier: ConstraintIdentifier.MessageLabel.height),
        ])
    }

    private class func attributedStringFrom(_ text: String, for id: String) -> NSAttributedString? {
        if let attributedString = attributedStringCache.object(forKey: id as NSString) {
            return attributedString
        }
        guard let htmlText = text.data(using: .utf8, allowLossyConversion: false) else {
            print("🤯🤯🤯Could not create UTF8 formatted data from \(text)")
            return nil
        }
        do {
            let attributedString = try NSAttributedString(
                data: htmlText,
                options: [
                    .documentType: NSAttributedString.DocumentType.html,
                    .characterEncoding: String.Encoding.utf8.rawValue,
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
}
