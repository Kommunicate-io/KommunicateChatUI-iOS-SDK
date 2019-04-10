//
//  ImageMessageView.swift
//  RichMessageKit
//
//  Created by Shivam Pokhriyal on 05/02/19.
//

import UIKit

/// It shows image and caption over a bubble with a fixed width that is passed to it.
///
/// - NOTE: To change configurations like font color etc, change `ImageBubbleStyle`
public class ImageBubble: UIView, ViewInterface {

    fileprivate let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "placeholder", in: Bundle.richMessageKit, compatibleWith: nil)
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        return imageView
    }()

    fileprivate let caption: UILabel = {
        let label = UILabel(frame: .zero)
        label.isHidden = true
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()

    fileprivate let bubbleView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        return view
    }()

    fileprivate let isMyMessage: Bool
    fileprivate let padding: Padding
    fileprivate let maxWidth: CGFloat

    static let captionTopPadding: CGFloat = 4.0

    public init(frame: CGRect, maxWidth: CGFloat, isMyMessage: Bool) {
        self.maxWidth = maxWidth
        self.isMyMessage = isMyMessage
        padding = isMyMessage ? ImageBubbleTheme.sentMessage.bubble.padding : ImageBubbleTheme.receivedMessage.bubble.padding
        super.init(frame: frame)
        setupConstraints()
        setupStyle()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// It sets image and caption in `ImageMessageView`
    ///
    /// - Parameter model: object that conforms to `ImageModel` to update the view.
    public func update(model: ImageModel) {
        updateImage(model)
        updateCaption(model)
        /// Set frame
        let widthRatio = isMyMessage ? ImageBubbleTheme.sentMessage.widthRatio : ImageBubbleTheme.receivedMessage.widthRatio
        let width = maxWidth * widthRatio
        let height = ImageBubble.rowHeight(model: model, maxWidth: width)
        self.frame.size = CGSize(width: width, height: height)
    }

    /// It calculates height of `ImageMessageView` with given width and model
    ///
    /// - WARNING: Font and Padding is not used.
    /// - NOTE: font is `ImageBubbleStyle.captionStyle.font`. To change font, modify `ImageBubbleStyle`.
    /// - Parameters:
    ///   - model: model that conforms to `ImageModel`
    ///   - width: width of the view. Use same which is passed in initialization.
    /// - Returns: Height of view based on width and model
    public static func rowHeight(model: ImageModel,
                                 maxWidth: CGFloat,
                                 font: UIFont = UIFont(),
                                 padding: Padding? = nil) -> CGFloat {
        return ImageBubbleSizeCalculator().rowHeight(model: model, maxWidth: maxWidth)
    }

    private func setupConstraints() {
        self.addViewsForAutolayout(views: [imageView, caption, bubbleView])
        self.bringSubviewToFront(imageView)
        self.bringSubviewToFront(caption)

        bubbleView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        bubbleView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        bubbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        bubbleView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true

        imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: padding.top).isActive = true
        imageView.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: padding.left).isActive = true
        imageView.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -1 * padding.right).isActive = true
        /// Set Image Height
        let heightRatio = isMyMessage ? ImageBubbleTheme.sentMessage.heightRatio : ImageBubbleTheme.receivedMessage.heightRatio
        let imageHeight = maxWidth * heightRatio
        imageView.heightAnchor.constraint(equalToConstant: imageHeight).isActive = true

        caption.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: ImageBubble.captionTopPadding).isActive = true
        caption.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: padding.left).isActive = true
        caption.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -1 * padding.right).isActive = true
        caption.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -1 * padding.bottom).isActive = true
    }

    private func setupStyle() {
        switch isMyMessage {
        case true:
            caption.setStyle(ImageBubbleTheme.sentMessage.captionStyle)
            bubbleView.backgroundColor = ImageBubbleTheme.sentMessage.bubble.color
            bubbleView.layer.cornerRadius = ImageBubbleTheme.sentMessage.bubble.cornerRadius
        case false:
            caption.setStyle(ImageBubbleTheme.receivedMessage.captionStyle)
            bubbleView.backgroundColor = ImageBubbleTheme.receivedMessage.bubble.color
            bubbleView.layer.cornerRadius = ImageBubbleTheme.receivedMessage.bubble.cornerRadius
        }
    }

    private func updateImage(_ model: ImageModel) {
        guard let url = URL(string: model.url) else { return }
        ImageCache.downloadImage(url: url) { [weak self] image in
            guard let image = image else { return }
            DispatchQueue.main.async {
                self?.imageView.image = image
            }
        }
    }

    private func updateCaption(_ model: ImageModel) {
        guard let text = model.caption else {
            caption.isHidden = true
            return
        }
        caption.isHidden = false
        caption.text = text
    }

}
