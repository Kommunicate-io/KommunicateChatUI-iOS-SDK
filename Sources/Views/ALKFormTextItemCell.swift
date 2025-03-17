//
//  ALKFormTextItemCell.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by Mukesh on 08/07/20.
//

import UIKit

class ALKFormTextItemCell: UITableViewCell {
    var item: FormViewModelItem? {
        didSet {
            guard let item = item as? FormViewModelTextItem else {
                return
            }
            nameLabel.text = item.label
            valueTextField.attributedPlaceholder =
                NSAttributedString(string: item.placeholder ?? "")
            valueTextField.placeholderColor = .lightGray
        }
    }

    let nameLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = Font.medium(size: 15).font()
        label.textColor = UIColor.kmDynamicColor(light: .black, dark: .white)
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()

    let valueTextField: KMPaddedTextField = {
        let textfield = KMPaddedTextField(frame: .zero)
        textfield.layer.borderColor = UIColor(netHex: 0xDCDCDC).cgColor
        textfield.layer.borderWidth = 2
        textfield.layer.cornerRadius = 4.0
        textfield.textPadding = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        return textfield
    }()

    private lazy var errorStackView: UIStackView = {
        let labelStackView = UIStackView()
        labelStackView.axis = .horizontal
        labelStackView.alignment = .fill
        labelStackView.distribution = .fillEqually
        labelStackView.backgroundColor = UIColor.clear
        return labelStackView
    }()

    let errorLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = .red
        label.font = Font.normal(size: 15).font()
        label.textAlignment = .left
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        valueTextField.textColor = .kmDynamicColor(light: .black, dark: .white)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        addConstraints()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addConstraints() {
        addViewsForAutolayout(views: [nameLabel, valueTextField, errorStackView])
        errorStackView.addArrangedSubview(errorLabel)
        errorStackView.bringSubviewToFront(errorLabel)
        nameLabel.layout {
            $0.leading == leadingAnchor + 10
            $0.trailing == trailingAnchor - 30
            $0.top == topAnchor + 10
        }
        valueTextField.layout {
            $0.leading == nameLabel.leadingAnchor
            $0.trailing == trailingAnchor - 15
            $0.top == nameLabel.bottomAnchor + 5
        }
        errorStackView.layout {
            $0.leading == nameLabel.leadingAnchor
            $0.trailing == nameLabel.trailingAnchor
            $0.top == valueTextField.bottomAnchor + 5
            $0.bottom <= bottomAnchor - 10
        }
    }
}

class ALKFormTextAreaItemCell: UITableViewCell {
    var item: FormViewModelItem? {
        didSet {
            guard let item = item as? FormViewModelTextAreaItem else {
                return
            }
            nameLabel.text = item.title
            valueTextField.text = item.placeholder
            valueTextField.textColor = .lightGray
        }
    }

    let nameLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = Font.medium(size: 15).font()
        label.textColor = UIColor.kmDynamicColor(light: .black, dark: .white)
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()

    let valueTextField: KMPaddedTextView = {
        let textfield = KMPaddedTextView(frame: .zero)
        textfield.font = Font.normal(size: 17).font()
        textfield.backgroundColor = UIColor.clear
        textfield.layer.borderColor = UIColor(netHex: 0xDCDCDC).cgColor
        textfield.layer.borderWidth = 2
        textfield.layer.cornerRadius = 4.0
        return textfield
    }()

    private lazy var errorStackView: UIStackView = {
        let labelStackView = UIStackView()
        labelStackView.axis = .horizontal
        labelStackView.alignment = .fill
        labelStackView.distribution = .fillEqually
        labelStackView.backgroundColor = UIColor.clear
        return labelStackView
    }()

    let errorLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = .red
        label.font = Font.normal(size: 15).font()
        label.textAlignment = .left
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        valueTextField.textColor = .black
        contentView.backgroundColor = .kmDynamicColor(light: .white, dark: UIColor.appBarDarkColor())
        addConstraints()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addConstraints() {
        addViewsForAutolayout(views: [nameLabel, valueTextField, errorStackView])
        valueTextField.heightAnchor.constraint(equalToConstant: 80).isActive = true
        errorStackView.addArrangedSubview(errorLabel)
        errorStackView.bringSubviewToFront(errorLabel)
        nameLabel.layout {
            $0.leading == leadingAnchor + 10
            $0.trailing == trailingAnchor - 30
            $0.top == topAnchor + 10
        }
        valueTextField.layout {
            $0.leading == nameLabel.leadingAnchor
            $0.trailing == trailingAnchor - 15
            $0.top == nameLabel.bottomAnchor + 10
        }
        errorStackView.layout {
            $0.leading == nameLabel.leadingAnchor
            $0.trailing == nameLabel.trailingAnchor
            $0.top == valueTextField.bottomAnchor + 10
            $0.bottom <= bottomAnchor - 10
        }
    }
}

class ALKFormItemHeaderView: UITableViewHeaderFooterView {
    var item: FormViewModelItem? {
        didSet {
            guard let item = item else {
                return
            }
            titleLabel.text = item.sectionTitle
        }
    }

    var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = Font.normal(size: 17).font()
        label.textColor = .kmDynamicColor(light: .text(.gray7E), dark: .text(.grayCC))
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        addConstraints()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addConstraints() {
        addViewsForAutolayout(views: [titleLabel])
        titleLabel.layout {
            $0.leading == leadingAnchor + 10
            $0.trailing == trailingAnchor - 30
            $0.top == topAnchor + 10
            $0.bottom <= bottomAnchor - 10
        }
    }
}

class KMPaddedTextField: UITextField {

    var textPadding = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textPadding)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textPadding)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textPadding)
    }
}

class KMPaddedTextView: UITextView {

    var textPadding: UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8) {
        didSet {
            textContainerInset = textPadding
        }
    }

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        textContainerInset = textPadding
    }
}
