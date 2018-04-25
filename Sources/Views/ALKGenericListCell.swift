//
//  ALKGenericListCell.swift
//  ApplozicSwift
//
//  Created by Mukesh Thawani on 23/04/18.
//

import UIKit

class ALKGenericListCell: ALKChatBaseCell<ALKMessageViewModel> {

    open let itemBackgroundView: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.borderWidth = 0.5
        return view
    }()

    open let itemTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "title"
        label.numberOfLines = 3
        label.font = Font.bold(size: 16.0).font()
        label.textColor = UIColor.black
        return label
    }()

    open let itemDescriptionLabel: VerticalAlignLabel = {
        let label = VerticalAlignLabel()
        label.text = "DescriptionLabel"
        label.numberOfLines = 1
        label.font = Font.normal(size: 15.0).font()
        label.textColor = UIColor.gray
        return label
    }()

    open var itemLabelStackView: UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
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
            static var left: CGFloat = 0
            static var right: CGFloat = 0
        }
    }

    open var actionButtons = [UIButton]()
    open var template: ALKGenericListTemplate!
    open var buttonSelected: ((_ index: Int, _ name: String) -> ())?
    open var items = [ALKGenericListTemplate.Payload.Element]()
    open var itemsStackView = [UIStackView]()

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
        let buttonHeight = 30
        let baseHeight: CGFloat = 170
        let padding: CGFloat = 10
        let totalButtonHeight: CGFloat = CGFloat(buttonHeight * (template.payload.buttons.count))
        return baseHeight + totalButtonHeight + padding
    }

    open func update(template: ALKGenericListTemplate) {
        items = template.payload.elements
        addItemsToView(items: items)
        let buttons = template.payload.buttons
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
        view.addViewsForAutolayout(views: [mainStackView])

        mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Padding.mainStackView.left).isActive = true
        mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: Padding.mainStackView.right).isActive = true
        mainStackView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        mainStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: Padding.mainStackView.bottom).isActive = true

        buttonStackView.leadingAnchor.constraint(equalTo: mainStackView.leadingAnchor, constant: 0).isActive = true
    }

    private func updateViewFor(_ buttons: [ALKGenericListTemplate.Payload.Button]) {
        // Hide extra buttons
        actionButtons.enumerated().forEach {
            if $0 >= buttons.count { $1.isHidden = true }
            else { $1.setTitle(buttons[$0].title, for: .normal) }
        }
    }

    private func addItemsToView(
        items: [ALKGenericListTemplate.Payload.Element]) {
        items.forEach() {
            itemTitleLabel.text = $0.title
            itemDescriptionLabel.text = $0.description
            itemLabelStackView.addArrangedSubview(itemTitleLabel)
            itemLabelStackView.addArrangedSubview(itemDescriptionLabel)
            mainStackView.insertArrangedSubview(itemLabelStackView, at: 0)
        }
    }
}
