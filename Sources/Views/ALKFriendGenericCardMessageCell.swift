//
//  ALKFriendGenericCardCell.swift
//  ApplozicSwift
//
//  Created by Shivam Pokhriyal on 05/12/18.
//

import Applozic
import Foundation
import Kingfisher

open class ALKFriendGenericCardMessageCell: ALKGenericCardBaseCell {
    enum ConstraintIdentifier {
        enum NameLabel {
            static let height = "NameLabelHeight"
        }

        enum AvatarImageView {
            static let height = "AvatarImageViewHeight"
        }
    }

    enum Padding {
        enum NameLabel {
            static let top: CGFloat = 6
            static let leading: CGFloat = 57
            static let trailing: CGFloat = 57
            static let height: CGFloat = 16
        }

        enum AvatarImageView {
            static let top: CGFloat = 18
            static let leading: CGFloat = 9
            static let height: CGFloat = 37
            static let width: CGFloat = 37
        }

        enum TimeLabel {
            static var leading: CGFloat = 2.0
            static var top: CGFloat = 2.0
            static let maxWidth: CGFloat = 200
        }
    }

    fileprivate var timeLabel: UILabel = {
        let lb = UILabel()
        lb.isOpaque = true
        return lb
    }()

    fileprivate var avatarImageView: UIImageView = {
        let imv = UIImageView()
        imv.contentMode = .scaleAspectFill
        imv.clipsToBounds = true
        let layer = imv.layer
        layer.cornerRadius = 18.5
        layer.masksToBounds = true
        imv.isUserInteractionEnabled = true
        return imv
    }()

    fileprivate var nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.isOpaque = true
        return label
    }()

    fileprivate lazy var timeLabelWidth = timeLabel.widthAnchor.constraint(equalToConstant: 0)
    fileprivate lazy var timeLabelHeight = timeLabel.heightAnchor.constraint(equalToConstant: 0)

    var messageView = ALKFriendMessageView()
    lazy var messageViewHeight = self.messageView.heightAnchor.constraint(equalToConstant: 0)

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func update(viewModel: ALKMessageViewModel, width: CGFloat) {
        let isMessageEmpty = viewModel.isMessageEmpty

        let messageWidth = width - (ChatCellPadding.ReceivedMessage.Message.left +
            ChatCellPadding.ReceivedMessage.Message.right)

        messageViewHeight.constant = isMessageEmpty ? 0 : ALKFriendMessageView.rowHeight(viewModel: viewModel, width: messageWidth)

        if !isMessageEmpty {
            messageView.update(viewModel: viewModel)
        }

        messageView.updateHeightOfViews(hideView: isMessageEmpty, viewModel: viewModel, maxWidth: width)

        showNameAndAvatarImageView(isMessageEmpty: isMessageEmpty, viewModel: viewModel)

        layoutIfNeeded()
        super.update(viewModel: viewModel, width: width)

        timeLabel.setStyle(ALKMessageStyle.time)
        timeLabel.text = viewModel.time
        let timeLabelSize = viewModel.time!.rectWithConstrainedWidth(
            Padding.TimeLabel.maxWidth,
            font: ALKMessageStyle.time.font
        )

        timeLabelHeight.constant = timeLabelSize.height.rounded(.up)
        timeLabelWidth.constant = timeLabelSize.width.rounded(.up)
    }

    override func setupViews() {
        super.setupViews()
        setupCollectionView()

        contentView.addViewsForAutolayout(views: [collectionView, messageView, nameLabel, avatarImageView, timeLabel])
        contentView.bringSubviewToFront(messageView)

        nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: Padding.NameLabel.top).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Padding.NameLabel.leading).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Padding.NameLabel.trailing).isActive = true
        nameLabel.heightAnchor.constraintEqualToAnchor(constant: 0, identifier: ConstraintIdentifier.NameLabel.height).isActive = true

        avatarImageView.topAnchor.constraint(equalTo: topAnchor, constant: Padding.AvatarImageView.top).isActive = true
        avatarImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Padding.AvatarImageView.leading).isActive = true
        avatarImageView.heightAnchor.constraintEqualToAnchor(constant: 0, identifier: ConstraintIdentifier.AvatarImageView.height).isActive = true
        avatarImageView.widthAnchor.constraint(equalToConstant: Padding.AvatarImageView.width).isActive = true

        let leftPadding = ChatCellPadding.ReceivedMessage.Message.left
        let rightPadding = ChatCellPadding.ReceivedMessage.Message.right
        messageView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor).isActive = true
        messageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: leftPadding).isActive = true
        messageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -1 * rightPadding).isActive = true
        messageViewHeight.isActive = true

        let width = CGFloat(ALKMessageStyle.receivedBubble.widthPadding)
        let templateLeftPadding = leftPadding + 64 - width

        collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: templateLeftPadding).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: messageView.bottomAnchor, constant: ALKFriendGenericCardMessageCell.cardTopPadding).isActive = true
        collectionView.heightAnchor.constraintEqualToAnchor(constant: 0, identifier: ConstraintIdentifier.collectionView.rawValue).isActive = true
        timeLabel.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor, constant: Padding.TimeLabel.leading).isActive = true
        timeLabel.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: Padding.TimeLabel.top).isActive = true
        timeLabelWidth.isActive = true
        timeLabelHeight.isActive = true
        timeLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor).isActive = true
    }

    open override class func rowHeigh(viewModel: ALKMessageViewModel, width: CGFloat) -> CGFloat {
        let isMessageEmpty = viewModel.isMessageEmpty
        var height: CGFloat = 0

        let timeLabelSize = viewModel.time!.rectWithConstrainedWidth(
            Padding.TimeLabel.maxWidth,
            font: ALKMessageStyle.time.font
        )

        if isMessageEmpty {
            height += Padding.NameLabel.top + Padding.NameLabel.height
        } else {
            let messageWidth = width - (ChatCellPadding.ReceivedMessage.Message.left +
                ChatCellPadding.ReceivedMessage.Message.right)
            height = ALKFriendMessageView.rowHeight(viewModel: viewModel, width: messageWidth)
        }

        let cardHeight = super.cardHeightFor(message: viewModel, width: width)
        return cardHeight + height + 10 + timeLabelSize.height.rounded(.up) + Padding.TimeLabel.top // Extra 10 below complete view. Modify this for club/unclub.
    }

    private func setupCollectionView() {
        let layout: TopAlignedFlowLayout = TopAlignedFlowLayout()
        layout.minimumInteritemSpacing = 10
        layout.scrollDirection = .horizontal
        collectionView = ALKGenericCardCollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
    }

    private func showNameAndAvatarImageView(isMessageEmpty: Bool, viewModel: ALKMessageViewModel) {
        nameLabel
            .constraint(withIdentifier: ConstraintIdentifier.NameLabel.height)?
            .constant = isMessageEmpty ? Padding.NameLabel.height : 0
        avatarImageView
            .constraint(withIdentifier: ConstraintIdentifier.AvatarImageView.height)?
            .constant = isMessageEmpty ? Padding.AvatarImageView.height : 0

        if isMessageEmpty {
            let placeHolder = UIImage(named: "placeholder", in: Bundle.applozic, compatibleWith: nil)

            if let url = viewModel.avatarURL {
                let resource = ImageResource(downloadURL: url, cacheKey: url.absoluteString)
                avatarImageView.kf.setImage(with: resource, placeholder: placeHolder)
            } else {
                avatarImageView.image = placeHolder
            }

            nameLabel.text = viewModel.displayName
            nameLabel.setStyle(ALKMessageStyle.displayName)
        }
    }
}
