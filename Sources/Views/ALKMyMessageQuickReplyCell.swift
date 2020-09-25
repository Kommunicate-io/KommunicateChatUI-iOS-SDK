//
//  ALKMyQuickReplyCell.swift
//  ApplozicSwift
//
//  Created by Shivam Pokhriyal on 08/01/19.
//

import Foundation

public class ALKMyMessageQuickReplyCell: ALKChatBaseCell<ALKMessageViewModel> {
    enum ViewPadding {
        enum StateView {
            static let bottom: CGFloat = 3
            static let right: CGFloat = 2
            static let height: CGFloat = 9
            static let width: CGFloat = 17
        }

        enum TimeLabel {
            static let right: CGFloat = 2
            static let left: CGFloat = 2
            static let bottom: CGFloat = 2
            static let maxWidth: CGFloat = 200
        }

        static let maxWidth = UIScreen.main.bounds.width
        static let messageViewPadding = Padding(left: ChatCellPadding.SentMessage.Message.left,
                                                right: ChatCellPadding.SentMessage.Message.right,
                                                top: 0,
                                                bottom: 0)
    }

    fileprivate var timeLabel: UILabel = {
        let lb = UILabel()
        lb.isOpaque = true
        return lb
    }()

    fileprivate var stateView: UIImageView = {
        let sv = UIImageView()
        sv.isUserInteractionEnabled = false
        sv.contentMode = .center
        return sv
    }()

    fileprivate lazy var timeLabelWidth = timeLabel.widthAnchor.constraint(equalToConstant: 0)
    fileprivate lazy var timeLabelHeight = timeLabel.heightAnchor.constraint(equalToConstant: 0)

    fileprivate lazy var messageView = MessageView(
        bubbleStyle: MessageTheme.sentMessage.bubble,
        messageStyle: MessageTheme.sentMessage.message,
        maxWidth: ViewPadding.maxWidth
    )
    var quickReplyView = SuggestedReplyView()
    lazy var messageViewHeight = self.messageView.heightAnchor.constraint(equalToConstant: 0)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func update(viewModel: ALKMessageViewModel, maxWidth: CGFloat) {
        super.update(viewModel: viewModel)

        let isMessageEmpty = viewModel.isMessageEmpty
        let model = viewModel.messageDetails()

        messageViewHeight.constant = isMessageEmpty ? 0 :
            SentMessageViewSizeCalculator().rowHeight(messageModel: model,
                                                      maxWidth: ViewPadding.maxWidth,
                                                      padding: ViewPadding.messageViewPadding)
        if !isMessageEmpty {
            messageView.update(model: model)
        }

        messageView.updateHeighOfView(hideView: isMessageEmpty, model: model)

        guard let suggestedReply = viewModel.suggestedReply() else {
            quickReplyView.isHidden = true
            return
        }
        let quickReplyViewWidth = maxWidth -
            (ChatCellPadding.SentMessage.QuickReply.left + ChatCellPadding.SentMessage.QuickReply.right)
        quickReplyView.update(model: suggestedReply, maxWidth: quickReplyViewWidth)

        // Set time
        timeLabel.text = viewModel.time
        timeLabel.setStyle(ALKMessageStyle.time)

        let timeLabelSize = viewModel.time!.rectWithConstrainedWidth(
            ViewPadding.TimeLabel.maxWidth,
            font: ALKMessageStyle.time.font
        )

        timeLabelHeight.constant = timeLabelSize.height.rounded(.up)
        timeLabelWidth.constant = timeLabelSize.width.rounded(.up)

        setStatusStyle(statusView: stateView, ALKMessageStyle.messageStatus)
    }

    public class func rowHeight(viewModel: ALKMessageViewModel, maxWidth: CGFloat) -> CGFloat {
        var height: CGFloat = 0
        let model = viewModel.messageDetails()

        let timeLabelSize = viewModel.time!.rectWithConstrainedWidth(
            ViewPadding.TimeLabel.maxWidth,
            font: ALKMessageStyle.time.font
        )

        if !viewModel.isMessageEmpty {
            height = SentMessageViewSizeCalculator().rowHeight(messageModel: model,
                                                               maxWidth: ViewPadding.maxWidth,
                                                               padding: ViewPadding.messageViewPadding)
        }

        guard let suggestedReplies = viewModel.suggestedReply() else {
            return height
        }

        let quickReplyViewWidth = maxWidth -
            (ChatCellPadding.SentMessage.QuickReply.left + ChatCellPadding.SentMessage.QuickReply.right)

        return height
            + SuggestedReplyView.rowHeight(model: suggestedReplies, maxWidth: quickReplyViewWidth)
            + ChatCellPadding.SentMessage.QuickReply.top
            + ChatCellPadding.SentMessage.QuickReply.bottom + timeLabelSize.height.rounded(.up) + ViewPadding.TimeLabel.bottom
    }

    private func setupConstraints() {
        contentView.addSubview(messageView)
        contentView.addViewsForAutolayout(views: [messageView, quickReplyView, stateView, timeLabel])
        NSLayoutConstraint.activate([
            messageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            messageView.leadingAnchor.constraint(
                greaterThanOrEqualTo: contentView.leadingAnchor,
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
            quickReplyView.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: ChatCellPadding.SentMessage.QuickReply.left),
            quickReplyView.bottomAnchor.constraint(
                equalTo: timeLabel.topAnchor,
                constant: -ChatCellPadding.SentMessage.QuickReply.bottom
            ),
            stateView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1 * ViewPadding.StateView.bottom),
            stateView.trailingAnchor.constraint(equalTo: quickReplyView.trailingAnchor, constant: -1 * ViewPadding.StateView.right),
            stateView.heightAnchor.constraint(equalToConstant: ViewPadding.StateView.height),
            stateView.widthAnchor.constraint(equalToConstant: ViewPadding.StateView.width),
            timeLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1 * ViewPadding.TimeLabel.bottom),
            timeLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: ViewPadding.TimeLabel.left),
            timeLabelWidth,
            timeLabelHeight,
            timeLabel.trailingAnchor.constraint(equalTo: stateView.leadingAnchor, constant: -1 * ViewPadding.TimeLabel.right),
        ])
    }
}
