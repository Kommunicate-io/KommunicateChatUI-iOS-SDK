//
//  KMTagView.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by sathyan elangovan on 21/11/22.
//

import Foundation
import UIKit

public struct Paddingg {
    let left: CGFloat
    let right: CGFloat
    let top: CGFloat
    let bottom: CGFloat

    public init(left: CGFloat, right: CGFloat, top: CGFloat, bottom: CGFloat) {
        self.left = left
        self.right = right
        self.top = top
        self.bottom = bottom
    }
}

protocol ColorProtocoll {
    static func setPrimaryColor(primaryColor: UIColor)
}

public class KMTagView: UIView {

    public struct Config {
 
        public var padding = Padding(left: 14, right: 14, top: 8, bottom: 8)
        public var textImageSpace: CGFloat = 10

        var spaceWithoutText: CGFloat {
            return padding.left + padding.right + textImageSpace
        }
        var minWidth: CGFloat = 30
        var minHeight: CGFloat = 25

        public init() {}
    }

    public var index: Int?
    
    let title: String
    let maxWidth: CGFloat
    var config: Config

    private let label = UILabel()

    public init(title: String,
                config: Config = Config(),
                maxWidth: CGFloat = UIScreen.main.bounds.width)
    {
        self.title = title
        self.config = config
        self.maxWidth = maxWidth
        super.init(frame: .zero)
        setupView()
        setupConstraint()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func labelWidth() -> CGFloat {
        let titleWidth =
            title.rectWithConstrainedWidth(maxWidth - config.spaceWithoutText, font: UIFont.systemFont(ofSize: 12)).width.rounded(.up)
        let labelWidth = titleWidth + config.spaceWithoutText
        return max(labelWidth, config.minWidth)
    }

    public func labelHeight() -> CGFloat {
        let titleHeight =
            title.rectWithConstrainedWidth(maxWidth - config.spaceWithoutText, font: KMTagView.TagLabelStyle.shared.font).height.rounded(.up)
        let labelHeight = titleHeight + config.padding.top + config.padding.bottom
        return max(labelHeight, config.minHeight)
    }

    public class func labelSize(text: String,
                                 image: UIImage? = nil,
                                 maxWidth: CGFloat = UIScreen.main.bounds.width,
                                 config: Config = Config()) -> CGSize
    {
        var config = config
        let textSize = text.rectWithConstrainedWidth(maxWidth - config.spaceWithoutText,
                                                     font: KMTagView.TagLabelStyle.shared.font)
        let labelWidth = textSize.width.rounded(.up)
        let labelHeight = textSize.height.rounded(.up) + config.padding.top + config.padding.bottom
        return CGSize(width: max(labelWidth + config.spaceWithoutText, config.minWidth),
                      height: max(labelHeight, config.minHeight))
    }

    private func setupView() {
        let style = KMTagView.TagLabelStyle.shared
        backgroundColor = style.labelColor.background
        layer.cornerRadius = style.cornerRadius
        clipsToBounds = true

        label.text = title
        label.textColor = style.labelColor.text
        label.font = style.font
        label.numberOfLines = 1
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center

        frame.size = CGSize(width: labelWidth(), height: labelHeight())
    }

    private func setupConstraint() {
        addViewsForAutolayout(views: [label])

        NSLayoutConstraint.activate([

            label.leadingAnchor.constraint(equalTo: leadingAnchor,
                                           constant: config.padding.left),
            label.trailingAnchor.constraint(equalTo: trailingAnchor,
                                            constant: -config.padding.right),
            label.topAnchor.constraint(equalTo: topAnchor,
                                       constant: config.padding.top),
            label.bottomAnchor.constraint(equalTo: bottomAnchor,
                                          constant: -config.padding.bottom),
        ])
    }
}

extension KMTagView {
    public struct TagLabelStyle: ColorProtocoll {
        static var shared = TagLabelStyle()

        static func setPrimaryColor(primaryColor: UIColor) {
            TagLabelStyle.shared.setColor(primaryColor)
        }

        mutating func setColor(_ color: UIColor) {
            labelColor.text = color
        }
        
        struct Color {
            var text = UIColor(red: 60.0 / 255.0, green: 75.0 / 255.0, blue: 80 / 255.0, alpha: 1.0)
            var background = UIColor(red: 231.0 / 255.0, green: 234.0 / 255.0, blue: 242 / 255.0, alpha: 1.0)
        }
        
        public var font = UIFont.systemFont(ofSize: 12)
        public var cornerRadius: CGFloat = 3
        var labelColor = Color()
    }
}

