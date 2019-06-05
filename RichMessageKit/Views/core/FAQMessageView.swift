//
//  FAQMessageView.swift
//  ApplozicSwift
//
//  Created by Shivam Pokhriyal on 03/06/19.
//

import UIKit

public class FAQMessageView: UIView {

    fileprivate let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()

    fileprivate let descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()

    fileprivate let bubbleView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.borderColor = UIColor.gray.cgColor
        view.layer.borderWidth = 2
        return view
    }()

    fileprivate let buttonLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()

    fileprivate lazy var buttons = SuggestedReplyView(config: SuggestedReplyView.SuggestedReplyConfig(), delegate: self)

    fileprivate let style: FAQMessageStyle
    fileprivate let alignLeft: Bool

    fileprivate lazy var titleHeight = titleLabel.heightAnchor.constraint(equalToConstant: 0)
    fileprivate lazy var descriptionHeight = descriptionLabel.heightAnchor.constraint(equalToConstant: 0)
    fileprivate lazy var buttonLabelHeight = buttonLabel.heightAnchor.constraint(equalToConstant: 0)

    public static var verticalSpacing: CGFloat = 5

    public var faqSelected: ((_ index: Int?, _ title: String) -> Void)?

    public init(frame: CGRect, faqStyle: FAQMessageStyle, alignLeft: Bool) {
        style = faqStyle
        self.alignLeft = alignLeft
        super.init(frame: frame)
        setupStyle()
        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func update(model: FAQMessage, maxWidth: CGFloat) {
        let width = maxWidth - (style.bubble.padding.left + style.bubble.padding.right)
        titleLabel.text = model.title
        titleHeight.constant = model.title?.heightWithConstrainedWidth(width, font: style.title.font) ?? 0
        descriptionLabel.text = model.description
        descriptionHeight.constant = model.description?.heightWithConstrainedWidth(width, font: style.description.font) ?? 0
        buttonLabel.text = model.buttonLabel
        buttonLabelHeight.constant = model.buttonLabel?.heightWithConstrainedWidth(maxWidth, font: style.buttonLabel.font) ?? 0
        buttons.update(model: SuggestedReplyMessage(title: model.buttons, reply: model.buttons, message: model.message))
    }

    public class func rowHeight(model: FAQMessage, maxWidth: CGFloat, style: FAQMessageStyle) -> CGFloat {
        let padding = style.bubble.padding
        let width = maxWidth - (padding.left + padding.right)
        let buttonModel = SuggestedReplyMessage(title: model.buttons, reply: model.buttons, message: model.message)
        let buttonHeight = SuggestedReplyView.rowHeight(model: buttonModel, maxWidth: maxWidth) + 2 * verticalSpacing
        let titleHeight = (model.title?.heightWithConstrainedWidth(width, font: style.title.font) ?? 0) + style.bubble.padding.top + verticalSpacing
        let descriptionHeight = (model.description?.heightWithConstrainedWidth(width, font: style.description.font) ?? 0) + style.bubble.padding.bottom + verticalSpacing
        let buttonLabelHeight = (model.buttonLabel?.heightWithConstrainedWidth(maxWidth, font: style.buttonLabel.font) ?? 0) + verticalSpacing
        return buttonHeight + titleHeight + descriptionHeight + buttonLabelHeight
    }

    private func setupStyle() {
        titleLabel.setStyle(style.title)
        descriptionLabel.setStyle(style.description)
        buttonLabel.setStyle(style.buttonLabel)
        bubbleView.backgroundColor = style.bubble.color
        bubbleView.layer.cornerRadius = style.bubble.cornerRadius
    }

    private func setupConstraints() {
        bubbleView.addViewsForAutolayout(views: [titleLabel, descriptionLabel])
        self.addViewsForAutolayout(views: [bubbleView, buttonLabel, buttons])
        let padding = style.bubble.padding

        if alignLeft {
            buttonLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        } else {
            buttonLabel.leadingAnchor.constraint(greaterThanOrEqualTo: self.leadingAnchor).isActive = true
        }

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: padding.left),
            titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -1 * padding.right),
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: padding.top),
            titleHeight,

            descriptionLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: padding.left),
            descriptionLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -1 * padding.right),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: FAQMessageView.verticalSpacing),
            descriptionHeight,

            bubbleView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            bubbleView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            bubbleView.topAnchor.constraint(equalTo: self.topAnchor),
            bubbleView.bottomAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: padding.bottom),

            buttonLabel.topAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: FAQMessageView.verticalSpacing),
            buttonLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            buttonLabelHeight,

            buttons.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            buttons.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            buttons.topAnchor.constraint(equalTo: buttonLabel.bottomAnchor, constant: FAQMessageView.verticalSpacing),
            buttons.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -FAQMessageView.verticalSpacing)
            ])
    }
}

extension FAQMessageView: Tappable {
    public func didTap(index: Int?, title: String) {
        guard let faqSelected = faqSelected else {
            print("❌❌❌ To handle faq click please use faqSelected.❌❌❌")
            return
        }
        faqSelected(index, title)
    }
}
