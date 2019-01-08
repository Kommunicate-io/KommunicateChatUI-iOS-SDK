//
//  ALKQuickReplyButton.swift
//  ApplozicSwift
//
//  Created by Shivam Pokhriyal on 07/01/19.
//

import UIKit

/// **ALKCurvedButton** is a generic curved button which renders text supplied to it.
///
/// It also accepts optional font, color and maxWidth for rendering.
/// - NOTE: Minimum width is 45 and minimum height is 35
public class ALKCurvedButton: UIButton {

    var title: String
    var color: UIColor
    var textFont: UIFont
    var maxWidth: CGFloat

    public struct Padding {
        var left: CGFloat = 10.0
        var right: CGFloat = 10.0
        var top: CGFloat = 5.0
        var bottom: CGFloat = 5.0
    }

    public let padding = Padding()

    // MARK: - Initializers
    /// Initializer for curved button.
    ///
    /// - Parameters:
    ///   - title: Text to be shown in the button
    ///   - font: Font for button text
    ///   - color: Color for button text
    ///   - maxWidth: Maximum width of button so that it can render in multiple lines of text is large.
    public init(title: String,
         font: UIFont = UIFont.systemFont(ofSize: 14),
         color: UIColor = UIColor(red: 85, green: 83, blue: 183),
         maxWidth: CGFloat = UIScreen.main.bounds.width) {
        self.title = title
        self.textFont = font
        self.color = color
        self.maxWidth = maxWidth
        super.init(frame: .zero)
        setupButton()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public methods
    /// This method calculates width of button.
    ///
    /// - Returns: Returns button width.
    public func buttonWidth() -> CGFloat {
        let titleWidth = title.rectWithConstrainedWidth(maxWidth, font: textFont).width
        var buttonWidth = titleWidth + padding.left + padding.right
        buttonWidth = buttonWidth > maxWidth ? maxWidth : buttonWidth
        return buttonWidth >= 45 ? buttonWidth : 45 //Minimum width is 45
    }

    /// This method calculates height of button.
    ///
    /// - Returns: Returns button height.
    public func buttonHeight() -> CGFloat {
        let titleHeight = title.rectWithConstrainedWidth(maxWidth, font: textFont).height
        let buttonHeight = titleHeight + padding.top + padding.bottom
        return buttonHeight >= 35 ? buttonHeight : 35 //Minimum height is 35
    }

    public class func buttonSize(text: String, maxWidth: CGFloat, font: UIFont) -> CGSize {
        let textSize = text.rectWithConstrainedWidth(maxWidth, font: font)
        var width = textSize.width + 28
        var height = textSize.height + 16
        width = width >= 45 ? width : 45
        height = height >= 35 ? height : 35
        return CGSize(width: width, height: height)
    }

    // MARK: - Private methods.
    private func setupButton() {
        /// Attributed title for button
        let attributes = [NSAttributedString.Key.font: textFont,
                          NSAttributedString.Key.foregroundColor : color]
        let attributedTitle = NSAttributedString(string: title, attributes: attributes)

        self.setAttributedTitle(attributedTitle, for: .normal)
        self.frame.size = CGSize(width: buttonWidth(), height: buttonHeight())
        self.widthAnchor.constraint(equalToConstant: buttonWidth()).isActive = true
        self.heightAnchor.constraint(equalToConstant: buttonHeight()).isActive = true
//        self.contentEdgeInsets = UIEdgeInsets(top: padding.top, left: padding.left, bottom: padding.bottom, right: padding.right)
        self.titleLabel?.lineBreakMode = .byWordWrapping
        self.backgroundColor = .clear
        self.layer.cornerRadius = 15
        self.layer.borderWidth = 2
        self.layer.borderColor = color.cgColor
        self.clipsToBounds = true
    }
}
