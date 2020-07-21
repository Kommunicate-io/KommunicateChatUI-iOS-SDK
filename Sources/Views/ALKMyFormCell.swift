//
//  ALKMyFormCell.swift
//  ApplozicSwift
//
//  Created by Mukesh on 13/07/20.
//

import Foundation

class ALKMyFormCell: ALKFormCell {
    enum Padding {
        enum StateView {
            static let top: CGFloat = 3
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
        lb.numberOfLines = 1
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
    lazy var messageViewHeight = messageView.heightAnchor.constraint(equalToConstant: 0)

    override func setupViews() {
        super.setupViews()
        setupConstraints()
    }

    override func update(viewModel: ALKMessageViewModel) {
        self.identifier = viewModel.identifier
        let isMessageEmpty = viewModel.isMessageEmpty
        let maxWidth = UIScreen.main.bounds.width
        let messageWidth = maxWidth - (ChatCellPadding.SentMessage.Message.left +
            ChatCellPadding.SentMessage.Message.right)
        messageViewHeight.constant = isMessageEmpty ? 0 : ALKMyMessageView.rowHeight(viewModel: viewModel, width: messageWidth)
        if !isMessageEmpty {
            messageView.update(viewModel: viewModel)
        }
        messageView.updateHeightOfView(hideView: isMessageEmpty, viewModel: viewModel, maxWidth: maxWidth)
        timeLabel.setStyle(ALKMessageStyle.time)
        timeLabel.text = viewModel.time
        let timeLabelSize = viewModel.time!.rectWithConstrainedWidth(
            Padding.TimeLabel.maxWidth,
            font: ALKMessageStyle.time.font
        )
        timeLabelHeight.constant = timeLabelSize.height.rounded(.up)
        timeLabelWidth.constant = timeLabelSize.width.rounded(.up)
        setStatusStyle(statusView: stateView, ALKMessageStyle.messageStatus)
        layoutIfNeeded()
        super.update(viewModel: viewModel)
    }

    private func setupConstraints() {
        addViewsForAutolayout(views: [
            messageView,
            itemListView,
            stateView,
            timeLabel
        ])
        stateView.topAnchor.constraint(equalTo: timeLabel.topAnchor, constant: Padding.StateView.top).isActive = true
        stateView.trailingAnchor.constraint(equalTo: itemListView.trailingAnchor, constant: -Padding.StateView.right).isActive = true
        stateView.heightAnchor.constraint(equalToConstant: Padding.StateView.height).isActive = true
        stateView.widthAnchor.constraint(equalToConstant: Padding.StateView.width).isActive = true
        timeLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Padding.TimeLabel.bottom).isActive = true
        timeLabelWidth.isActive = true
        timeLabelHeight.isActive = true
        timeLabel.trailingAnchor.constraint(equalTo: stateView.leadingAnchor, constant: -Padding.TimeLabel.right).isActive = true

        let leftPadding = ChatCellPadding.SentMessage.Message.left
        let rightPadding = ChatCellPadding.SentMessage.Message.right
        let widthPadding = CGFloat(ALKMessageStyle.sentBubble.widthPadding)
        let templateLeftPadding = ChatCellPadding.SentMessage.MessageButton.left
        let templateRightPadding = rightPadding - widthPadding
        messageViewHeight.isActive = true
        messageView.layout {
            $0.top == topAnchor
            $0.leading == leadingAnchor + leftPadding
            $0.trailing == trailingAnchor - rightPadding
        }
        itemListView.layout {
            $0.top == messageView.bottomAnchor + ChatCellPadding.SentMessage.MessageButton.top
            $0.bottom == timeLabel.topAnchor - ChatCellPadding.SentMessage.MessageButton.bottom
            $0.leading == leadingAnchor + templateLeftPadding
            $0.trailing == trailingAnchor - templateRightPadding
        }
    }
}
