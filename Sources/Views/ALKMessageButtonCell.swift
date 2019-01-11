//
//  ALKMessageButtonCell.swift
//  ApplozicSwift
//
//  Created by Shivam Pokhriyal on 10/01/19.
//

class ALKMyMessageButtonCell: ALKChatBaseCell<ALKMessageViewModel> {

    var messageView = ALKMyMessageView()
    var buttonView = ButtonsView(frame: .zero)
    lazy var messageViewHeight = self.messageView.heightAnchor.constraint(equalToConstant: 0)

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(viewModel: ALKMessageViewModel, maxWidth: CGFloat) {
        self.viewModel = viewModel
        let messageWidth = maxWidth -
            (ChatCellPadding.SentMessage.Message.left + ChatCellPadding.SentMessage.Message.right)
        let height = ALKMyMessageView.rowHeight(viewModel: viewModel, width: messageWidth)
        messageViewHeight.constant = height
        messageView.update(viewModel: viewModel)

        guard let dict = viewModel.payloadFromMetadata() else {
            self.layoutIfNeeded()
            return
        }
        let buttonWidth = maxWidth - (ChatCellPadding.SentMessage.MessageButton.left + ChatCellPadding.SentMessage.MessageButton.right)
        updateMessageButtonView(payload: dict, width: buttonWidth, heightOffset: height)
        self.layoutIfNeeded()
    }

    override class func rowHeigh(viewModel: ALKMessageViewModel, width: CGFloat) -> CGFloat {
        let messageWidth = width -
            (ChatCellPadding.SentMessage.Message.left + ChatCellPadding.SentMessage.Message.right)
        let messageHeight = ALKMyMessageView.rowHeight(viewModel: viewModel, width: messageWidth)

        guard let dict = viewModel.payloadFromMetadata() else {
            return messageHeight + 10 // Paddding
        }
        let buttonWidth = width - (ChatCellPadding.SentMessage.MessageButton.left + ChatCellPadding.SentMessage.MessageButton.right)
        let buttonHeight = ButtonsView.rowHeight(payload: dict, maxWidth: buttonWidth)
        return messageHeight + buttonHeight + 20 // Padding between messages
    }

    private func setupConstraints() {
        self.contentView.addSubview(messageView)
        self.contentView.addSubview(buttonView)
        messageView.translatesAutoresizingMaskIntoConstraints = false
        messageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        messageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ChatCellPadding.SentMessage.Message.left).isActive = true
        messageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -1 * ChatCellPadding.SentMessage.Message.right).isActive = true
        messageViewHeight.isActive = true
    }

    private func updateMessageButtonView(payload: [Dictionary<String, Any>], width: CGFloat, heightOffset: CGFloat) {
        buttonView.maxWidth = width
        buttonView.stackViewAlignment = .trailing
        buttonView.update(payload: payload)

        buttonView.frame = CGRect(x: ChatCellPadding.SentMessage.MessageButton.left,
                                         y: heightOffset + ChatCellPadding.SentMessage.MessageButton.top,
                                         width: width,
                                         height: ButtonsView.rowHeight(payload: payload, maxWidth: width))
    }

}

class ALKFriendMessageButtonCell: ALKChatBaseCell<ALKMessageViewModel> {

    var messageView = ALKFriendMessageView()
    var buttonView = ButtonsView(frame: .zero)
    lazy var messageViewHeight = self.messageView.heightAnchor.constraint(equalToConstant: 0)

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(viewModel: ALKMessageViewModel, maxWidth: CGFloat) {
        self.viewModel = viewModel
        let messageWidth = maxWidth -
            (ChatCellPadding.ReceivedMessage.Message.left + ChatCellPadding.ReceivedMessage.Message.right)
        let height = ALKFriendMessageView.rowHeight(viewModel: viewModel, width: messageWidth)
        messageViewHeight.constant = height
        messageView.update(viewModel: viewModel)

        guard let dict = viewModel.payloadFromMetadata() else {
            self.layoutIfNeeded()
            return
        }
        let buttonWidth = maxWidth - (ChatCellPadding.ReceivedMessage.MessageButton.left + ChatCellPadding.ReceivedMessage.MessageButton.right)
        updateMessageButtonView(payload: dict, width: buttonWidth, heightOffset: height)
        self.layoutIfNeeded()
    }

