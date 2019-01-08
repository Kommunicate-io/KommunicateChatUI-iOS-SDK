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

    override func update(viewModel: ALKMessageViewModel) {
        let height = ALKFriendMessageView.rowHeight(viewModel: viewModel, width: UIScreen.main.bounds.width - 100)
        messageViewHeight.constant = height
        messageView.update(viewModel: viewModel)
        guard let quickReplyArray = viewModel.quickReplyDictionary() else {
            self.layoutIfNeeded()
            return
        }
        quickReplyView.update(quickReplyArray: quickReplyArray)
        quickReplyView.frame = CGRect(x: 60, y: height + 10, width: (UIScreen.main.bounds.width - 100), height: ALKQuickReplyView.rowHeight(quickReplyArray: quickReplyArray))
        self.layoutIfNeeded()
    }

    private func setupConstraints() {
        self.contentView.addSubview(messageView)
        messageView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(quickReplyView)
        messageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4).isActive = true
        messageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0).isActive = true
        messageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -95).isActive = true
        messageViewHeight.isActive = true
    }

    class func rowHeight(viewModel: ALKMessageViewModel) -> CGFloat {
        let height = ALKFriendMessageView.rowHeight(viewModel: viewModel, width: UIScreen.main.bounds.width - 100)
        guard let quickReplyDict = viewModel.quickReplyDictionary() else {
            return height
        }
        return height + ALKQuickReplyView.rowHeight(quickReplyArray: quickReplyDict) + 20 // Padding between messages
    }

}
