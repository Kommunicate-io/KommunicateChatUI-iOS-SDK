//
//  ALKFormMultiSelectItemCell.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by Mukesh on 13/07/20.
//

import Foundation
import UIKit

class ALKFormMultiSelectItemCell: UITableViewCell {
    var cellSelected: (() -> Void)?
    var item: FormViewModelMultiselectItem.Option? {
        didSet {
            guard let item = item else {
                return
            }
            nameLabel.text = item.label
        }
    }
    
    var isSelectedCell: Bool = false
    
    let checkBoxImage: UIImageView = {
       let image = UIImageView()
        image.image = UIImage(named: "checkbox_unchecked", in: Bundle.km, compatibleWith: nil)
        return image
    }()

    let nameLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = Font.medium(size: 17).font()
        label.textColor = .kmDynamicColor(light: .black, dark: .white)
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onSelection))
        contentView.addGestureRecognizer(tapRecognizer)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        addConstraints()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func onSelection() {
        isSelectedCell = !isSelectedCell
        if isSelectedCell == true {
            checkBoxImage.image = UIImage(named: "checkbox_checked", in: Bundle.km, compatibleWith: nil)
        } else {
            checkBoxImage.image = UIImage(named: "checkbox_unchecked", in: Bundle.km, compatibleWith: nil)
        }
        cellSelected?()
    }

    private func addConstraints() {
        addViewsForAutolayout(views: [checkBoxImage, nameLabel])
        NSLayoutConstraint.activate([
            checkBoxImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Size.CheckBoxImage.leading),
            checkBoxImage.centerYAnchor.constraint(equalTo: centerYAnchor),
            checkBoxImage.heightAnchor.constraint(equalToConstant: Size.CheckBoxImage.height),
            checkBoxImage.widthAnchor.constraint(equalToConstant: Size.CheckBoxImage.width),
            nameLabel.leadingAnchor.constraint(equalTo: checkBoxImage.trailingAnchor, constant: Size.NameLabel.leading),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: Size.NameLabel.trailing),
            nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: Size.NameLabel.top),
            nameLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: Size.NameLabel.bottom)
            ])
    }
}

private extension ALKFormMultiSelectItemCell {
    enum Size {
        enum NameLabel {
            static let top: CGFloat = 10
            static let bottom: CGFloat = -10
            static let leading: CGFloat = 10
            static let trailing: CGFloat = -40
        }
        enum CheckBoxImage {
            static let leading: CGFloat = 10
            static let height: CGFloat = 25
            static let width: CGFloat = 25
        }
    }
}
