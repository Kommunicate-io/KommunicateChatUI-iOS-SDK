//
//  ALKMyQuickReplyCell.swift
//  ApplozicSwift
//
//  Created by Shivam Pokhriyal on 08/01/19.
//

import Foundation

class ALKMyQuickReplyCell: ALKChatBaseCell<ALKMessageViewModel> {

    var messageView = ALKMyMessageView()
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
            (QuickReplyConfig.SentMessage.MessagePadding.left + QuickReplyConfig.SentMessage.MessagePadding.right)
        let height = ALKMyMessageView.rowHeight(viewModel: viewModel, width: messageWidth)
        messageViewHeight.constant = height
        messageView.update(viewModel: viewModel)
        guard let quickReplyArray = viewModel.quickReplyDictionary() else {
            self.layoutIfNeeded()
            return
        }
        let quickReplyViewWidth = maxWidth -
            (QuickReplyConfig.SentMessage.QuickReplyPadding.left + QuickReplyConfig.SentMessage.QuickReplyPadding.right)
        updateQuickReplyView(quickReplyArray: quickReplyArray, height: height, width: quickReplyViewWidth)
        self.layoutIfNeeded()
    }

    class func rowHeight(viewModel: ALKMessageViewModel, maxWidth: CGFloat) -> CGFloat {
        let messageWidth = maxWidth -
            (QuickReplyConfig.SentMessage.MessagePadding.left + QuickReplyConfig.SentMessage.MessagePadding.right)
        let height = ALKMyMessageView.rowHeight(viewModel: viewModel, width: messageWidth)
        guard let quickReplyDict = viewModel.quickReplyDictionary() else {
            return height
        }
        let quickReplyViewWidth = maxWidth -
            (QuickReplyConfig.SentMessage.QuickReplyPadding.left + QuickReplyConfig.SentMessage.QuickReplyPadding.right)
        return height + ALKQuickReplyView.rowHeight(quickReplyArray: quickReplyDict, maxWidth: quickReplyViewWidth) + 20 // Padding between messages
    }

    private func setupConstraints() {
        self.contentView.addSubview(messageView)
        messageView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(quickReplyView)
        messageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        messageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: QuickReplyConfig.SentMessage.MessagePadding.left).isActive = true
        messageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -1 * QuickReplyConfig.SentMessage.MessagePadding.right).isActive = true
        messageViewHeight.isActive = true
    }

    private func updateQuickReplyView(quickReplyArray: [Dictionary<String, Any>], height: CGFloat, width: CGFloat) {
        quickReplyView.maxWidth = width
        quickReplyView.alignLeft = false
        quickReplyView.update(quickReplyArray: quickReplyArray)
        let quickReplyViewHeight = ALKQuickReplyView.rowHeight(quickReplyArray: quickReplyArray, maxWidth: width)

        quickReplyView.frame = CGRect(x: QuickReplyConfig.SentMessage.QuickReplyPadding.left,
                                      y: height + QuickReplyConfig.SentMessage.QuickReplyPadding.top,
                                      width: width,
                                      height: quickReplyViewHeight)
    }

}
