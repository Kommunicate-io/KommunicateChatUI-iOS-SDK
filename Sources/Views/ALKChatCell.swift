//
//  ChatCell.swift
//  
//
//  Created by Mukesh Thawani on 04/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher
import MGSwipeTableCell
import Applozic

public protocol ALKChatViewModelProtocol {
    var avatar: URL? { get }
    var avatarImage: UIImage? { get }
    var avatarGroupImageUrl: String? { get }
    var name: String { get }
    var groupName: String { get }
    var theLastMessage: String? { get }
    var hasUnreadMessages: Bool { get }
    var totalNumberOfUnreadMessages: UInt { get }
    var isGroupChat: Bool { get }
    var contactId: String? { get }
    var channelKey: NSNumber? { get }
    var conversationId: NSNumber! {get set}
    var createdAt: String? { get }
}

enum ALKChatCellAction {
    case delete
    case favorite
    case store
    case call
    case mute
    case unmute
}

protocol ALKChatCellDelegate: class {
    func chatCell(cell: ALKChatCell, action: ALKChatCellAction, viewModel: ALKChatViewModelProtocol)
}

final class ALKChatCell: MGSwipeTableCell {

    private var avatarImageView: UIImageView = {
        let imv = UIImageView()
        imv.contentMode = .scaleAspectFill
        imv.clipsToBounds = true
        let layer = imv.layer
        layer.cornerRadius = 22.5
        layer.backgroundColor = UIColor.clear.cgColor
        layer.masksToBounds = true
        return imv
    }()

    private var nameLabel: UILabel = {
        let label = UILabel()
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.font = Font.bold(size: 14.0).font()
        label.textColor = .text(.black00)
        return label
    }()

    private var locationLabel: UILabel = {
        let label = UILabel()
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.font = Font.normal(size: 14.0).font()
        label.textColor = UIColor(netHex: 0x9B9B9B)
        return label
    }()

    private var lineView: UIView = {
        let view = UIView()
        let layer = view.layer
        view.backgroundColor = UIColor.init(red: 200.0/255.0, green: 199.0/255.0, blue: 204.0/255.0, alpha: 0.33)
        return view
    }()

    private lazy var voipButton: UIButton = {
        let bt = UIButton(type: .custom)
        bt.setImage(UIImage(named: "icon_menu_dial_on"), for: .normal)
        bt.setImage(UIImage(named: "icon_call_disable"), for: .disabled)
        bt.addTarget(self, action: #selector(callTapped(button:)), for: .touchUpInside)
        return bt
    }()

    private lazy var favoriteButton: UIButton = {
        let bt = UIButton(type: .custom)
        bt.setImage(UIImage(named: "icon_favorite"), for: .normal)
        bt.setImage(UIImage(named: "icon_favorite_active"), for: .highlighted)
        bt.setImage(UIImage(named: "icon_favorite_active"), for: .selected)
        bt.addTarget(self, action: #selector(favoriteTapped(button:)), for: UIControlEvents.touchUpInside)
        return bt
    }()

    // MARK: BadgeNumber
    private lazy var badgeNumberView: UIView = {
        let view = UIView(frame: .zero)
        view.setBackgroundColor(.background(.main))
        return view
    }()

    private lazy var badgeNumberLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "0"
        label.textAlignment = .center
        label.setTextColor(.white)
        label.setFont(UIFont.font(.normal(size: 9.0)))

        return label
    }()

    private var timeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.numberOfLines = 1
        label.font = Font.normal(size: 14.0).font()
        label.textColor = UIColor(netHex: 0x9B9B9B)
        return label
    }()

