//
//  ALMessage+Extension.swift
//  ApplozicSwift
//
//  Created by Mukesh Thawani on 04/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import Foundation
import Applozic

let friendsMessage = "4"
let myMessage = "5"

let imageBaseUrl = ALUserDefaultsHandler.getFILEURL() + "/rest/ws/aws/file/"

extension ALMessage: ALKChatViewModelProtocol {

    private var alContact: ALContact? {
        let alContactDbService = ALContactDBService()
        guard let alContact = alContactDbService.loadContact(byKey: "userId", value: self.to) else {
            return nil
        }
        return alContact
    }

    private var alChannel: ALChannel? {
        let alChannelService = ALChannelService()

        // TODO:  This is a workaround as other method uses closure.
        // Later replace this with:
        // alChannelService.getChannelInformation(, orClientChannelKey: , withCompletion: )
        guard let alChannel = alChannelService.getChannelByKey(self.groupId) else {
            return nil
        }
        return alChannel
    }

    public var avatar: URL? {
        guard let alContact = alContact, let url = alContact.contactImageUrl else {
            return nil
        }
        return URL(string: url)
    }

    public var avatarImage: UIImage? {
        return isGroupChat ? UIImage(named: "group_profile_picture-1", in: Bundle.applozic, compatibleWith: nil) : nil
    }

    public var avatarGroupImageUrl: String? {

        guard let alChannel = alChannel, let avatar = alChannel.channelImageURL else {
            return nil
        }
        return avatar
    }

    public var name: String {
        guard let alContact = alContact, let id = alContact.userId  else {
            return ""
        }
        guard let displayName = alContact.getDisplayName(), !displayName.isEmpty else { return id }

        return displayName
    }

    public var groupName: String {
        if isGroupChat {
            guard let alChannel = alChannel, let name = alChannel.name else {
                return ""
            }
            return name
        }
        return ""
    }

    public var theLastMessage: String? {
        switch messageType {
        case .text:
            return message
        case .photo:
            return "Photo"
        case .location:
            return "Location"
        case .voice:
            return "Audio"
        case .information:
            return "Update"
        case .video:
            return "Video"
        case .html:
            return "Text"
        case .genericCard:
            return message
        case .genericList:
            return message
        case .quickReply:
            return message
        }
    }

    public var hasUnreadMessages: Bool {
        if isGroupChat {
            guard let alChannel = alChannel, let unreadCount = alChannel.unreadCount else {
                return false
            }
            return unreadCount.boolValue
        } else {
            guard let alContact = alContact, let unreadCount = alContact.unreadCount else {
                return false
            }
            return unreadCount.boolValue
        }
    }

    var identifier: String {
        guard let key = self.key else {
            return ""
        }
        return key
    }

    var friendIdentifier: String? {
        return nil
    }

    public var totalNumberOfUnreadMessages: UInt {
        if isGroupChat {
            guard let alChannel = alChannel, let unreadCount = alChannel.unreadCount else {
                return 0
            }
            return UInt(truncating: unreadCount)
        } else {
            guard let alContact = alContact, let unreadCount = alContact.unreadCount else {
                return 0
            }
            return UInt(truncating: unreadCount)
        }

    }

    public var isGroupChat: Bool {
        guard let _ = self.groupId else {
            return false
        }
        return true
    }

    public var contactId: String? {
        return self.contactIds
    }

    public var channelKey: NSNumber? {
        return self.groupId
    }

    public var createdAt: String? {
        let isToday = ALUtilityClass.isToday(date)
        return getCreatedAtTime(isToday)
    }
}

extension ALMessage {

    var isMyMessage: Bool {
        return (type != nil) ? (type == myMessage):false
    }

    var messageType: ALKMessageType {

        switch Int32(contentType) {
        case ALMESSAGE_CONTENT_DEFAULT:
            let isGenericCardType = isGenericCard()
            guard isGenericCardType || isGenericList() || isQuickReply() else {return .text}
            return isGenericCardType ? .genericCard:isQuickReply() ? .quickReply: .genericList
        case ALMESSAGE_CONTENT_LOCATION:
            return .location
        case ALMESSAGE_CHANNEL_NOTIFICATION:
            return .information
        case ALMESSAGE_CONTENT_TEXT_HTML:
            return .html
        default:
            guard let attachmentType = getAttachmentType() else {return .text}
            return attachmentType
        }
    }

    var date: Date {
        guard let time = createdAtTime else { return Date() }
        let sentAt = Date(timeIntervalSince1970: Double(time.doubleValue/1000))
        return sentAt
    }

