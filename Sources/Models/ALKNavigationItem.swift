import UIKit

/// ALKNavigationItem class is used for creating a Navigation bar items
public struct ALKNavigationItem {
    public static let NSNotificationForConversationViewNavigationTap = "ConversationViewNavigationTap"

    public static let NSNotificationForConversationListNavigationTap = "ConversationListNavigationTap"
    
    public var faqTextColor: UIColor = UIColor.white
    public var faqBackgroundColor: UIColor = UIColor(hexString: "ffffff", alpha: 0.24)
    let faqIdentifier = 11_223_346

    /// The identifier of this item.
    public let identifier: Int

    /// The text of this item.
    public let buttonText: String?

    /// The image of this item.
    public let buttonImage: UIImage?

    private init(
        identifier: Int,
        buttonText: String? = nil,
        buttonImage: UIImage? = nil
    ) {
        self.identifier = identifier
        self.buttonText = buttonText
        self.buttonImage = buttonImage
    }
}

public extension ALKNavigationItem {
    ///  Convenience initializer for creating `ALKNavigationItem` with text.
    ///
    /// - Parameters:
    ///   - identifier: A unique identifier, that will be part of the tap
    ///                 notification for identifying the tapped button.
    ///   - text: The text of this item.
    init(identifier: Int, text: String) {
        self.init(identifier: identifier, buttonText: text)
    }

    ///  Convenience initializer for creating `ALKNavigationItem` with an icon.
    ///
    /// - Parameters:
    ///   - identifier: A unique identifier, that will be part of the tap
    ///                 notification for identifying the tapped button.
    ///   - icon:  The icon of this item.
    init(identifier: Int, icon: UIImage) {
        self.init(identifier: identifier, buttonImage: icon)
    }
}

public extension ALKNavigationItem {
    func barButton(target: Any, action: Selector) -> UIBarButtonItem? {
        guard let image = buttonImage else {
            guard let text = buttonText else {
                return nil
            }
           
            if identifier == faqIdentifier {
                let customView = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 30))
                let btn = ExtendedTouchAreaButton(frame:CGRectMake(0.0, 0.0, 50.0, 30.0) )
                btn.isUserInteractionEnabled = true
                btn.setTitle(text, for: .normal)
                btn.backgroundColor = faqBackgroundColor
                btn.setTextColor(color: faqTextColor, forState: .normal)
                btn.layer.cornerRadius = 5
                btn.tag = faqIdentifier
                btn.addTarget(target, action: action, for: .touchUpInside)
                customView.addSubview(btn)
                let barButton = UIBarButtonItem(customView: customView)
                return barButton
            }
            let button = UIBarButtonItem(title: text, style: .plain, target: target, action: action)
            button.tag = identifier
            return button
        }

        let scaledImage = image.scale(with: CGSize(width: 25, height: 25))

        guard var buttonImage = scaledImage else {
            return nil
        }
        buttonImage = buttonImage.imageFlippedForRightToLeftLayoutDirection()
        let button = UIBarButtonItem(image: buttonImage, style: .plain, target: target, action: action)
        button.tag = identifier
        return button
    }
}

extension UIButton {
    func toBarButtonItem() -> UIBarButtonItem? {
        return UIBarButtonItem(customView: self)
    }
}

