//
//  ALKMessageButtonCell.swift
//  ApplozicSwift
//
//  Created by Shivam Pokhriyal on 10/01/19.
//

open class ALKMyMessageButtonCell: ALKChatBaseCell<ALKMessageViewModel> {
    var messageView = ALKMyMessageView()
    var buttonView = SuggestedReplyView()
    lazy var messageViewHeight = self.messageView.heightAnchor.constraint(equalToConstant: 0)

    override func setupViews() {
        super.setupViews()
        setupConstraints()
    }

    open func update(viewModel: ALKMessageViewModel, maxWidth: CGFloat) {
        self.viewModel = viewModel
        let messageWidth = maxWidth -
            (ChatCellPadding.SentMessage.Message.left + ChatCellPadding.SentMessage.Message.right)
        let height = ALKMyMessageView.rowHeight(viewModel: viewModel, width: messageWidth)
        messageViewHeight.constant = height
        messageView.update(viewModel: viewModel)

        guard let dict = viewModel.linkOrSubmitButton() else {
            buttonView.isHidden = true
            return
        }
        buttonView.isHidden = false
        let buttonWidth = maxWidth - (ChatCellPadding.SentMessage.MessageButton.left + ChatCellPadding.SentMessage.MessageButton.right)
        buttonView.update(model: dict, maxWidth: buttonWidth)
    }

    open override class func rowHeigh(viewModel: ALKMessageViewModel, width: CGFloat) -> CGFloat {
        let messageWidth = width -
            (ChatCellPadding.SentMessage.Message.left + ChatCellPadding.SentMessage.Message.right)
        let messageHeight = ALKMyMessageView.rowHeight(viewModel: viewModel, width: messageWidth)

        guard let dict = viewModel.linkOrSubmitButton() else {
            return messageHeight + 10 // Paddding
        }
        let buttonWidth = width - (ChatCellPadding.SentMessage.MessageButton.left + ChatCellPadding.SentMessage.MessageButton.right)
        let buttonHeight = SuggestedReplyView.rowHeight(model: dict, maxWidth: buttonWidth)
        return messageHeight
            + buttonHeight
            + ChatCellPadding.SentMessage.MessageButton.top
            + ChatCellPadding.SentMessage.MessageButton.bottom
    }

    private func setupConstraints() {
        contentView.addViewsForAutolayout(views: [messageView, buttonView])
        NSLayoutConstraint.activate([
            messageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            messageView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: ChatCellPadding.SentMessage.Message.left
            ),
            messageView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -1 * ChatCellPadding.SentMessage.Message.right
            ),
            messageViewHeight,

            buttonView.topAnchor.constraint(
                equalTo: messageView.bottomAnchor,
                constant: ChatCellPadding.SentMessage.MessageButton.top
            ),
            buttonView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -ChatCellPadding.SentMessage.MessageButton.right
            ),
            buttonView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            buttonView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -ChatCellPadding.SentMessage.MessageButton.bottom
            ),
        ])
    }
}

class ALKFriendMessageButtonCell: ALKChatBaseCell<ALKMessageViewModel> {
    var messageView = ALKFriendMessageView()
    var buttonView = SuggestedReplyView()
    lazy var messageViewHeight = self.messageView.heightAnchor.constraint(equalToConstant: 0)

    var buttonSelected: ((_ index: Int, _ name: String) -> Void)?

    override func setupViews() {
        super.setupViews()
        buttonView.delegate = self
        setupConstraints()
    }

    open func update(viewModel: ALKMessageViewModel, maxWidth: CGFloat) {
        self.viewModel = viewModel
        let messageWidth = maxWidth -
            (ChatCellPadding.ReceivedMessage.Message.left + ChatCellPadding.ReceivedMessage.Message.right)
        let height = ALKFriendMessageView.rowHeight(viewModel: viewModel, width: messageWidth)
        messageViewHeight.constant = height
        messageView.update(viewModel: viewModel)

        guard let dict = viewModel.linkOrSubmitButton() else {
            buttonView.isHidden = true
            return
        }
        buttonView.isHidden = false
        let buttonWidth = maxWidth - (ChatCellPadding.ReceivedMessage.MessageButton.left + ChatCellPadding.ReceivedMessage.MessageButton.right)
        buttonView.update(model: dict, maxWidth: buttonWidth)
    }

    open override class func rowHeigh(viewModel: ALKMessageViewModel, width: CGFloat) -> CGFloat {
        let messageWidth = width -
            (ChatCellPadding.ReceivedMessage.Message.left + ChatCellPadding.ReceivedMessage.Message.right)
        let messageHeight = ALKFriendMessageView.rowHeight(viewModel: viewModel, width: messageWidth)

        guard let dict = viewModel.linkOrSubmitButton() else {
            return messageHeight + 10 // Paddding
        }
        let buttonWidth = width - (ChatCellPadding.ReceivedMessage.MessageButton.left + ChatCellPadding.ReceivedMessage.MessageButton.right)
        let buttonHeight = SuggestedReplyView.rowHeight(model: dict, maxWidth: buttonWidth)
        return messageHeight
            + buttonHeight
            + ChatCellPadding.ReceivedMessage.MessageButton.top
            + ChatCellPadding.ReceivedMessage.MessageButton.bottom
    }

    private func setupConstraints() {
        contentView.addViewsForAutolayout(views: [messageView, buttonView])
        NSLayoutConstraint.activate([
            messageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            messageView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: ChatCellPadding.ReceivedMessage.Message.left
            ),
            messageView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -1 * ChatCellPadding.ReceivedMessage.Message.right
            ),
            messageViewHeight,

            buttonView.topAnchor.constraint(
                equalTo: messageView.bottomAnchor,
                constant: ChatCellPadding.ReceivedMessage.MessageButton.top
            ),
            buttonView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: ChatCellPadding.ReceivedMessage.MessageButton.left
            ),
            buttonView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            buttonView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -ChatCellPadding.ReceivedMessage.MessageButton.bottom
            ),
        ])
    }
}

extension ALKFriendMessageButtonCell: Tappable {
    func didTap(index: Int?, title: String) {
        guard let index = index, let buttonSelected = buttonSelected else { return }
        buttonSelected(index, title)
    }
}
