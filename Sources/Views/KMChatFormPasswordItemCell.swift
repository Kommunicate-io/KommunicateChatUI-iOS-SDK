//
//  KMChatFormPasswordItemCell.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by Mukesh on 13/07/20.
//

import Foundation
import UIKit

class KMChatFormPasswordItemCell: UITableViewCell {
    var item: FormViewModelItem? {
        didSet {
            guard let item = item as? FormViewModelPasswordItem else {
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
        label.textColor = .kmDynamicColor(light: .black, dark: .white)
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()

    let valueTextField: KMPaddedTextField = {
        let textfield = KMPaddedTextField(frame: .zero)
        textfield.isSecureTextEntry = true
        textfield.layer.borderColor = UIColor(netHex: 0xDCDCDC).cgColor
        textfield.layer.borderWidth = 2
        textfield.layer.cornerRadius = 4.0
        textfield.textPadding = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        return textfield
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
        addViewsForAutolayout(views: [nameLabel, valueTextField])
        nameLabel.layout {
            $0.leading == leadingAnchor + 10
            $0.trailing == trailingAnchor - 30
            $0.top == topAnchor + 10
        }
        valueTextField.layout {
            $0.leading == nameLabel.leadingAnchor
            $0.trailing == trailingAnchor - 15
            $0.top == nameLabel.bottomAnchor + 5
            $0.bottom <= bottomAnchor - 10
        }
    }
}
