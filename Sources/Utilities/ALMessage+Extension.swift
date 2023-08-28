//
//  ALMessage+Extension.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by Mukesh Thawani on 04/05/17.
//

import Foundation
import KommunicateCore_iOS_SDK
import MapKit
#if canImport(RichMessageKit)
    import RichMessageKit
#endif
let friendsMessage = "4"
let myMessage = "5"

let imageBaseUrl = ALUserDefaultsHandler.getFILEURL() + "/rest/ws/aws/file/"

enum ChannelMetadataKey {
    static let conversationSubject = "KM_CONVERSATION_SUBJECT"
}

let emailSourceType = 7

extension ALMessage: ALKChatViewModelProtocol {
    private var alContact: ALContact? {
        let alContactDbService = ALContactDBService()
        guard let alContact = alContactDbService.loadContact(byKey: "userId", value: to) else {
            return nil
        }
        return alContact
    }

    private var alChannel: ALChannel? {
        let alChannelService = ALChannelService()

        // TODO: This is a workaround as other method uses closure.
        // Later replace this with:
        // alChannelService.getChannelInformation(, orClientChannelKey: , withCompletion: )
        guard let groupId = groupId,
              let alChannel = alChannelService.getChannelByKey(groupId)
        else {
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
        return isGroupChat ? UIImage(named: "group_profile_picture-1", in: Bundle.km, compatibleWith: nil) : nil
    }

    public var avatarGroupImageUrl: String? {
        guard let alChannel = alChannel, let avatar = alChannel.channelImageURL else {
            return nil
        }
        return avatar
    }
    
    func fetchCustomBotName(userId: String) -> String {
        guard let customBotId = ALApplozicSettings.getCustomizedBotId(),
              customBotId == userId,
              let customBotName = ALApplozicSettings.getCustomBotName()
        else { return "" }

        return customBotName
    }
    
    public var name: String {
        guard let alContact = alContact, let id = alContact.userId else {
            return ""
        }
        
        let customBotName = fetchCustomBotName(userId: id)
        // if its not empty,custom bot name is available.
        guard customBotName.isEmpty else {
            return customBotName
        }
        
        guard let displayName = alContact.getDisplayName(), !displayName.isEmpty else { return id }

        return displayName
    }
   
    public var groupName: String {
        guard let alChannel = alChannel else { return "" }
        let name = alChannel.name ?? ""
        guard
            let userId = alChannel.getReceiverIdInGroupOfTwo(),
            let contact = ALContactDBService().loadContact(byKey: "userId", value: userId)
        else {
            return name
        }
        return contact.getDisplayName()
    }
    public var theLastMessage: String? {
        var defaultMessage = "Message"
        switch messageType {
        case .text:
            return message
        case .photo, .video, .voice:
            return (filePath ?? "").isEmpty ? defaultMessage : filePath
        case .location:
            return "Location"
        case .information, .html, .allButtons:
            return isMessageEmpty ? defaultMessage : message
        case .faqTemplate:
            return isMessageEmpty ? "FAQ" : message
        case .button,
             .form,
             .quickReply,
             .listTemplate,
             .imageMessage,
             .cardTemplate:
            return latestRichMessageText()
        case .email:
            guard let channelMetadata = alChannel?.metadata,
                  let messageText = channelMetadata[ChannelMetadataKey.conversationSubject]
            else {
                return message
            }
            return messageText as? String
        case .document:
            let path = ALKFileUtils().getFileName(filePath: filePath, fileMeta: fileMeta)
            return path.isEmpty ? "File" : path
        case .staticTopMessage:
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
        guard let key = key else {
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
        guard groupId != nil else {
            return false
        }
        return true
    }

    public var contactId: String? {
        return contactIds
    }

    public var channelKey: NSNumber? {
        return groupId
    }

    public var createdAt: String? {
        let isToday = ALUtilityClass.isToday(date)
        return getCreatedAtTime(isToday)
    }

    public var channelType: Int16 {
        guard let alChannel = alChannel else { return 0 }
        return alChannel.type
    }

    public var isMessageEmpty: Bool {
        return message == nil || message != nil && message.trim().isEmpty
    }

    public var messageMetadata: NSMutableDictionary? {
        return metadata
    }
    
    public var platformSource: String? {
        guard let sourceChannel = ALChannelDBService().getChannelByKey(channelKey) else { return ""}
        if sourceChannel.platformSource == nil, let channel = ALChannelService().getChannelByKey(channelKey), let sourceFromMeta = channel.metadata.value(forKey: "source") {
            ALChannelDBService().updatePlatformSource(channelKey, platformSource: sourceFromMeta as? String)
        }
        
        let source = sourceChannel.platformSource
        return source
    }
}

extension ALMessage {
    var isMyMessage: Bool {
        return (type != nil) ? (type == myMessage) : false
    }

    public var messageType: ALKMessageType {
        guard source != emailSourceType else {
            // Attachments come as separate message.
            if message == nil, let type = getAttachmentType() {
                return type
            }
            return .email
        }
        
        if let uploadUrl = ALApplozicSettings.getDefaultOverrideuploadUrl(), !uploadUrl.isEmpty, Int32(contentType) == ALMESSAGE_CONTENT_ATTACHMENT {
            return richMessageType()
        }
        
        switch Int32(contentType) {
        case ALMESSAGE_CONTENT_DEFAULT:
            return richMessageType()
        case ALMESSAGE_CONTENT_LOCATION:
            return .location
        case ALMESSAGE_CHANNEL_NOTIFICATION:
            return .information
        case ALMESSAGE_CONTENT_TEXT_HTML:
            return richMessageType()
        case ALMESSAGE_CONTENT_INITIAL_STATIC_MESSAGE:
            return .staticTopMessage
        default:
            guard let attachmentType = getAttachmentType() else { return .text }
            return attachmentType
        }
    }

    var date: Date {
        guard let time = createdAtTime else { return Date() }
        let sentAt = Date(timeIntervalSince1970: Double(time.doubleValue / 1000))
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
        guard let fileMeta = fileMeta, let fileMetaSize = fileMeta.size, let size = Int64(fileMetaSize) else {
            return 0
        }
        return size
    }

    var thumbnailURL: URL? {
        guard let fileMeta = fileMeta, let urlStr = fileMeta.thumbnailUrl, let url = URL(string: urlStr) else {
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

        // Returns lat, long
        func getCoordinates(from message: String) -> (Any, Any)? {
            guard let messageData = message.data(using: .utf8),
                  let jsonObject = try? JSONSerialization.jsonObject(
                      with: messageData,
                      options: .mutableContainers
                  ),
                  let messageJSON = jsonObject as? [String: Any]
            else {
                return nil
            }
            guard let lat = messageJSON["lat"],
                  let lon = messageJSON["lon"]
            else {
                return nil
            }
            return (lat, lon)
        }

        guard let message = message,
              let (lat, lon) = getCoordinates(from: message)
        else {
            return nil
        }
        // Check if type is double or string
        if let lat = lat as? Double,
           let lon = lon as? Double
        {
            let location = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            return Geocode(coordinates: location)
        } else {
            guard let latString = lat as? String,
                  let lonString = lon as? String,
                  let lat = Double(latString),
                  let lon = Double(lonString)
            else {
                return nil
            }
            let location = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            return Geocode(coordinates: location)
        }
    }

    var fileMetaInfo: ALFileMetaInfo? {
        return fileMeta ?? nil
    }

    private func getAttachmentType() -> ALKMessageType? {
        guard let fileMeta = fileMeta, let contentType = fileMeta.contentType else { return nil }
        if contentType.hasPrefix("image") {
            return .photo
        } else if contentType.hasPrefix("audio") {
            return .voice
        } else if contentType.hasPrefix("video") {
            return .video
        } else {
            return .document
        }
    }

    private func richMessageType() -> ALKMessageType {
        guard let metadata = metadata,
              let contentType = metadata["contentType"] as? String, contentType == "300",
              let templateId = metadata["templateId"] as? String
        else {
            switch Int32(self.contentType) {
            case ALMESSAGE_CONTENT_DEFAULT:
                return .text
            case ALMESSAGE_CONTENT_TEXT_HTML:
                return .html
            case ALMESSAGE_CONTENT_ATTACHMENT:
                return getAttachmentType() ?? .text
            default:
                return .text
            }
        }
        switch templateId {
        case "3":
            return .button
        case "6":
            return .quickReply
        case "7":
            return .listTemplate
        case "8":
            return .faqTemplate
        case "9":
            return .imageMessage
        case "10":
            return .cardTemplate
        case "11":
            return .allButtons
        case "12":
            return .form
        default:
            return .text
        }
    }

    func latestRichMessageText() -> String {
        switch Int32(contentType) {
        case ALMESSAGE_CONTENT_DEFAULT:
            return isMessageEmpty ? "Message" : message
        case ALMESSAGE_CONTENT_TEXT_HTML:
            return "Message"
        default:
            return isMessageEmpty ? "Message" : message
        }
    }
}

public extension ALMessage {
    var messageModel: ALKMessageModel {
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
        messageModel.metadata = metadata as? [String: Any]
        messageModel.source = source
        if let messageContentType = Message.ContentType(rawValue: contentType) {
            messageModel.contentType = messageContentType
        }
        return messageModel
    }
}

extension ALMessage {
    override open func isEqual(_ object: Any?) -> Bool {
        if let object = object as? ALMessage, let objectKey = object.key, let key = key {
            return key == objectKey
        } else {
            return false
        }
    }
}
