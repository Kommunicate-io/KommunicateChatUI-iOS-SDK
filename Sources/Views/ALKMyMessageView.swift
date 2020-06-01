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

    enum ConstraintIdentifier {
        enum MessageView {
            static let height = "MessageViewHeight"
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

    fileprivate var bubbleView: ALKImageView = {
        let bv = ALKImageView()
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
        bubbleView.setStyle(ALKMessageStyle.sentBubble, isReceiverSide: false)
    }

    func update(viewModel: ALKMessageViewModel) {
        // Set message
        messageView.text = viewModel.message ?? ""
        messageView.setStyle(ALKMessageStyle.sentMessage)
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
        addViewsForAutolayout(views: [messageView, bubbleView])
        bringSubviewToFront(messageView)
        messageView.topAnchor.constraint(equalTo: topAnchor, constant: Padding.MessageView.top).isActive = true
        messageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        messageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1 * Padding.MessageView.bottom).isActive = true
        messageView.heightAnchor.constraintEqualToAnchor(constant: 0, identifier: ConstraintIdentifier.MessageView.height).isActive = true
        messageView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor).isActive = true

        bubbleView.leadingAnchor.constraint(equalTo: messageView.leadingAnchor, constant: -widthPadding).isActive = true
        bubbleView.trailingAnchor.constraint(equalTo: messageView.trailingAnchor, constant: widthPadding).isActive = true
        bubbleView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        bubbleView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1 * Padding.BubbleView.bottom).isActive = true
    }

    func updateHeightOfView(hideView: Bool, viewModel: ALKMessageViewModel, maxWidth: CGFloat) {
        let messageHeight = hideView ? 0 : viewModel.message?.heightWithConstrainedWidth(maxWidth, font: ALKMessageStyle.sentMessage.font)

        messageView
            .constraint(withIdentifier: ConstraintIdentifier.MessageView.height)?.constant = messageHeight ?? 0
    }
}
