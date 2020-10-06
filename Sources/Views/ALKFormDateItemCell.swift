//
//  ALKDateItemCell.swift
//  ApplozicSwift
//
//  Created by Sunil on 30/09/20.
//

import Foundation
import UIKit

class ALKFormDateItemCell: ALKFormDateBaseCell {
    var item: FormViewModelItem? {
        didSet {
            guard let item = item as? FormViewModelDateItem else {
                return
            }
            nameLabel.text = item.label
            valueTextField.attributedPlaceholder =
                NSAttributedString(string: Date.is24HrsFormate() ? Date.Formates.Date.twentyfour : Date.Formates.Date.twelve)
            valueTextField.placeholderColor = .lightGray
        }
    }
}

class ALKFormTimeItemCell: ALKFormDateBaseCell {
    var item: FormViewModelItem? {
        didSet {
            guard let item = item as? FormViewModelTimeItem else {
                return
            }
            nameLabel.text = item.label
            valueTextField.attributedPlaceholder =
                NSAttributedString(string: Date.is24HrsFormate() ? Date.Formates.Time.twentyfour : Date.Formates.Time.twelve)
            valueTextField.placeholderColor = .lightGray
        }
    }
}

class ALKFormDateTimeItemCell: ALKFormDateBaseCell {
    var item: FormViewModelItem? {
        didSet {
            guard let item = item as? FormViewModelDateTimeLocalItem else {
                return
            }
            nameLabel.text = item.label
            valueTextField.attributedPlaceholder =
                NSAttributedString(string: Date.is24HrsFormate() ? Date.Formates.DateAndTime.twentyfour : Date.Formates.DateAndTime.twelve)
            valueTextField.placeholderColor = .lightGray
        }
    }
}

class ALKFormDateBaseCell: UITableViewCell {
    let nameLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = Font.medium(size: 15).font()
        label.textColor = .black
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()

    let valueTextField: UITextField = {
        let textfield = UITextField(frame: .zero)
        textfield.isUserInteractionEnabled = true
        return textfield
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        valueTextField.textColor = .black
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
            $0.trailing == nameLabel.trailingAnchor
            $0.top == nameLabel.bottomAnchor + 5
            $0.bottom <= bottomAnchor - 10
        }
    }
}
