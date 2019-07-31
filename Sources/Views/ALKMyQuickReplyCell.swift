//
//  ALKMyQuickReplyCell.swift
//  ApplozicSwift
//
//  Created by Shivam Pokhriyal on 08/01/19.
//

import Foundation

public class ALKMyQuickReplyCell: ALKChatBaseCell<ALKMessageViewModel> {

    var messageView = ALKMyMessageView()
    var quickReplyView = ALKQuickReplyView(frame: .zero)
    lazy var messageViewHeight = self.messageView.heightAnchor.constraint(equalToConstant: 0)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func update(viewModel: ALKMessageViewModel, maxWidth: CGFloat) {
        let messageWidth = maxWidth -
            (ChatCellPadding.SentMessage.Message.left + ChatCellPadding.SentMessage.Message.right)
        let height = ALKMyMessageView.rowHeight(viewModel: viewModel, width: messageWidth)
        messageViewHeight.constant = height
        messageView.update(viewModel: viewModel)
        guard let quickReplyArray = viewModel.payloadFromMetadata() else {
            quickReplyView.isHidden = true
            self.layoutIfNeeded()
            return
        }
        let quickReplyViewWidth = maxWidth -
            (ChatCellPadding.SentMessage.QuickReply.left + ChatCellPadding.SentMessage.QuickReply.right)
        updateQuickReplyView(quickReplyArray: quickReplyArray, height: height, width: quickReplyViewWidth)
        self.layoutIfNeeded()
    }

    public class func rowHeight(viewModel: ALKMessageViewModel, maxWidth: CGFloat) -> CGFloat {
        let messageWidth = maxWidth -
            (ChatCellPadding.SentMessage.Message.left + ChatCellPadding.SentMessage.Message.right)
        let height = ALKMyMessageView.rowHeight(viewModel: viewModel, width: messageWidth)
        guard let quickReplyDict = viewModel.payloadFromMetadata() else {
            return height
        }
        let quickReplyViewWidth = maxWidth -
            (ChatCellPadding.SentMessage.QuickReply.left + ChatCellPadding.SentMessage.QuickReply.right)
        return height + ALKQuickReplyView.rowHeight(quickReplyArray: quickReplyDict, maxWidth: quickReplyViewWidth) + 20 // Padding between messages
    }

    private func setupConstraints() {
        self.contentView.addSubview(messageView)
        messageView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(quickReplyView)
        messageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        messageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ChatCellPadding.SentMessage.Message.left).isActive = true
        messageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -1 * ChatCellPadding.SentMessage.Message.right).isActive = true
        messageViewHeight.isActive = true
    }

    private func updateQuickReplyView(quickReplyArray: [Dictionary<String, Any>], height: CGFloat, width: CGFloat) {
        quickReplyView.maxWidth = width
        quickReplyView.alignLeft = false
        quickReplyView.update(quickReplyArray: quickReplyArray)
        let quickReplyViewHeight = ALKQuickReplyView.rowHeight(quickReplyArray: quickReplyArray, maxWidth: width)

        var xPos = ChatCellPadding.SentMessage.QuickReply.left
        if UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft {
            xPos = ChatCellPadding.SentMessage.QuickReply.right
        }

        quickReplyView.frame = CGRect(x: xPos,
                                      y: height + ChatCellPadding.SentMessage.QuickReply.top,
                                      width: width,
                                      height: quickReplyViewHeight)
    }

}
