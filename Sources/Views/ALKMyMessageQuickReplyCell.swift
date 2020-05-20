//
//  ALKMyQuickReplyCell.swift
//  ApplozicSwift
//
//  Created by Shivam Pokhriyal on 08/01/19.
//

import Foundation

public class ALKMyMessageQuickReplyCell: ALKChatBaseCell<ALKMessageViewModel> {
    enum Padding {
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
        super.update(viewModel: viewModel)

        let isMessageEmpty = viewModel.isMessageEmpty

        let messageWidth = maxWidth -
            (ChatCellPadding.SentMessage.Message.left + ChatCellPadding.SentMessage.Message.right)

        messageViewHeight.constant = isMessageEmpty ? 0 : ALKMyMessageView.rowHeight(viewModel: viewModel, width: messageWidth)
        if !isMessageEmpty {
            messageView.update(viewModel: viewModel)
        }

        messageView.updateHeightOfView(hideView: isMessageEmpty, viewModel: viewModel, maxWidth: maxWidth)

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
            Padding.TimeLabel.maxWidth,
            font: ALKMessageStyle.time.font
        )

        timeLabelHeight.constant = timeLabelSize.height.rounded(.up)
        timeLabelWidth.constant = timeLabelSize.width.rounded(.up)

        setStatusStyle(statusView: stateView, ALKMessageStyle.messageStatus)
    }

    public class func rowHeight(viewModel: ALKMessageViewModel, maxWidth: CGFloat) -> CGFloat {
        var height: CGFloat = 0

        let timeLabelSize = viewModel.time!.rectWithConstrainedWidth(
            Padding.TimeLabel.maxWidth,
            font: ALKMessageStyle.time.font
        )

        if !viewModel.isMessageEmpty {
            let messageWidth = maxWidth -
                (ChatCellPadding.SentMessage.Message.left + ChatCellPadding.SentMessage.Message.right)
            height = ALKMyMessageView.rowHeight(viewModel: viewModel, width: messageWidth)
        }

        guard let suggestedReplies = viewModel.suggestedReply() else {
            return height
        }

        let quickReplyViewWidth = maxWidth -
            (ChatCellPadding.SentMessage.QuickReply.left + ChatCellPadding.SentMessage.QuickReply.right)

        return height
            + SuggestedReplyView.rowHeight(model: suggestedReplies, maxWidth: quickReplyViewWidth)
            + ChatCellPadding.SentMessage.QuickReply.top
            + ChatCellPadding.SentMessage.QuickReply.bottom + timeLabelSize.height.rounded(.up) + Padding.TimeLabel.bottom
    }

    private func setupConstraints() {
        contentView.addSubview(messageView)
        contentView.addViewsForAutolayout(views: [messageView, quickReplyView, stateView, timeLabel])
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
            quickReplyView.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: ChatCellPadding.SentMessage.QuickReply.left),
            quickReplyView.bottomAnchor.constraint(
                equalTo: timeLabel.topAnchor,
                constant: -ChatCellPadding.SentMessage.QuickReply.bottom
            ),
            stateView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1 * Padding.StateView.bottom),
            stateView.trailingAnchor.constraint(equalTo: quickReplyView.trailingAnchor, constant: -1 * Padding.StateView.right),
            stateView.heightAnchor.constraint(equalToConstant: Padding.StateView.height),
            stateView.widthAnchor.constraint(equalToConstant: Padding.StateView.width),
            timeLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1 * Padding.TimeLabel.bottom),
            timeLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: Padding.TimeLabel.left),
            timeLabelWidth,
            timeLabelHeight,
            timeLabel.trailingAnchor.constraint(equalTo: stateView.leadingAnchor, constant: -1 * Padding.TimeLabel.right),
        ])
    }
}
