//
//  ALKMyImageMessage.swift
//  ApplozicSwift
//
//  Created by Shivam Pokhriyal on 10/04/19.
//

import Foundation

struct ImageMessage: ImageModel, MessageModel {
    var caption: String?

    var url: String = ""

    var isMyMessage: Bool

    var message: String?

    var time: String

    var displayName: String?

    var status: MessageStatus?

    var imageURL: URL?

    var isReplyMessage: Bool

    var originalMessage: MessageModel?

    var metadata: Dictionary<String, Any>?

    init(with model: ALKMessageViewModel) {
        self.isMyMessage = model.isMyMessage
        self.time = model.time!
        self.displayName = model.displayName
        self.message = model.message
        self.status = model.messageStatus()
        self.imageURL = model.avatarURL
        self.isReplyMessage = model.isReplyMessage
        self.originalMessage = nil
        self.metadata = model.metadata
        let payload = model.payloadFromMetadata()
        precondition(payload != nil, "Payload cannot be nil")
        guard let imageData = payload?[0], let url = imageData["url"] as? String else {
            assertionFailure("Payload must contain url.")
            return
        }
        self.url = url
        self.caption = imageData["caption"] as? String
    }

}

extension ALKMessageViewModel {
    func messageStatus() -> MessageStatus {
        if isAllRead {
            return .read
        } else if isAllReceived {
            return .delivered
        } else if isSent {
            return .sent
        } else {
            return .pending
        }
    }
}

class ALKMyImageMessageCell: ALKChatBaseCell<ALKMessageViewModel> {

    let maxWidth = UIScreen.main.bounds.width
    static let padding = Padding(left: 60, right: 10, top: 10, bottom: 10)
    var imageMessageView: ImageMessageView

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        imageMessageView = ImageMessageView(frame: .zero, maxWidth: maxWidth, padding: ALKMyImageMessageCell.padding, isMyMessage: true)
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func update(viewModel: ALKMessageViewModel) {

        let imageMessage = ImageMessage(with: viewModel)
        imageMessageView.update(model: imageMessage)
    }

    override class func rowHeigh(viewModel: ALKMessageViewModel, width: CGFloat) -> CGFloat {
        return ImageMessageView.rowHeight(model: ImageMessage(with: viewModel), maxWidth: width, padding: padding)
    }

    private func setupConstraints() {
        contentView.addViewsForAutolayout(views: [imageMessageView])
        imageMessageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        imageMessageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        imageMessageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        imageMessageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
    }
}
