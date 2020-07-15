//
//  ALKFormSingleSelectItemCell.swift
//  ApplozicSwift
//
//  Created by Mukesh on 13/07/20.
//

import Foundation

class ALKFormSingleSelectItemCell: UITableViewCell {
    var cellSelected: (() -> Void)?
    var item: FormViewModelSingleselectItem.Option? {
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
        label.numberOfLines = 1
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

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func onSelection() {
        cellSelected?()
    }

    private func addConstraints() {
        addViewsForAutolayout(views: [nameLabel])
        nameLabel.layout {
            $0.leading == leadingAnchor + 10
            $0.trailing == trailingAnchor - 30
            $0.top == topAnchor + 10
            $0.bottom <= bottomAnchor - 10
        }
    }
}
