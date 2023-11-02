//
//  KMFormMultiSelectButtonItemCell.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by sathyan elangovan on 21/03/23.
//

import Foundation
import UIKit
#if canImport(RichMessageKit)
    import RichMessageKit
#endif

class KMFormMultiSelectButtonItemCell: UITableViewCell {
    var cellSelected: (() -> Void)?
    var item: FormViewModelMultiselectItem.Option?
    var button = KMMultiSelectButton()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        addConstraints()
    }

    func update(item: FormViewModelMultiselectItem.Option, isChecked: Bool = false){
        self.item = item
        button.update(title: item.label,isSelected: isChecked)
        button.delegate = self
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func onSelection() {
        cellSelected?()
    }

    private func addConstraints() {
        addViewsForAutolayout(views: [button])
        button.layout {
            $0.leading == leadingAnchor + Size.nameLabel.leading
            $0.trailing == trailingAnchor + Size.nameLabel.trailing
            $0.top == topAnchor + Size.nameLabel.top
            $0.bottom <= bottomAnchor + Size.nameLabel.bottom
        }
        
    }
}

private extension KMFormMultiSelectButtonItemCell {
    enum Size {
        enum nameLabel {
            static let top: CGFloat = 5
            static let bottom: CGFloat = -5
            static let leading: CGFloat = 10
            static let trailing: CGFloat = -40
        }
    }
}

extension KMFormMultiSelectButtonItemCell: Tappable {
    func didTap(index: Int?, title: String) {
        cellSelected?()
    }
}
