//
//  ALKFriendImageMessage.swift
//  ApplozicSwift
//
//  Created by Shivam Pokhriyal on 10/04/19.
//

import Foundation

class ALKFriendImageMessageCell: ALKChatBaseCell<ALKMessageViewModel> {

    let maxWidth = UIScreen.main.bounds.width
    static let padding = Padding(left: 10, right: 60, top: 10, bottom: 10)
    var imageMessageView: ImageMessageView

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        imageMessageView = ImageMessageView(frame: .zero, maxWidth: maxWidth, padding: ALKFriendImageMessageCell.padding, isMyMessage: false)
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func update(viewModel: ALKMessageViewModel) {

        let imageMessage = ImageMessage(with: viewModel)
        imageMessageView.update(model: imageMessage)
    }

    override class func rowHeigh(viewModel: ALKMessageViewModel, width: CGFloat) -> CGFloat {
        return ImageMessageView.rowHeight(model: ImageMessage(with: viewModel), maxWidth: width, padding: padding)
    }

    private func setupConstraints() {
        contentView.addViewsForAutolayout(views: [imageMessageView])
        imageMessageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        imageMessageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        imageMessageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        imageMessageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
    }
}