    override class func rowHeigh(viewModel: ALKMessageViewModel, width: CGFloat) -> CGFloat {
        let messageWidth = width -
            (ChatCellPadding.ReceivedMessage.Message.left + ChatCellPadding.ReceivedMessage.Message.right)
        let messageHeight = ALKFriendMessageView.rowHeight(viewModel: viewModel, width: messageWidth)

        guard let dict = viewModel.payloadFromMetadata() else {
            return messageHeight + 10 // Paddding
        }
        let buttonWidth = width - (ChatCellPadding.ReceivedMessage.MessageButton.left + ChatCellPadding.ReceivedMessage.MessageButton.right)
        let buttonHeight = ButtonsView.rowHeight(payload: dict, maxWidth: buttonWidth)
        return messageHeight + buttonHeight + 20 // Padding between messages
    }

    private func setupConstraints() {
        self.contentView.addSubview(messageView)
        self.contentView.addSubview(buttonView)
        messageView.translatesAutoresizingMaskIntoConstraints = false
        messageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        messageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ChatCellPadding.ReceivedMessage.Message.left).isActive = true
        messageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -1 * ChatCellPadding.ReceivedMessage.Message.right).isActive = true
        messageViewHeight.isActive = true
    }

    private func updateMessageButtonView(payload: [Dictionary<String, Any>], width: CGFloat, heightOffset: CGFloat) {
        buttonView.maxWidth = width
        buttonView.stackViewAlignment = .leading
        buttonView.update(payload: payload)

        buttonView.frame = CGRect(x: ChatCellPadding.ReceivedMessage.MessageButton.left,
                                         y: heightOffset + ChatCellPadding.ReceivedMessage.MessageButton.top,
                                         width: width,
                                         height: ButtonsView.rowHeight(payload: payload, maxWidth: width))
    }

}

public struct MessageButtonConfig {

    public static var font = UIFont(name: "HelveticaNeue", size: 14) ?? UIFont.systemFont(ofSize: 14)

    public struct SubmitButton {
        public static var textColor = UIColor(red: 85, green: 83, blue: 183)
    }

    public struct LinkButton {
        public static var textColor = UIColor(red: 85, green: 83, blue: 183)
    }
}

public class ButtonsView: UIView {

    let font = MessageButtonConfig.font

    lazy var mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 2
        stackView.alignment = stackViewAlignment
        stackView.axis = .vertical
        stackView.distribution = .fill
        return stackView
    }()

    public var maxWidth: CGFloat!
    public var stackViewAlignment: UIStackView.Alignment = .leading {
        didSet {
            mainStackView.alignment = stackViewAlignment
        }
    }
    public var buttonSelected: ((_ index: Int, _ name: String) -> ())?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func update(payload: [Dictionary<String, Any>]) {
        mainStackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
        for i in 0 ..< payload.count {
            let dict = payload[i]
            guard let type = dict["type"] as? String, type == "link" else {
                // Submit button
                let name = dict["name"] as? String ?? ""
                let button = submitButton(title: name, index: i)
                mainStackView.addArrangedSubview(button)
                continue
            }
            // Link Button
            let name = dict["name"] as? String ?? ""
            let button = linkButton(title: name, index: i)
            mainStackView.addArrangedSubview(button)
        }
    }

    public class func rowHeight(payload: [Dictionary<String, Any>], maxWidth: CGFloat) -> CGFloat {
        var height: CGFloat = 0
        for dict in payload {
            let title = dict["name"] as? String ?? ""
            let currHeight = ALKCurvedButton.buttonSize(text: title, maxWidth: maxWidth, font: MessageButtonConfig.font).height
            height += currHeight + 2  // StackView spacing
        }
        return height
    }

    private func setupConstraints() {
        self.addViewsForAutolayout(views: [mainStackView])
        mainStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        mainStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        mainStackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        mainStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }

    private func submitButton(title: String, index: Int) -> ALKCurvedButton {
        let color = MessageButtonConfig.SubmitButton.textColor
        let button = ALKCurvedButton(title: title, font: font, color: color, maxWidth: maxWidth)
        button.index = index
//        button.layer.borderWidth = 0
//        button.backgroundColor = MessageButtonConfig.SubmitButton.backgroundColor
        button.buttonSelected = { [weak self] tag, title in
            self?.buttonSelected?(tag!, title)
        }
        return button
    }

    private func linkButton(title: String, index: Int) -> ALKCurvedButton {
        let color = MessageButtonConfig.LinkButton.textColor
        let button = ALKCurvedButton(title: title, font: font, color: color, maxWidth: maxWidth)
        button.index = index
        button.layer.borderWidth = 0

        let attributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font: font,
                                                          NSAttributedString.Key.foregroundColor : color,
                                                          NSAttributedString.Key.underlineStyle: 1]
        let attributedTitle = NSAttributedString(string: title, attributes: attributes)
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.buttonSelected = { [weak self] tag, title in
            self?.buttonSelected?(tag!, title)
        }
        return button
    }
}

