//
//  ALKMyMessageView.swift
//  ApplozicSwift
//
//  Created by Shivam Pokhriyal on 08/01/19.
//
import Applozic

class ALKMyMessageView: UIView {

    fileprivate var widthPadding: CGFloat = CGFloat(ALKMessageStyle.sentBubble.widthPadding)
    fileprivate lazy var messageView: ALHyperLabel = {
        let label = ALHyperLabel.init(frame: .zero)
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
        let image = UIImage.init(named: "chat_bubble_rounded", in: Bundle.applozic, compatibleWith: nil)
        bv.tintColor = UIColor(netHex: 0xF1F0F0)
        bv.image = image?.imageFlippedForRightToLeftLayoutDirection()
        bv.isUserInteractionEnabled = false
        bv.isOpaque = true
        return bv
    }()

    init() {
        super.init(frame: .zero)
        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(viewModel: ALKMessageViewModel) {
        // Set message
        messageView.text = viewModel.message ?? ""
        messageView.setStyle(ALKMessageStyle.message)

        // Set time
        timeLabel.text = viewModel.time
        timeLabel.setStyle(ALKMessageStyle.time)

        // Set read status
        if viewModel.isAllRead {
            stateView.image = UIImage(named: "read_state_3", in: Bundle.applozic, compatibleWith: nil)
            stateView.tintColor = UIColor(netHex: 0x0578FF)
        } else if viewModel.isAllReceived {
            stateView.image = UIImage(named: "read_state_2", in: Bundle.applozic, compatibleWith: nil)
            stateView.tintColor = nil
        } else if viewModel.isSent {
            stateView.image = UIImage(named: "read_state_1", in: Bundle.applozic, compatibleWith: nil)
            stateView.tintColor = nil
        } else {
            stateView.image = UIImage(named: "seen_state_0", in: Bundle.applozic, compatibleWith: nil)
            stateView.tintColor = UIColor.red
        }
    }

    class func rowHeight(viewModel: ALKMessageViewModel, width: CGFloat) -> CGFloat {
        let minimumHeight: CGFloat = 10 // Padding
        guard let message = viewModel.message else {
            return minimumHeight
        }
        let font = ALKMessageStyle.message.font
        var messageHeight = message.heightWithConstrainedWidth(width: width, font: font)
        messageHeight += 20 // (6 + 4) + 10 for extra padding
        return max(messageHeight, minimumHeight)
    }
    
    private func setupConstraints() {
        self.addViewsForAutolayout(views: [messageView, bubbleView, stateView, timeLabel])
        self.bringSubview(toFront: messageView)
        messageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 4).isActive = true
        messageView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        messageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -6).isActive = true
        messageView.leadingAnchor.constraint(greaterThanOrEqualTo: self.leadingAnchor).isActive = true

        bubbleView.leadingAnchor.constraint(equalTo: messageView.leadingAnchor, constant: -widthPadding).isActive = true
        bubbleView.trailingAnchor.constraint(equalTo: messageView.trailingAnchor, constant: widthPadding).isActive = true
        bubbleView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        bubbleView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -2).isActive = true

        stateView.widthAnchor.constraint(equalToConstant: 17.0).isActive = true
        stateView.heightAnchor.constraint(equalToConstant: 9.0).isActive = true
        stateView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -1.0).isActive = true
        stateView.trailingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: -2.0).isActive = true

        timeLabel.trailingAnchor.constraint(equalTo: stateView.leadingAnchor, constant: -2.0).isActive = true
        timeLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: 2).isActive = true
    }

}
