//
//  ALKFriendQuickReplyCell.swift
//  ApplozicSwift
//
//  Created by Shivam Pokhriyal on 07/01/19.
//

public class ALKFriendQuickReplyCell: ALKChatBaseCell<ALKMessageViewModel> {
    var messageView = ALKFriendMessageView()
    var quickReplyView = SuggestedReplyView()

    var quickReplySelected: ((_ index: Int, _ title: String) -> Void)?

    lazy var messageViewHeight = self.messageView.heightAnchor.constraint(equalToConstant: 0)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupConstraints()
        quickReplyView.delegate = self
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func update(viewModel: ALKMessageViewModel, maxWidth: CGFloat) {
        super.update(viewModel: viewModel)
        let messageWidth = maxWidth -
            (ChatCellPadding.ReceivedMessage.Message.left + ChatCellPadding.ReceivedMessage.Message.right)
        let height = ALKFriendMessageView.rowHeight(viewModel: viewModel, width: messageWidth)
        messageViewHeight.constant = height
        messageView.update(viewModel: viewModel)
        guard let suggestedReplies = viewModel.suggestedReply() else {
            quickReplyView.isHidden = true
            return
        }
        let quickReplyViewWidth = maxWidth -
            (ChatCellPadding.ReceivedMessage.QuickReply.left + ChatCellPadding.ReceivedMessage.QuickReply.right)
        quickReplyView.update(model: suggestedReplies, maxWidth: quickReplyViewWidth)
    }

    public class func rowHeight(viewModel: ALKMessageViewModel, maxWidth: CGFloat) -> CGFloat {
        let messageWidth = maxWidth -
            (ChatCellPadding.ReceivedMessage.Message.left + ChatCellPadding.ReceivedMessage.Message.right)
        let height = ALKFriendMessageView.rowHeight(viewModel: viewModel, width: messageWidth)
        guard let suggestedReplies = viewModel.suggestedReply() else {
            return height
        }
        let quickReplyViewWidth = maxWidth -
            (ChatCellPadding.ReceivedMessage.QuickReply.left + ChatCellPadding.ReceivedMessage.QuickReply.right)
        return height
            + SuggestedReplyView.rowHeight(model: suggestedReplies, maxWidth: quickReplyViewWidth)
            + ChatCellPadding.ReceivedMessage.QuickReply.top
            + ChatCellPadding.ReceivedMessage.QuickReply.bottom
    }

    private func setupConstraints() {
        contentView.addViewsForAutolayout(views: [messageView, quickReplyView])
        NSLayoutConstraint.activate([
            messageView.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: ChatCellPadding.ReceivedMessage.Message.top
            ),
            messageView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: ChatCellPadding.ReceivedMessage.Message.left
            ),
            messageView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -1 * ChatCellPadding.ReceivedMessage.Message.right
            ),
            messageViewHeight,

            quickReplyView.topAnchor.constraint(
                equalTo: messageView.bottomAnchor,
                constant: ChatCellPadding.ReceivedMessage.QuickReply.top
            ),
            quickReplyView.leadingAnchor.constraint(
                equalTo: messageView.leadingAnchor,
                constant: ChatCellPadding.ReceivedMessage.QuickReply.left
            ),
            quickReplyView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -ChatCellPadding.ReceivedMessage.QuickReply.right
            ),
            quickReplyView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -ChatCellPadding.ReceivedMessage.QuickReply.bottom
            ),
        ])
    }
}

extension ALKFriendQuickReplyCell: Tappable {
    public func didTap(index: Int?, title: String) {
        guard let quickReplySelected = quickReplySelected, let index = index else { return }
        quickReplySelected(index, title)
    }
}
