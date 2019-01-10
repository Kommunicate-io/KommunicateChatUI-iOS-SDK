//
//  ALKFriendQuickReplyCell.swift
//  ApplozicSwift
//
//  Created by Shivam Pokhriyal on 07/01/19.
//

class ALKFriendQuickReplyCell: ALKChatBaseCell<ALKMessageViewModel> {

    var messageView = ALKFriendMessageView()
    var quickReplyView = ALKQuickReplyView(frame: .zero)
    lazy var messageViewHeight = self.messageView.heightAnchor.constraint(equalToConstant: 0)

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(viewModel: ALKMessageViewModel, maxWidth: CGFloat) {
        let messageWidth = maxWidth -
            (QuickReplyConfig.ReceivedMessage.MessagePadding.left + QuickReplyConfig.ReceivedMessage.MessagePadding.right)
        let height = ALKFriendMessageView.rowHeight(viewModel: viewModel, width: messageWidth)
        messageViewHeight.constant = height
        messageView.update(viewModel: viewModel)
        guard let quickReplyArray = viewModel.quickReplyDictionary() else {
            self.layoutIfNeeded()
            return
        }
        let quickReplyViewWidth = maxWidth -
            (QuickReplyConfig.ReceivedMessage.QuickReplyPadding.left + QuickReplyConfig.ReceivedMessage.QuickReplyPadding.right)
        updateQuickReplyView(quickReplyArray: quickReplyArray, height: height, width: quickReplyViewWidth)
        self.layoutIfNeeded()
    }

    class func rowHeight(viewModel: ALKMessageViewModel, maxWidth: CGFloat) -> CGFloat {
        let messageWidth = maxWidth -
            (QuickReplyConfig.ReceivedMessage.MessagePadding.left + QuickReplyConfig.ReceivedMessage.MessagePadding.right)
        let height = ALKFriendMessageView.rowHeight(viewModel: viewModel, width: messageWidth)
        guard let quickReplyDict = viewModel.quickReplyDictionary() else {
            return height
        }
        let quickReplyViewWidth = maxWidth -
            (QuickReplyConfig.ReceivedMessage.QuickReplyPadding.left + QuickReplyConfig.ReceivedMessage.QuickReplyPadding.right)
        return height + ALKQuickReplyView.rowHeight(quickReplyArray: quickReplyDict, maxWidth: quickReplyViewWidth) + 20 // Padding between messages
    }

    private func setupConstraints() {
        self.contentView.addSubview(messageView)
        messageView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(quickReplyView)
        messageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: QuickReplyConfig.ReceivedMessage.MessagePadding.top).isActive = true
        messageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: QuickReplyConfig.ReceivedMessage.MessagePadding.left).isActive = true
        messageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -1 * QuickReplyConfig.ReceivedMessage.MessagePadding.right).isActive = true
        messageViewHeight.isActive = true
    }

    private func updateQuickReplyView(quickReplyArray: [Dictionary<String, Any>], height: CGFloat, width: CGFloat) {
        quickReplyView.maxWidth = width
        quickReplyView.alignLeft = true
        quickReplyView.update(quickReplyArray: quickReplyArray)
        let quickReplyViewHeight = ALKQuickReplyView.rowHeight(quickReplyArray: quickReplyArray, maxWidth: width)

        quickReplyView.frame = CGRect(x: QuickReplyConfig.ReceivedMessage.QuickReplyPadding.left,
                                      y: height + QuickReplyConfig.ReceivedMessage.QuickReplyPadding.top,
                                      width: width,
                                      height: quickReplyViewHeight)
    }
}