    var time: String? {

        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "HH:mm"
        return dateFormatterGet.string(from: date)
    }

    var isSent: Bool {
        guard let status = status else {
            return false
        }
        return status == NSNumber(integerLiteral: Int(SENT.rawValue))
    }

    var isAllRead: Bool {
        guard let status = status else {
            return false
        }
        return status == NSNumber(integerLiteral: Int(DELIVERED_AND_READ.rawValue))
    }

    var isAllReceived: Bool {
        guard let status = status else {
            return false
        }
        return status == NSNumber(integerLiteral: Int(DELIVERED.rawValue))
    }

    var ratio: CGFloat {
        // Using default
        if messageType == .text {
            return 1.7
        }
        return 0.9
    }

    var size: Int64 {
        guard let fileMeta = fileMeta, let size = Int64(fileMeta.size) else {
            return 0
        }
        return size
    }

    var thumbnailURL: URL? {
        guard let fileMeta = fileMeta, let urlStr = fileMeta.thumbnailUrl, let url = URL(string: urlStr)  else {
            return nil
        }
        return url
    }

    var imageUrl: URL? {
        guard let fileMeta = fileMeta, let urlStr = fileMeta.blobKey, let imageUrl = URL(string: imageBaseUrl + urlStr) else {
            return nil
        }
        return imageUrl
    }

    var filePath: String? {
        guard let filePath = imageFilePath else {
            return nil
        }
        return filePath
    }

    var geocode: Geocode? {
        guard messageType == .location else {
            return nil
        }
        if let message = message {
            let jsonObject = try! JSONSerialization.jsonObject(with: message.data(using: .utf8)!, options: .mutableContainers) as! [String: Any]

            // Check if type is double or string
            if let lat = jsonObject["lat"] as? Double, let lon = jsonObject["lon"] as? Double {
                let location = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                return Geocode(coordinates: location)
            } else {
                guard let latString = jsonObject["lat"] as? String,
                    let lonString = jsonObject["lon"] as? String,let lat = Double(latString), let lon = Double(lonString) else {
                        return nil
                }
                let location = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                return Geocode(coordinates: location)
            }
        }
        return nil
    }

    var fileMetaInfo: ALFileMetaInfo? {
        return self.fileMeta ?? nil
    }

    private func getAttachmentType() -> ALKMessageType? {
        guard let fileMeta = fileMeta else {return nil}
        if fileMeta.contentType.hasPrefix("image") {
            return .photo
        } else if fileMeta.contentType.hasPrefix("audio") {
            return .voice
        } else if fileMeta.contentType.hasPrefix("video") {
            return .video
        } else {
            return nil
        }
    }

    private func isGenericCard() -> Bool {
        guard let metadata = metadata,
            let templateId = metadata["templateId"] as? String else {
                return false
        }
        return templateId == "2"
    }

    private func isGenericList() -> Bool {
        guard let metadata = metadata,
            let templateId = metadata["templateId"] as? String else {
                return false
        }
        return templateId == "8"
    }
    
    private func isQuickReply() -> Bool {
        guard let metadata = metadata,
            let templateId = metadata["templateId"] as? String else {
                return false
        }
        return templateId == "6"
    }

}

extension ALMessage {

    public var messageModel: ALKMessageModel {
        let messageModel = ALKMessageModel()
        messageModel.message = message
        messageModel.isMyMessage = isMyMessage
        messageModel.identifier = identifier
        messageModel.date = date
        messageModel.time = time
        messageModel.avatarURL = avatar
        messageModel.displayName = name
        messageModel.contactId = contactId
        messageModel.conversationId = conversationId
        messageModel.channelKey = channelKey
        messageModel.isSent = isSent
        messageModel.isAllReceived = isAllReceived
        messageModel.isAllRead = isAllRead
        messageModel.messageType = messageType
        messageModel.ratio = ratio
        messageModel.size = size
        messageModel.thumbnailURL = thumbnailURL
        messageModel.imageURL = imageUrl
        messageModel.filePath = filePath
        messageModel.geocode = geocode
        messageModel.fileMetaInfo = fileMetaInfo
        messageModel.receiverId = to
        messageModel.isReplyMessage = isAReplyMessage()
        messageModel.metadata = metadata as? Dictionary<String, Any>
        return messageModel
    }
}

extension ALMessage {
    override open func isEqual(_ object: Any?) -> Bool {
        if let object = object as? ALMessage, let objectKey = object.key, let key = self.key {
            return key == objectKey
        } else {
            return false
        }
    }
}
