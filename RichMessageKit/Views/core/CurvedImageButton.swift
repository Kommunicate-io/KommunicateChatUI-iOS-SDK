//
//  CurvedImageButton.swift
//  ApplozicSwift
//
//  Created by Shivam Pokhriyal on 25/09/19.
//

import UIKit

public class LinkButton: UIView, RichButtonView {

    public struct Config {
        public struct Label {
            public static let left: CGFloat = 16
            public static let right: CGFloat = 10
            public static let top: CGFloat = 8
            public static let bottom: CGFloat = 8
        }
        public struct Image {
            public static let right: CGFloat = 16
            public static let width: CGFloat = 12
            public static let height: CGFloat = 12
        }

        fileprivate static let extraSpace = Label.left + Label.right + Image.width + Image.right
    }

    /// Index of button. It will be used when button is tapped
    public var index: Int?

    // MARK: Internal Properties

    let title: String
    let color: UIColor
    let textFont: UIFont
    let maxWidth: CGFloat
    var delegate: Tappable?

    private let label = UILabel()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: "link", in: Bundle.richMessageKit, compatibleWith: nil)
        imageView.image = image?.withRenderingMode(.alwaysTemplate)
        return imageView
    }()

    // MARK: Initializers

    /// Initializer for link button.
    ///
    /// - Parameters:
    ///   - title: Text to be shown in the button.
    ///   - delegate: A delegate used to receive callbacks when button is tapped.
    ///   - font: Font for button text.
    ///   - color: Color for button text.
    ///   - maxWidth: Maximum width of button so that it can render in multiple lines of text is large.
    public init(title: String,
                font: UIFont = UIFont.systemFont(ofSize: 14),
                color: UIColor = UIColor(red: 85, green: 83, blue: 183),
                maxWidth: CGFloat = UIScreen.main.bounds.width) {
        self.title = title
        textFont = font
        self.color = color
        self.maxWidth = maxWidth
        super.init(frame: .zero)
        setupConstraint()
        setupAction()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public methods

    /// This method calculates width of button.
    ///
    /// - Returns: Button width for the given title.
    public func buttonWidth() -> CGFloat {
        let titleWidth = title.rectWithConstrainedWidth(maxWidth - Config.extraSpace, font: textFont).width.rounded(.up)
        let buttonWidth = titleWidth + Config.extraSpace
        return max(buttonWidth, 45) // Minimum width is 45
    }

    /// This method calculates height of button.
    ///
    /// - Returns: Button height for the given title.
    public func buttonHeight() -> CGFloat {
        let titleHeight = title.rectWithConstrainedWidth(maxWidth - Config.extraSpace, font: textFont).height.rounded(.up)
        let buttonHeight = titleHeight + Config.Label.top + Config.Label.bottom
        return max(buttonHeight, 35) // Minimum height is 35
    }

    /// This method calculates size of button.
    ///
    /// - NOTE: Pass same maxWidth and font used while creating button.
    /// - Returns: Button size for the given title.
    public class func buttonSize(text: String,
                                 maxWidth: CGFloat = UIScreen.main.bounds.width,
                                 font: UIFont = UIFont.systemFont(ofSize: 14)) -> CGSize {
        let textSize = text.rectWithConstrainedWidth(maxWidth - Config.extraSpace, font: font)
        let labelWidth = textSize.width.rounded(.up)
        let labelHeight = textSize.height.rounded(.up) + Config.Label.top + Config.Label.bottom
        return CGSize(width: max(labelWidth + Config.extraSpace, 45),
                      height: max(labelHeight, 35))
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

    private func setupConstraint() {
        addViewsForAutolayout(views: [label, imageView])
        backgroundColor = .clear
        layer.cornerRadius = 15
        layer.borderWidth = 2
        layer.borderColor = color.cgColor
        clipsToBounds = true

        label.text = title
        label.textColor = color
        label.font = textFont

        frame.size = CGSize(width: buttonWidth(), height: buttonHeight())

        NSLayoutConstraint.activate([
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor,
                                                constant: -LinkButton.Config.Image.right),
            imageView.widthAnchor.constraint(equalToConstant: LinkButton.Config.Image.width),
            imageView.heightAnchor.constraint(equalToConstant: LinkButton.Config.Image.height),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),

            label.leadingAnchor.constraint(equalTo: leadingAnchor,
                                           constant: LinkButton.Config.Label.left),
            label.trailingAnchor.constraint(equalTo: imageView.leadingAnchor,
                                            constant: -LinkButton.Config.Label.right),
            label.topAnchor.constraint(equalTo: topAnchor,
                                       constant: LinkButton.Config.Label.top),
            label.bottomAnchor.constraint(equalTo: bottomAnchor,
                                          constant: -LinkButton.Config.Label.bottom),
            ])
    }

}
