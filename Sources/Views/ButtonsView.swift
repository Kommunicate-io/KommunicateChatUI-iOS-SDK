//
//  ButtonsView.swift
//  ApplozicSwift
//
//  Created by Shivam Pokhriyal on 17/01/19.
//

import Foundation

public struct MessageButtonConfig {
    public static var font = UIFont(name: "HelveticaNeue", size: 14) ?? UIFont.systemFont(ofSize: 14)

    public struct SubmitButton {
        public static var textColor = UIColor(red: 85, green: 83, blue: 183)
    }

    public struct LinkButton {
        public static var textColor = UIColor(red: 85, green: 83, blue: 183)
    }
}

public class ButtonsView: UIView {
    let font = MessageButtonConfig.font

    lazy var mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 2
        stackView.alignment = stackViewAlignment
        stackView.axis = .vertical
        stackView.distribution = .fill
        return stackView
    }()

    public var maxWidth: CGFloat!
    public var stackViewAlignment: UIStackView.Alignment = .leading {
        didSet {
            mainStackView.alignment = stackViewAlignment
        }
    }

    public var buttonSelected: ((_ index: Int, _ name: String) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func update(payload: [[String: Any]]) {
        mainStackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
        for index in 0 ..< payload.count {
            let dict = payload[index]
            var config = CurvedImageButton.Config()
            config.font = font
            guard let type = dict["type"] as? String, type == "link" else {
                // Submit button
                config.color = MessageButtonConfig.SubmitButton.textColor
                let name = dict["name"] as? String ?? ""
                let button = CurvedImageButton(title: name, config: config, maxWidth: maxWidth)
                mainStackView.addArrangedSubview(button)
                continue
            }
            // Link Button
            config.color = MessageButtonConfig.LinkButton.textColor
            let name = dict["name"] as? String ?? ""
            let image = UIImage(named: "link", in: Bundle.richMessageKit, compatibleWith: nil)
            let button = CurvedImageButton(title: name, image: image, config: config, maxWidth: maxWidth)
            mainStackView.addArrangedSubview(button)
        }
    }

    public class func rowHeight(payload: [[String: Any]], maxWidth: CGFloat) -> CGFloat {
        var height: CGFloat = 0
        var config = CurvedImageButton.Config()
        config.font = MessageButtonConfig.font
        for dict in payload {
            let title = dict["name"] as? String ?? ""
            var currHeight: CGFloat = 0
            if let type = dict["type"] as? String, type == "link" {
                config.color = MessageButtonConfig.LinkButton.textColor
                let image = UIImage(named: "link", in: Bundle.richMessageKit, compatibleWith: nil)
                currHeight = CurvedImageButton.buttonSize(text: title, image: image, maxWidth: maxWidth, config: config).height
            } else {
                config.color = MessageButtonConfig.SubmitButton.textColor
                currHeight = CurvedImageButton.buttonSize(text: title, maxWidth: maxWidth, config: config).height
            }
            height += currHeight + 2 // StackView spacing
        }
        return height
    }

    private func setupConstraints() {
        addViewsForAutolayout(views: [mainStackView])
        mainStackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        mainStackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        mainStackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        mainStackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
}
