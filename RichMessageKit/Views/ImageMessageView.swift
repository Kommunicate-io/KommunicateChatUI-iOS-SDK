//
//  ReceivedImageMessageView.swift
//  RichMessageKit
//
//  Created by Shivam Pokhriyal on 07/02/19.
//

import UIKit

public class ImageMessageView: UIView, ViewInterface {

    /// It is used to inform the delegate that the image is tapped. URL of tapped image is sent.
    public var delegate: Tappable?

    static let imageBubbleTopPadding: CGFloat = 4

    fileprivate var messageView: UIView
    fileprivate var messageViewPadding: Padding
    fileprivate var imageBubble: ImageBubble
    fileprivate var imageBubbleWidth: CGFloat
    fileprivate var maxWidth: CGFloat
    fileprivate var padding: Padding
    fileprivate var isMyMessage: Bool
    fileprivate lazy var messageViewHeight = messageView.heightAnchor.constraint(equalToConstant: 0)
    fileprivate var imageUrl: String?

    public init(frame: CGRect, maxWidth: CGFloat, padding: Padding, isMyMessage: Bool) {
        self.maxWidth = maxWidth
        self.padding = padding
        messageViewPadding = Padding(left: padding.left,
                                     right: padding.right,
                                     top: padding.top,
                                     bottom: ImageMessageView.imageBubbleTopPadding)
        self.isMyMessage = isMyMessage
        if isMyMessage {
            messageView = SentMessageView(frame: .zero, padding: messageViewPadding, maxWidth: maxWidth)
        } else {
            messageView = ReceivedMessageView(frame: .zero, padding: messageViewPadding, maxWidth: maxWidth)
        }
        imageBubble = ImageBubble(frame: .zero, maxWidth: maxWidth, isMyMessage: isMyMessage)
        imageBubbleWidth = maxWidth * (isMyMessage ? ImageBubbleTheme.sentMessage.widthRatio : ImageBubbleTheme.receivedMessage.widthRatio)
        super.init(frame: frame)
        setupConstraints()
        setupGesture()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Updated the `ImageMessageView`.
    ///
    /// - WARNING: `MessageModel`'s isMyMessage should be same as what is passed in initialization.
    /// - Parameter model: object that conforms to `MessageModel`
    public func update(model: MessageModel & ImageModel) {
        guard isMyMessage == model.isMyMessage else {
            print("😱😱😱Inconsistent information passed to the view.😱😱😱")
            print("During initialization isMyMessage's value is \(isMyMessage) and model's isMyMessage value is \(model.isMyMessage)")
            return
        }
        if isMyMessage {
            let sentMsgView = messageView as! SentMessageView
            sentMsgView.update(model: model)
            messageViewHeight.constant = SentMessageView.rowHeight(model: model, maxWidth: maxWidth, padding: messageViewPadding)
        } else {
            let receivedMsgView = messageView as! ReceivedMessageView
            receivedMsgView.update(model: model)
            messageViewHeight.constant = ReceivedMessageView.rowHeight(model: model, maxWidth: maxWidth, padding: messageViewPadding)
        }
        /// Set frame
        let height = ImageMessageView.rowHeight(model: model, maxWidth: maxWidth, padding: padding)
        self.frame.size = CGSize(width: maxWidth, height: height)

        imageUrl = model.url
        imageBubble.update(model: model)
    }

    /// It is used to get exact height of `ImageMessageView` using messageModel, width and padding
    ///
    /// - NOTE: Font is not used. Change `ImageBubbleStyle.captionStyle.font`
    /// - Parameters:
    ///   - model: object that conforms to `MessageModel`
    ///   - maxWidth: maximum allowable width for the view.
    ///   - padding: padding for the view.
    /// - Returns: exact height of the view.
    public static func rowHeight(model: MessageModel & ImageModel,
                                 maxWidth: CGFloat,
                                 font: UIFont = UIFont(),
                                 padding: Padding?) -> CGFloat {
        guard let padding = padding else {
            print("Padding is not passed from outside. Use the same padding in initialization.")
            return 0
        }
        return ImageMessageViewSizeCalculator().rowHeight(model: model, maxWidth: maxWidth, padding: padding)
    }

    private func setupConstraints() {
        self.addViewsForAutolayout(views: [messageView, imageBubble])

        messageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        messageView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        messageView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        messageViewHeight.isActive = true

        imageBubble.topAnchor.constraint(equalTo: messageView.bottomAnchor, constant: 0).isActive = true
        if isMyMessage {
            imageBubble.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -1 * padding.right).isActive = true
        } else {
            let leadingMargin = padding.left + (ReceivedMessageView.Config.ProfileImage.width + ReceivedMessageView.Config.MessageView.leftPadding)
            imageBubble.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: leadingMargin).isActive = true
        }
        imageBubble.widthAnchor.constraint(equalToConstant: imageBubbleWidth).isActive = true
        imageBubble.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -1 * padding.bottom).isActive = true
    }

    @objc private func imageTapped() {
        guard let delegate = delegate else {
            print("❌❌❌ Delegate is not set. To handle image click please set delegate.❌❌❌")
            return
        }
        guard let imageUrl = imageUrl else {
            print("😱😱😱 ImageUrl is found nil. 😱😱😱")
            return
        }
        delegate.didTap(index: 0, title: imageUrl)
    }

    private func setupGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        tapGesture.numberOfTapsRequired = 1
        imageBubble.addGestureRecognizer(tapGesture)
    }

}
