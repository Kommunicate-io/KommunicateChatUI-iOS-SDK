//
//  CurvedImageButton.swift
//  ApplozicSwift
//
//  Created by Shivam Pokhriyal on 25/09/19.
//

import UIKit

/// A curved button with text and optional image.
///
/// To change the spacing and other properties of view, change parameters of #CurvedImageButton.Config
public class CurvedImageButton: UIView {
    /// Configuration to change UI properties of `CurvedImageButton`
    public struct Config {
        /// Padding of view.
        public var padding = Padding(left: 14, right: 14, top: 8, bottom: 8)

        /// Space between image and text.
        /// If image is nil then this space will be 0.
        public var textImageSpace: CGFloat = 10

        /// Size of image.
        /// If image is nil then size will be 0.
        public var imageSize = CGSize(width: 12, height: 12)

        var spaceWithoutText: CGFloat {
            return padding.left + padding.right + textImageSpace + imageSize.width
        }

        /// Minimum width of the view.
        var minWidth: CGFloat = 45

        /// Minimum height of the view.
        var minHeight: CGFloat = 35

        public init() {}
    }

    /// Index of button. It will be used when button is tapped
    public var index: Int?

    /// Used to inform the delegate that the button is pressed.
    public weak var delegate: Tappable?

    // MARK: Internal Properties

    let title: String
    let maxWidth: CGFloat
    let image: UIImage?
    var config: Config

    private let label = UILabel()

    private let imageView = UIImageView()

    // MARK: Initializers

    /// Initializer for link button.
    ///
    /// - Parameters:
    ///   - title: Text to be shown in the button.
    ///   - image: Optional. If used, an image of size CurvedImageButton.Config.Image will be shown to the right of text.
    ///   - config: `CurvedImageButton.Config`. It can be used to customize UI of button.
    ///   - maxWidth: Maximum width of button so that it can render in multiple lines of text is large.
    public init(title: String,
                image: UIImage? = nil,
                config: Config = Config(),
                maxWidth: CGFloat = UIScreen.main.bounds.width)
    {
        self.title = title
        self.image = image
        self.config = config
        if image == nil {
            self.config.textImageSpace = 0
            self.config.imageSize = CGSize(width: 0, height: 0)
        }
        self.maxWidth = maxWidth
        super.init(frame: .zero)
        setupView()
        setupConstraint()
        setupAction()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public methods

    /// This method calculates width of button.
    ///
    /// - Returns: Button width for the given title.
    public func buttonWidth() -> CGFloat {
        let titleWidth =
            title
                .rectWithConstrainedWidth(maxWidth - config.spaceWithoutText,
                                          font: CurvedImageButton.QuickReplyButtonStyle.shared.font)
                .width
                .rounded(.up)
        let buttonWidth = titleWidth + config.spaceWithoutText
        return max(buttonWidth, config.minWidth) // Minimum width is 45
    }

    /// This method calculates height of button.
    ///
    /// - Returns: Button height for the given title.
    public func buttonHeight() -> CGFloat {
        let titleHeight =
            title
                .rectWithConstrainedWidth(maxWidth - config.spaceWithoutText,
                                          font: CurvedImageButton.QuickReplyButtonStyle.shared.font)
                .height
                .rounded(.up)
        let buttonHeight = titleHeight + config.padding.top + config.padding.bottom
        return max(buttonHeight, config.minHeight) // Minimum height is 35
    }

    /// This method calculates size of button.
    ///
    /// - NOTE: Pass same maxWidth, title and image used while creating button. Otherwise result will be wrong.
    /// - Returns: Button size for the given title.
    public class func buttonSize(text: String,
                                 image: UIImage? = nil,
                                 maxWidth: CGFloat = UIScreen.main.bounds.width,
                                 config: Config = Config()) -> CGSize
    {
        var config = config
        if image == nil {
            config.textImageSpace = 0
            config.imageSize = CGSize(width: 0, height: 0)
        }
        let textSize = text.rectWithConstrainedWidth(maxWidth - config.spaceWithoutText,
                                                     font: CurvedImageButton.QuickReplyButtonStyle.shared.font)
        let labelWidth = textSize.width.rounded(.up)
        let labelHeight = textSize.height.rounded(.up) + config.padding.top + config.padding.bottom
        return CGSize(width: max(labelWidth + config.spaceWithoutText, config.minWidth),
                      height: max(labelHeight, config.minHeight))
    }

    // MARK: Private methods

    @objc private func tapped(_: UIButton) {
        guard let delegate = delegate else { return }
        delegate.didTap(index: index, title: title)
    }

    private func setupAction() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))
        tapGesture.numberOfTapsRequired = 1
        addGestureRecognizer(tapGesture)
    }

    private func setupView() {
        let style = CurvedImageButton.QuickReplyButtonStyle.shared
        backgroundColor = style.buttonColor.background
        layer.cornerRadius = style.cornerRadius
        layer.borderWidth = style.borderWidth
        layer.borderColor = style.buttonColor.border
        clipsToBounds = true

        label.text = title
        label.textColor = style.buttonColor.text
        label.font = style.font
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping

        imageView.image = image?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = style.buttonColor.tint

        frame.size = CGSize(width: buttonWidth(), height: buttonHeight())
    }

    private func setupConstraint() {
        addViewsForAutolayout(views: [label, imageView])

        NSLayoutConstraint.activate([
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor,
                                                constant: -config.padding.right),
            imageView.widthAnchor.constraint(equalToConstant: config.imageSize.width),
            imageView.heightAnchor.constraint(equalToConstant: config.imageSize.height),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),

            label.leadingAnchor.constraint(equalTo: leadingAnchor,
                                           constant: config.padding.left),
            label.trailingAnchor.constraint(equalTo: imageView.leadingAnchor,
                                            constant: -config.textImageSpace),
            label.topAnchor.constraint(equalTo: topAnchor,
                                       constant: config.padding.top),
            label.bottomAnchor.constraint(equalTo: bottomAnchor,
                                          constant: -config.padding.bottom),
        ])
    }
}
