//
//  ALKChatBarConfiguration.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by Mukesh on 02/07/19.
//

import Foundation
import UIKit
#if canImport(RichMessageKit)
    import RichMessageKit
#endif

/// Types attachment that a user can send
public enum AttachmentType: CaseIterable, Equatable {
    case contact
    case camera
    case gallery
    case video
    /// Add your Google Map API key to view the map on the Conversation screen.
    /// Use `ALUserDefaultsHandler.setGoogleMapAPIKey(<Your-Google-Map-Api-Key>)`.
    case location
    case document
}

/// A type that can be used to configure chat bar items
/// like attachment icons and their visibility.
public struct ALKChatBarConfiguration {
    /// A combination of different `AttachmentType`s we support.
    public enum AttachmentOptions {
        case all
        case none
        case some([AttachmentType])
    }

    /// if true then Attachment Options Will be hidden when bot is handeling the conversartion. By Default the value is False.
    public var hideAttachmentOptionsForBotConvesations = false
    
    /// If true then button tint color will be disabled for attachment buttons, send button.
    public var disableButtonTintColor = false
    
    ///  If you set a color here then send button's tint color will be overridden by this color instead primary color.
    public var sendButtonTintColor: UIColor?
    
    /// If you want to hide chat bar form the conversation list screen.
    public var hideChatBarForBotConvesations: Bool = false

    /// Set the maximum number of photos/videos that can be selected in the new photos UI.
    /// Maximum limit should be less than 30
    public var photosSelectionLimit: Int = 10 {
        didSet {
            guard photosSelectionLimit < 1 || photosSelectionLimit > 30 else { return }
            print("Error: Photos selection limit should be set b/w 1 & 30")
            photosSelectionLimit = 10
        }
    }

    /// Use this to set the `AttachmentOptions` you want to show.
    /// By default it is set to `all`.
    public var optionsToShow: AttachmentOptions = .all

    /// Style for textview's text and placeholder
    public enum TextView {
        // DispatchQueue for thread safety
        private static let queue = DispatchQueue(label: "com.kommunicateChatUI.textView.configQueue")

        // Private stored properties
        private static var _placeholder = Style(
            font: Font.normal(size: 14).font(),
            text: .text(.gray9B)
        )

        private static var _text = Style(
            font: Font.normal(size: 16.0).font(),
            text: .text(.black00)
        )

        // Public computed properties with thread-safe access

        /// Style for placeholder.
        public static var placeholder: Style {
            get { accessProperty(&_placeholder) }
            set { updateProperty(&_placeholder, value: newValue) }
        }

        /// Style for text view.
        public static var text: Style {
            get { accessProperty(&_text) }
            set { updateProperty(&_text, value: newValue) }
        }

        // MARK: - Private Helper Methods

        /// Thread-safe property access
        private static func accessProperty(_ property: inout Style) -> Style {
            return queue.sync { property }
        }

        /// Thread-safe property update
        private static func updateProperty(_ property: inout Style, value: Style) {
            queue.sync { property = value }
        }
    }

    private(set) var attachmentIcons: [AttachmentType: UIImage?] = {
        // This way we'll get an error when we have added a
        // new option but its icon is not present.
        var icons = [AttachmentType: UIImage?]()
        for option in AttachmentType.allCases {
            switch option {
            case .contact:
                icons[.contact] = UIImage(named: "contactShare", in: Bundle.km, compatibleWith: nil)
            case .camera:
                icons[.camera] = UIImage(named: "photo", in: Bundle.km, compatibleWith: nil)
            case .gallery:
                icons[.gallery] = UIImage(named: "gallery", in: Bundle.km, compatibleWith: nil)
            case .video:
                icons[.video] = UIImage(named: "video", in: Bundle.km, compatibleWith: nil)
            case .location:
                icons[.location] = UIImage(named: "location_new", in: Bundle.km, compatibleWith: nil)
            case .document:
                icons[.document] = UIImage(named: "ic_alk_document", in: Bundle.km, compatibleWith: nil)
            }
        }
        return icons
    }()

    /// Sets the icon for the given attachment type.
    ///
    /// - Parameters:
    ///   - icon: The image to use for specific type.
    ///   - type: The type(`AttachmentType`) that uses the specified image.
    public mutating func set(
        attachmentIcon icon: UIImage?,
        for type: AttachmentType
    ) {
        guard let icon = icon else { return }
        attachmentIcons[type] = icon
    }
}

extension ALKChatBarConfiguration.AttachmentOptions: Equatable {
    public static func == (lhs: ALKChatBarConfiguration.AttachmentOptions, rhs: ALKChatBarConfiguration.AttachmentOptions) -> Bool {
        switch (lhs, rhs) {
        case (.none, .none):
            return true
        case (.all, .all):
            return true
        case let (.some(l), .some(r)):
            return l == r
        case (.all, _):
            return false
        case(.some, _):
            return false
        case(.none, _):
            return false
        }
    }
}
