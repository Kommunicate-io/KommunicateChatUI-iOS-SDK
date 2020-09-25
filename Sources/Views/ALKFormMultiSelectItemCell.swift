//
//  ALKFormMultiSelectItemCell.swift
//  ApplozicSwift
//
//  Created by Mukesh on 13/07/20.
//

import Foundation

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

    let nameLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = Font.medium(size: 17).font()
        label.textColor = .black
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
        accessoryType = (accessoryType == .none) ? .checkmark : .none
        cellSelected?()
    }

    private func addConstraints() {
        addViewsForAutolayout(views: [nameLabel])
        nameLabel.layout {
            $0.leading == leadingAnchor + Size.nameLabel.leading
            $0.trailing == trailingAnchor + Size.nameLabel.trailing
            $0.top == topAnchor + Size.nameLabel.top
            $0.bottom <= bottomAnchor + Size.nameLabel.bottom
        }
    }
}

private extension ALKFormMultiSelectItemCell {
    enum Size {
        enum nameLabel {
            static let top: CGFloat = 10
            static let bottom: CGFloat = -10
            static let leading: CGFloat = 10
            static let trailing: CGFloat = -40
        }
    }
}
