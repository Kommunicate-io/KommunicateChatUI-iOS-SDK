//
//  ALKGenericListCell.swift
//  ApplozicSwift
//
//  Created by Mukesh Thawani on 23/04/18.
//

import UIKit

class ALKGenericListCell: ALKChatBaseCell<ALKMessageViewModel> {

    open var itemTitleLabel: UILabel {
        let label = UILabel()
        label.text = "title"
        label.numberOfLines = 3
        label.font = Font.bold(size: 16.0).font()
        label.textColor = UIColor.black
        return label
    }

    open var itemDescriptionLabel: VerticalAlignLabel {
        let label = VerticalAlignLabel()
        label.text = "DescriptionLabel"
        label.numberOfLines = 1
        label.font = Font.normal(size: 15.0).font()
        label.textColor = UIColor.gray
        return label
    }

    open let mainBackgroundView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 5
        view.layer.borderColor = UIColor.gray.cgColor
        view.layer.borderWidth = 1
        return view
    }()

    open var itemLabelStackView: UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        return stackView
    }

    open let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        return stackView
    }()

    open let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 3.0
        return stackView
    }()

    public enum Padding {
        enum mainStackView {
            static var bottom: CGFloat = -20.0
            static var left: CGFloat = 10
            static var right: CGFloat = -10
        }
    }

    open var actionButtons = [UIButton]()
    open var template: ALKGenericListTemplate!
    open var buttonSelected: ((_ index: Int, _ name: String) -> ())?
    open var itemsStackView = [UIStackView]()

    private var items = [ALKGenericListTemplate.Element]()
    private var elementsAdded = false

    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func setupViews() {
        super.setupViews()
        setUpButtons()
        setUpViews()
    }

    open class func rowHeightFor(template: ALKGenericListTemplate) -> CGFloat {
        let elementHeight = 60
        let buttonHeight = 30
        let baseHeight: CGFloat = 10
        let padding: CGFloat = 10
        let elementsHeight: CGFloat = CGFloat(elementHeight * template.elements.count)
        let totalButtonHeight: CGFloat = CGFloat(buttonHeight * (template.buttons.count))
        return baseHeight + elementsHeight + totalButtonHeight + padding
    }

    open func update(template: ALKGenericListTemplate) {
        items = template.elements
        if !elementsAdded { addItemsToView(items: items) }
        let buttons = template.buttons
        guard !buttons.isEmpty else { return }
        updateViewFor(buttons)
    }

    @objc func buttonSelected(_ action: UIButton) {
        self.buttonSelected?(action.tag, action.currentTitle ?? "")
    }

    private func setUpButtons() {
        actionButtons = (1...3).map {
            let button = UIButton()
            button.setTitleColor(.gray, for: .normal)
            button.setFont(font: Font.bold(size: 16.0))
            button.setTitle("Button", for: .normal)
            button.addTarget(self, action: #selector(buttonSelected(_:)), for: .touchUpInside)
            button.layer.borderWidth = 1.0
            button.tag = $0
            button.layer.borderColor = UIColor.gray.cgColor
            return button
        }
    }

    private func setUpViews() {
        setupConstraints()
        backgroundColor = .clear
    }

    private func setupConstraints() {
        let view = contentView

        actionButtons.forEach {
            buttonStackView.addArrangedSubview($0)
            $0.heightAnchor.constraint(equalToConstant: 30).isActive = true
        }
        mainStackView.addArrangedSubview(buttonStackView)
        view.addViewsForAutolayout(views: [mainBackgroundView, mainStackView])

        mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Padding.mainStackView.left).isActive = true
        mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: Padding.mainStackView.right).isActive = true
        mainStackView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        mainStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: Padding.mainStackView.bottom).isActive = true

        mainBackgroundView.leadingAnchor.constraint(equalTo: mainStackView.leadingAnchor).isActive = true
        mainBackgroundView.trailingAnchor.constraint(equalTo: mainStackView.trailingAnchor).isActive = true
        mainBackgroundView.topAnchor.constraint(equalTo: mainStackView.topAnchor).isActive = true
        mainBackgroundView.bottomAnchor.constraint(equalTo: mainStackView.bottomAnchor).isActive = true

        buttonStackView.leadingAnchor.constraint(equalTo: mainStackView.leadingAnchor, constant: 0).isActive = true
    }

    private func updateViewFor(_ buttons: [ALKGenericListTemplate.Button]) {
        // Hide3 extra buttons
        actionButtons.enumerated().forEach {
            if $0 >= buttons.count { $1.isHidden = true }
            else { $1.setTitle(buttons[$0].title, for: .normal) }
        }
    }

    private func addItemsToView(
        items: [ALKGenericListTemplate.Element]) {
        items.enumerated().forEach() {
            let item = itemLabelStackView
            let itemTitle = itemTitleLabel
            let itemDescription = itemDescriptionLabel
            let borderView = UIView()
            borderView.backgroundColor = UIColor.borderGray()
            itemTitle.text = $1.title
            itemDescription.text = $1.description
            item.addArrangedSubview(itemTitle)
            item.addArrangedSubview(itemDescription)
            item.addArrangedSubview(borderView)
            itemTitle.heightAnchor.constraint(equalToConstant: 30).isActive = true
            itemDescription.heightAnchor.constraint(equalToConstant: 30).isActive = true
            borderView.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
            mainStackView.insertArrangedSubview(item, at: $0)
            item.leadingAnchor.constraint(equalTo: mainStackView.leadingAnchor, constant: 5).isActive = true
            item.trailingAnchor.constraint(equalTo: mainStackView.trailingAnchor, constant: -5).isActive = true
        }
        elementsAdded = true
    }
}
