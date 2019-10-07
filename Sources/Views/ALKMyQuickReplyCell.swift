//
//  ALKMyQuickReplyCell.swift
//  ApplozicSwift
//
//  Created by Shivam Pokhriyal on 08/01/19.
//

import Foundation

public class ALKMyQuickReplyCell: ALKChatBaseCell<ALKMessageViewModel> {
    var messageView = ALKMyMessageView()
    var quickReplyView = SuggestedReplyView()
    lazy var messageViewHeight = self.messageView.heightAnchor.constraint(equalToConstant: 0)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupConstraints()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func update(viewModel: ALKMessageViewModel, maxWidth: CGFloat) {
        let messageWidth = maxWidth -
            (ChatCellPadding.SentMessage.Message.left + ChatCellPadding.SentMessage.Message.right)
        let height = ALKMyMessageView.rowHeight(viewModel: viewModel, width: messageWidth)
        messageViewHeight.constant = height
        messageView.update(viewModel: viewModel)
        guard let suggestedReply = viewModel.suggestedReply() else {
            quickReplyView.isHidden = true
            return
        }
        let quickReplyViewWidth = maxWidth -
            (ChatCellPadding.SentMessage.QuickReply.left + ChatCellPadding.SentMessage.QuickReply.right)
        quickReplyView.update(model: suggestedReply, maxWidth: quickReplyViewWidth)
    }

    public class func rowHeight(viewModel: ALKMessageViewModel, maxWidth: CGFloat) -> CGFloat {
        let messageWidth = maxWidth -
            (ChatCellPadding.SentMessage.Message.left + ChatCellPadding.SentMessage.Message.right)
        let height = ALKMyMessageView.rowHeight(viewModel: viewModel, width: messageWidth)
        guard let suggestedReplies = viewModel.suggestedReply() else {
            return height
        }
        let quickReplyViewWidth = maxWidth -
            (ChatCellPadding.SentMessage.QuickReply.left + ChatCellPadding.SentMessage.QuickReply.right)

        return height
            + SuggestedReplyView.rowHeight(model: suggestedReplies, maxWidth: quickReplyViewWidth)
            + ChatCellPadding.SentMessage.QuickReply.top
            + ChatCellPadding.SentMessage.QuickReply.top
    }

    private func setupConstraints() {
        contentView.addSubview(messageView)
        contentView.addViewsForAutolayout(views: [messageView, quickReplyView])
        NSLayoutConstraint.activate([
            messageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            messageView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: ChatCellPadding.SentMessage.Message.left
            ),
            messageView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -ChatCellPadding.SentMessage.Message.right
            ),
            messageViewHeight,

            quickReplyView.topAnchor.constraint(
                equalTo: messageView.bottomAnchor,
                constant: ChatCellPadding.SentMessage.QuickReply.top
            ),
            quickReplyView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -ChatCellPadding.SentMessage.QuickReply.right
            ),
            quickReplyView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            quickReplyView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -ChatCellPadding.SentMessage.QuickReply.bottom
            ),
        ])
    }
}
