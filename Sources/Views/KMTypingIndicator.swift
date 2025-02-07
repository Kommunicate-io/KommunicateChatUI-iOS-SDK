//
//  KMTypingIndicator.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by Abhijeet Ranjan on 11/12/23.
//

import KommunicateCore_iOS_SDK
import UIKit

class KMTypingIndicator: ALKMessageCell {

    private let typingIndicatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    enum Padding {
        enum TypingIndicator {
            static let top: CGFloat = 10
            static let bottom: CGFloat = 10
            static let left: CGFloat = 66.0 // Adjust left padding
            static let right: CGFloat = 0
            static let height: CGFloat = 44.0
            static let width: CGFloat = 44.0
            static let dotSpacing: CGFloat = 8.0
            static let dotRadius: CGFloat = 4.0
            static let animationDuration: TimeInterval = 0.8
        }
        enum BubbleView {
            static let top: CGFloat = 10
            static let left: CGFloat = 56.0
            static let right: CGFloat = 85.0
            static let bottom: CGFloat = 0
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createUI()
        startTypingAnimation()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setupStyle() {
        super.setupStyle()
        bubbleView.setStyle(ALKMessageStyle.receivedBubble, isReceiverSide: true)
    }

    // MARK: - UI Setup

    private func createUI() {
        addViewsForAutolayout(views: [bubbleView, typingIndicatorView])

        setupBubbleViewConstraints()
        setupTypingIndicatorViewConstraints()
        createDotViews()
    }

    private func setupBubbleViewConstraints() {
        bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Padding.BubbleView.top).isActive = true
        bubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Padding.BubbleView.left).isActive = true
        bubbleView.widthAnchor.constraint(equalToConstant: 75).isActive = true
        bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Padding.BubbleView.bottom).isActive = true
    }

    private func setupTypingIndicatorViewConstraints() {
        typingIndicatorView.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 20).isActive = true
        typingIndicatorView.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 20).isActive = true
        typingIndicatorView.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -10).isActive = true
        typingIndicatorView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -20).isActive = true
    }

    private func createDotViews() {
        for index in 0..<3 {
            let dotView = createDotView()
            typingIndicatorView.addSubview(dotView)

            configureDotViewConstraints(dotView, atIndex: index)
        }
    }

    private func createDotView() -> UIView {
        let dotView = UIView()
        dotView.translatesAutoresizingMaskIntoConstraints = false
        dotView.backgroundColor = UIColor.kmDynamicColor(light: .gray, dark: .white)
        dotView.layer.cornerRadius = Padding.TypingIndicator.dotRadius
        return dotView
    }

    private func configureDotViewConstraints(_ dotView: UIView, atIndex index: Int) {
        dotView.widthAnchor.constraint(equalToConstant: 2 * Padding.TypingIndicator.dotRadius).isActive = true
        dotView.heightAnchor.constraint(equalToConstant: 2 * Padding.TypingIndicator.dotRadius).isActive = true
        dotView.centerYAnchor.constraint(equalTo: typingIndicatorView.centerYAnchor).isActive = true

        if index == 0 {
            dotView.leadingAnchor.constraint(equalTo: typingIndicatorView.leadingAnchor).isActive = true
        } else {
            let previousDot = typingIndicatorView.subviews[index - 1]
            dotView.leadingAnchor.constraint(equalTo: previousDot.trailingAnchor, constant: Padding.TypingIndicator.dotSpacing).isActive = true
        }
    }

    // MARK: - Typing Animation

    private func startTypingAnimation() {
        for index in 0..<3 {
            let dotView = typingIndicatorView.subviews[index]

            UIView.animate(withDuration: Padding.TypingIndicator.animationDuration, delay: TimeInterval(index) * 0.2, options: [.repeat, .autoreverse], animations: {
                dotView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            }, completion: nil)
        }
    }
}
