//
//  ALKReplyMessageView.swift
//  ApplozicSwift
//
//  Created by Mukesh Thawani on 07/02/18.
//

import UIKit

/* Reply message view to be used in the
 bottom (above chat bar) when replying
 to a message */

open class ALKReplyMessageView: UIView {
    open let nameLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.text = "Name"
        label.numberOfLines = 1
        label.backgroundColor = UIColor.black
        return label
    }()

    open let messageLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.text = "The message"
        label.numberOfLines = 1
        label.backgroundColor = UIColor.black
        return label
    }()

    open let closeButton: UIButton = {
        let button = UIButton(frame: CGRect.zero)
        let closeImage = UIImage(named: "close")
        button.setImage(closeImage, for: .normal)
        button.backgroundColor = UIColor.green
        return button
    }()

    public var closeButtonTapped: ((Bool)->())?

    private var message: ALKMessageViewModel?

    private enum Padding {

        enum NameLabel {
            static let height: CGFloat = 30.0
            static let left: CGFloat = 10.0
            static let right: CGFloat = -10.0
            static let top: CGFloat = 5.0
        }

        enum MessageLabel {
            static let height: CGFloat = 30.0
            static let left: CGFloat = 10.0
            static let right: CGFloat = -10.0
            static let top: CGFloat = 5.0
            static let bottom: CGFloat = -5.0
        }

        enum CloseButton {
            static let height: CGFloat = 30.0
            static let width: CGFloat = 30.0
            static let right: CGFloat = -10.0
            static let top: CGFloat = 5.0
            static let bottom: CGFloat = -5.0
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpConstraints()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open func update(message: ALKMessageViewModel) {
        self.message = message
        nameLabel.text = "Name"
        messageLabel.text = "Message Text"
    }

    //MARK: - Internal methods

    private func setUpViews() {

        setUpConstraints()
        closeButton.target(forAction: #selector(closeButtonTapped(_:)), withSender: self)
    }

    private func setUpConstraints() {
        self.addViewsForAutolayout(views: [nameLabel, messageLabel, closeButton])

        let view = self

        nameLabel.heightAnchor.constraint(
            lessThanOrEqualToConstant: Padding.NameLabel.height)
            .isActive = true
        nameLabel.leadingAnchor.constraint(
            equalTo: view.leadingAnchor,
            constant: Padding.NameLabel.left).isActive = true
        nameLabel.trailingAnchor.constraint(
            equalTo: closeButton.leadingAnchor,
            constant: Padding.NameLabel.right).isActive = true
        nameLabel.topAnchor.constraint(
            equalTo: view.topAnchor,
            constant: Padding.NameLabel.top).isActive = true

        messageLabel.heightAnchor.constraint(
            lessThanOrEqualToConstant: Padding.MessageLabel.height)
            .isActive = true
        messageLabel.leadingAnchor.constraint(
            equalTo: view.leadingAnchor,
            constant: Padding.MessageLabel.left).isActive = true
        messageLabel.trailingAnchor.constraint(
            equalTo: view.trailingAnchor,
            constant: Padding.MessageLabel.right).isActive = true
        messageLabel.topAnchor.constraint(
            equalTo: nameLabel.bottomAnchor,
            constant: Padding.MessageLabel.top).isActive = true
        messageLabel.bottomAnchor.constraint(
            equalTo: view.bottomAnchor,
            constant: Padding.MessageLabel.bottom).isActive = true

        closeButton.heightAnchor.constraint(
            lessThanOrEqualToConstant: Padding.CloseButton.height)
            .isActive = true
        closeButton.widthAnchor.constraint(
            equalToConstant: Padding.CloseButton.width).isActive = true
        closeButton.trailingAnchor.constraint(
            equalTo: view.trailingAnchor,
            constant: Padding.CloseButton.right).isActive = true
        closeButton.topAnchor.constraint(
            equalTo: view.topAnchor,
            constant: Padding.CloseButton.top).isActive = true
        closeButton.bottomAnchor.constraint(
            equalTo: messageLabel.topAnchor,
            constant: Padding.CloseButton.bottom).isActive = true

    }

    @objc private func closeButtonTapped(_ sender: UIButton) {
        closeButtonTapped?(true)
    }

}