    private var onlineStatusView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor.onlineGreen()
        return view
    }()

    private var avatarName: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.gray
        label.layer.cornerRadius = 22.5
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.numberOfLines = 1
        label.clipsToBounds = true
        label.font = Font.bold(size: 20.0).font()
        return label
    }()
    
    let muteButton: MGSwipeButton = MGSwipeButton.init(type: .custom)

    weak var chatCellDelegate: ALKChatCellDelegate?

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        voipButton.isHidden = true
        setupConstraints()
    }

    deinit {
        voipButton.removeTarget(self, action:  #selector(callTapped(button:)), for: .touchUpInside)
        //favoriteButton.removeTarget(self, action:  #selector(favoriteTapped(button:)), for: .touchUpInside)
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)

        guard let _ = viewModel else {
            return
        }

        lineView.backgroundColor = UIColor(netHex: 0xF1F1F1)

        backgroundColor = highlighted ? UIColor.init(netHex: 0xECECEC) : UIColor.white
        contentView.backgroundColor = backgroundColor

        // set backgroundColor of badgeNumber
        badgeNumberView.setBackgroundColor(.background(.main))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        guard let _ = viewModel else {
            return
        }


        lineView.backgroundColor = UIColor(netHex: 0xF1F1F1)

        backgroundColor = selected ? UIColor.init(netHex: 0xECECEC) : UIColor.white
        contentView.backgroundColor = backgroundColor

        // set backgroundColor of badgeNumber
        badgeNumberView.setBackgroundColor(.background(.main))
    }
    
    private func isConversationMuted(viewModel: ALKChatViewModelProtocol) -> Bool{
        if let channelKey = viewModel.channelKey,
            let channel = ALChannelService().getChannelByKey(channelKey){
            if channel.isNotificationMuted() {
                return true
            }else {
                return false
            }
        }else if let contactId = viewModel.contactId,
            let contact = ALContactService().loadContact(byKey: "userId", value: contactId){
            if contact.isNotificationMuted() {
                return true
            }else {
                return false
            }
        }else {
            // Conversation is not for user or channel
            return true
        }
    }
    
    var viewModel: ALKChatViewModelProtocol?

    func update(viewModel: ALKChatViewModelProtocol, identity: ALKIdentityProtocol?) {

        self.viewModel = viewModel
        let placeHolder = UIImage(named: "placeholder", in: Bundle.applozic, compatibleWith: nil)
        avatarImageView.isHidden = true
        avatarName.isHidden = true
        avatarName.backgroundColor = UIColor.gray

        if let avatarImage = viewModel.avatarImage {
            if let imgStr = viewModel.avatarGroupImageUrl,let imgURL = URL.init(string: imgStr) {
                avatarImageView.isHidden = false
                let resource = ImageResource(downloadURL: imgURL, cacheKey: imgStr)
                avatarImageView.kf.setImage(with: resource, placeholder: avatarImage, options: nil, progressBlock: nil, completionHandler: nil)
            } else {
                avatarName.isHidden = false
                let name = getFirstTwoLetters(text: viewModel.groupName)
                avatarName.text = name.isEmpty ? "X": name
            }

        }else if let avatar = viewModel.avatar {
            avatarImageView.isHidden = false
            let resource = ImageResource(downloadURL: avatar, cacheKey: avatar.absoluteString)
            avatarImageView.kf.setImage(with: resource, placeholder: placeHolder, options: nil, progressBlock: nil, completionHandler: nil)
        } else {
            avatarName.isHidden = false
            let name = getFirstTwoLetters(text: viewModel.name)
            avatarName.text = name.isEmpty ? "X": name
        }

        let name = viewModel.isGroupChat ? viewModel.groupName:viewModel.name
        nameLabel.text = name
        locationLabel.text = viewModel.theLastMessage

        let deleteButton = MGSwipeButton.init(type: .system)
        deleteButton.backgroundColor = UIColor.mainRed()
        deleteButton.setImage(UIImage(named: "icon_delete_white", in: Bundle.applozic, compatibleWith: nil), for: .normal)
        deleteButton.setImage(UIImage(named: "icon_delete_white", in: Bundle.applozic, compatibleWith: nil), for: .highlighted)
        deleteButton.setImage(UIImage(named: "icon_delete_white", in: Bundle.applozic, compatibleWith: nil), for: .selected)
        deleteButton.tintColor = .white
        deleteButton.frame = CGRect.init(x: 0, y: 0, width: 69, height: 69)
        deleteButton.callback = { [weak self] (buttnon) in

            guard let strongSelf = self else {return true}
            guard let viewModel = strongSelf.viewModel else {return true}

            strongSelf.chatCellDelegate?.chatCell(cell: strongSelf, action: .delete, viewModel: viewModel)

            return true
        }

        muteButton.backgroundColor = UIColor.init(netHex: 0x999999)
        if isConversationMuted(viewModel: viewModel) {
            muteButton.setImage(UIImage(named: "icon_mute_active", in: Bundle.applozic, compatibleWith: nil), for: .normal)
        }else {
            muteButton.setImage(UIImage(named: "icon_mute_inactive", in: Bundle.applozic, compatibleWith: nil), for: .normal)
        }
 
        muteButton.frame = CGRect.init(x: 0, y: 0, width: 69, height: 69)
        muteButton.callback = { [weak self] (buttnon) in

            guard let strongSelf = self else {return true}
            guard let viewModel = strongSelf.viewModel else {return true}
            
            if strongSelf.isConversationMuted(viewModel: viewModel){
                strongSelf.chatCellDelegate?.chatCell(cell: strongSelf, action: .unmute, viewModel: viewModel)
            }else {
                strongSelf.chatCellDelegate?.chatCell(cell: strongSelf, action: .mute, viewModel: viewModel)
            }
            return true
        }

        self.rightButtons = [muteButton]
        self.rightSwipeSettings.transition = .static

        self.leftButtons = [deleteButton]
        self.leftSwipeSettings.transition = .static

        // get unread count of message and set badgenumber
        let unreadMsgCount = viewModel.totalNumberOfUnreadMessages
        let numberText: String = (unreadMsgCount < 1000 ? "\(unreadMsgCount)" : "999+")
        let isHidden = (unreadMsgCount < 1)

        badgeNumberView.isHidden = isHidden
        badgeNumberLabel.text = numberText

        timeLabel.text = viewModel.createdAt
        onlineStatusView.isHidden = true

        if !viewModel.isGroupChat {
            
            let contactService = ALContactService()
            guard let contactId = viewModel.contactId,
            let contact = contactService.loadContact(byKey: "userId", value: contactId) else {
                return
            }

            if contact.block || contact.blockBy || contactService.isUserDeleted(contactId) {
                onlineStatusView.isHidden = true
                return
            }

            onlineStatusView.isHidden = !contact.connected
        }

        self.voipButton.isEnabled = !viewModel.isGroupChat
    }

    private func setupConstraints() {

        contentView.addViewsForAutolayout(views: [avatarImageView, nameLabel, locationLabel,lineView,voipButton,/*favoriteButton,*/avatarName,badgeNumberView, timeLabel, onlineStatusView])

        // setup constraint of imageProfile
        avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 17.0).isActive = true
        avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15.0).isActive = true
        avatarImageView.heightAnchor.constraint(equalToConstant: 45.0).isActive = true
        avatarImageView.widthAnchor.constraint(equalToConstant: 45.0).isActive = true

        // setup constraint of name
        nameLabel.topAnchor.constraint(equalTo: avatarImageView.topAnchor, constant: 2).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 12).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: timeLabel.leadingAnchor, constant: -5).isActive = true

        // setup constraint of mood
        locationLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2).isActive = true
        locationLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        locationLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 12).isActive = true
        locationLabel.trailingAnchor.constraint(equalTo: voipButton.leadingAnchor, constant: -19).isActive = true

        // setup constraint of line
        lineView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        lineView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        lineView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        lineView.heightAnchor.constraint(equalToConstant: 1).isActive = true

        // setup constraint of favorite button
        /*
         favoriteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15).isActive = true
         favoriteButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
         favoriteButton.widthAnchor.constraint(equalToConstant: 24.0).isActive = true
         favoriteButton.heightAnchor.constraint(equalToConstant: 24.0).isActive = true
         */

        // setup constraint of VOIP button
        //voipButton.trailingAnchor.constraint(equalTo: favoriteButton.leadingAnchor, constant: -25.0).isActive = true
        voipButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -23).isActive = true
        voipButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        voipButton.widthAnchor.constraint(equalToConstant: 24.0).isActive = true
        voipButton.heightAnchor.constraint(equalToConstant: 25.0).isActive = true

        // setup constraint of badgeNumber
        badgeNumberView.addViewsForAutolayout(views: [badgeNumberLabel])


        badgeNumberView.trailingAnchor.constraint(lessThanOrEqualTo: nameLabel.leadingAnchor, constant: -5)
        badgeNumberView.topAnchor.constraint(equalTo: avatarImageView.topAnchor, constant: 0).isActive = true
        badgeNumberView.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: -12).isActive = true

        badgeNumberLabel.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 1000), for: .horizontal)
        badgeNumberLabel.topAnchor.constraint(equalTo: badgeNumberView.topAnchor, constant: 2.0).isActive = true
        badgeNumberLabel.bottomAnchor.constraint(equalTo: badgeNumberView.bottomAnchor, constant: -2.0).isActive = true
        badgeNumberLabel.leadingAnchor.constraint(equalTo: badgeNumberView.leadingAnchor, constant: 2.0).isActive = true
        badgeNumberLabel.trailingAnchor.constraint(equalTo: badgeNumberView.trailingAnchor, constant: -2.0).isActive = true
        badgeNumberLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 11.0).isActive = true
        badgeNumberLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 11.0).isActive = true

        timeLabel.heightAnchor.constraint(equalToConstant: 15).isActive = true
        timeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -19).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 70).isActive = true
        timeLabel.topAnchor.constraint(equalTo: nameLabel.topAnchor, constant: 0).isActive  = true

        onlineStatusView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0).isActive = true
        onlineStatusView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0).isActive = true
        onlineStatusView.widthAnchor.constraint(equalToConstant: 6).isActive = true

        avatarName.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 17.0).isActive = true
        avatarName.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15.0).isActive = true
        avatarName.heightAnchor.constraint(equalToConstant: 45.0).isActive = true
        avatarName.widthAnchor.constraint(equalToConstant: 45.0).isActive = true

        // update frame
        contentView.layoutIfNeeded()

        badgeNumberView.layer.cornerRadius = badgeNumberView.frame.size.height / 2.0
    }


    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private weak var comingSoonDelegate: UIView?

    func setComingSoonDelegate(delegate: UIView) {
        comingSoonDelegate = delegate
    }

    @objc func callTapped(button: UIButton) {

        guard let viewModel = self.viewModel else {return}
        self.chatCellDelegate?.chatCell(cell: self, action: .call, viewModel:viewModel)
    }

    @objc func favoriteTapped(button: UIButton) {
//        comingSoonDelegate?.makeToast(SystemMessage.ComingSoon.Favorite, duration: 1.0, position: .center)
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
    }

    private func getFirstTwoLetters(text: String) -> String {
        let stringInputArr = text.components(separatedBy: " ")
        var firstTwoCharStr = ""

        for string in stringInputArr {
            guard let firstChar = string.characters.first else { continue }
            firstTwoCharStr = firstTwoCharStr + String(firstChar)
        }
        return firstTwoCharStr
    }

    private func getRandomColor() -> UIColor {
        let colors = [0x19A5E4, 0x0EB04B, 0xF3B618, 0xE4E9EC]
        let x = randomInt(min: 0, max: 3)
        return UIColor.init(netHex: colors[x])
    }

    func randomInt(min: Int, max:Int) -> Int {
        return min + Int(arc4random_uniform(UInt32(max - min + 1)))
    }
    
}
