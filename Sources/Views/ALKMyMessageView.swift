//
//  ALKMyMessageView.swift
//  ApplozicSwift
//
//  Created by Shivam Pokhriyal on 08/01/19.
//

/// A custom view which has text, time and state labels. And it's used in multiple cells.
class ALKMyMessageView: UIView {
    struct Padding {
        struct MessageView {
            static let top: CGFloat = 4
            static let bottom: CGFloat = 6
        }

        struct BubbleView {
            static let bottom: CGFloat = 2
        }

        struct StateView {
            static let bottom: CGFloat = 1
            static let right: CGFloat = 2
        }

        struct TimeLabel {
            static let right: CGFloat = 2
            static let bottom: CGFloat = 2
        }
    }

    fileprivate var widthPadding: CGFloat = CGFloat(ALKMessageStyle.sentBubble.widthPadding)
    fileprivate lazy var messageView: ALKHyperLabel = {
        let label = ALKHyperLabel(frame: .zero)
        label.isUserInteractionEnabled = true
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()

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

    fileprivate var bubbleView: UIImageView = {
        let bv = UIImageView()
        bv.clipsToBounds = true
        bv.isUserInteractionEnabled = false
        bv.isOpaque = true
        return bv
    }()

    init() {
        super.init(frame: .zero)
        setupConstraints()
        setupStyle()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupStyle() {
        if ALKMessageStyle.sentBubble.style == .edge {
            let image = UIImage(named: "chat_bubble_rounded", in: Bundle.applozic, compatibleWith: nil)
            bubbleView.tintColor = UIColor(netHex: 0xF1F0F0)
            bubbleView.image = image?.imageFlippedForRightToLeftLayoutDirection()
        } else {
            bubbleView.layer.cornerRadius = ALKMessageStyle.sentBubble.cornerRadius
            bubbleView.tintColor = ALKMessageStyle.sentBubble.color
            bubbleView.backgroundColor = ALKMessageStyle.sentBubble.color
        }
    }

    func update(viewModel: ALKMessageViewModel) {
        // Set message
        messageView.text = viewModel.message ?? ""
        messageView.setStyle(ALKMessageStyle.sentMessage)

        // Set time
        timeLabel.text = viewModel.time
        timeLabel.setStyle(ALKMessageStyle.time)

        setStatusStyle(status: viewModel.status, ALKMessageStyle.messageStatus)
    }

    class func rowHeight(viewModel: ALKMessageViewModel, width: CGFloat) -> CGFloat {
        let minimumHeight: CGFloat = 10 // Padding
        guard let message = viewModel.message else {
            return minimumHeight
        }
        let font = ALKMessageStyle.sentMessage.font
        var messageHeight = message.heightWithConstrainedWidth(width, font: font)
        messageHeight += 20 // (6 + 4) + 10 for extra padding
        return max(messageHeight, minimumHeight)
    }

    private func setupConstraints() {
        addViewsForAutolayout(views: [messageView, bubbleView, stateView, timeLabel])
        bringSubviewToFront(messageView)
        messageView.topAnchor.constraint(equalTo: topAnchor, constant: Padding.MessageView.top).isActive = true
        messageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        messageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1 * Padding.MessageView.bottom).isActive = true
        messageView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor).isActive = true

        bubbleView.leadingAnchor.constraint(equalTo: messageView.leadingAnchor, constant: -widthPadding).isActive = true
        bubbleView.trailingAnchor.constraint(equalTo: messageView.trailingAnchor, constant: widthPadding).isActive = true
        bubbleView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        bubbleView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1 * Padding.BubbleView.bottom).isActive = true
        stateView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -1 * Padding.StateView.bottom).isActive = true
        stateView.trailingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: -1 * Padding.StateView.right).isActive = true

        timeLabel.trailingAnchor.constraint(equalTo: stateView.leadingAnchor, constant: -1 * Padding.TimeLabel.right).isActive = true
        timeLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: Padding.TimeLabel.bottom).isActive = true
    }

    func setStatusStyle(
        status: MessageStatus,
        _ style: ALKMessageStyle.SentMessageStatus,
        _ size: CGSize = CGSize(width: 17, height: 9)
    ) {
        guard let statusIcon = style.statusIcons[status] else { return }
        switch statusIcon {
        case let .templateImageWithTint(image, tintColor):
            stateView.image = image
                .imageFlippedForRightToLeftLayoutDirection()
                .scale(with: size)?
                .withRenderingMode(.alwaysTemplate)
            stateView.tintColor = tintColor
        case let .normalImage(image):
            stateView.image = image
                .imageFlippedForRightToLeftLayoutDirection()
                .scale(with: size)?
                .withRenderingMode(.alwaysOriginal)
        case .none:
            stateView.image = nil
        }
    }
}
