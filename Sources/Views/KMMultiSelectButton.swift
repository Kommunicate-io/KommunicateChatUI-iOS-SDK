//
//  KMMultiSelectButton.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by sathyan elangovan on 21/03/23.
//

import Foundation
import UIKit
#if canImport(RichMessageKit)
    import RichMessageKit
#endif

/// A curved button with text and  image.
public class KMMultiSelectButton: UIView {
    /// Configuration to change UI properties of `KMMultiSelectButton`
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

    var title: String = ""
    var maxWidth: CGFloat = 0.0
    var config =  Config()
    var isButtonselected = false
    
    private let label = UILabel()
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.isHidden = true
        return imageView
    }()
    
    // MARK: Initializers
    public init()
    {
        super.init(frame: .zero)
    }
    
    ///
    /// - Parameters:
    ///   - title: Text to be shown in the button.
    ///   - image: Optional. If used, an image of size KMMultiSelectButton.Config.Image will be shown to the right of text.
    ///   - config: `CurvedImageButton.Config`. It can be used to customize UI of button.
    ///   - maxWidth: Maximum width of button so that it can render in multiple lines of text is large.
    func update(title: String,maxWidth: CGFloat = UIScreen.main.bounds.width, isSelected: Bool) {
        self.title = title
        self.isButtonselected = isSelected
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
                                          font: KMMultipleSelectionConfiguration.shared.normalfont)
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
                                          font: KMMultipleSelectionConfiguration.shared.normalfont)
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
                                                     font: KMMultipleSelectionConfiguration.shared.normalfont)
        let labelWidth = textSize.width.rounded(.up)
        let labelHeight = textSize.height.rounded(.up) + config.padding.top + config.padding.bottom
        return CGSize(width: max(labelWidth + config.spaceWithoutText, config.minWidth),
                      height: max(labelHeight, config.minHeight))
    }

    // MARK: Private methods
    @objc private func tapped(_: UIButton) {
        let buttonConfiguration = KMMultipleSelectionConfiguration.shared
        if !isButtonselected {
            self.label.font = buttonConfiguration.selectedFont
            self.backgroundColor = buttonConfiguration.selectedBackgroundColor
            if let image = buttonConfiguration.image {
                self.imageView.image = image
            }
            self.imageView.isHidden = false
        } else {
            self.imageView.isHidden = true
            self.backgroundColor = buttonConfiguration.backgroundColor
            self.label.font = buttonConfiguration.normalfont
        }
        self.layoutSubviews()
        isButtonselected = !isButtonselected
        guard let delegate = delegate else { return }
        delegate.didTap(index: index, title: title)
    }

    private func setupAction() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))
        tapGesture.numberOfTapsRequired = 1
        addGestureRecognizer(tapGesture)
    }
    
    private func setupView() {
        let style = KMMultipleSelectionConfiguration.shared
        backgroundColor = style.backgroundColor
        layer.cornerRadius = style.cornorRadius
        layer.borderWidth = style.borderWidth
        layer.borderColor = style.borderColor.cgColor
        clipsToBounds = true

        label.text = title
        label.textColor = style.titleColor
        label.font = style.normalfont
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping

        if isButtonselected,let image = KMMultipleSelectionConfiguration.shared.image  {
            self.imageView.image = image
            self.imageView.isHidden = false
        } else {
            imageView.isHidden = true
        }
        frame.size = CGSize(width: buttonWidth(), height: buttonHeight())
    }

    private func setupConstraint() {
        let configuration = KMMultipleSelectionConfiguration.shared
        addViewsForAutolayout(views: [label, imageView])
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo:leadingAnchor, constant: 10),
            imageView.widthAnchor.constraint(equalToConstant: 20),
            imageView.heightAnchor.constraint(equalToConstant: 20),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            label.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 5),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            label.topAnchor.constraint(equalTo: topAnchor,constant: configuration.topPadding),
            label.bottomAnchor.constraint(equalTo: bottomAnchor,constant: -configuration.bottomPadding),

        ])
    }
}
