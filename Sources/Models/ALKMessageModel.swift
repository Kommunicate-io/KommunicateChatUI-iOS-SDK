//
//  ALKMessageModel.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by Mukesh Thawani on 04/05/17.
//

import Foundation
import KommunicateCore_iOS_SDK
#if canImport(RichMessageKit)
    import RichMessageKit
#endif

// MARK: - MessageType

public enum ALKMessageType: String {
    case text = "Text"
    case photo = "Photo"
    case voice = "Audio"
    case location = "Location"
    case information = "Information"
    case video = "Video"
    case html = "HTML"
    case quickReply = "QuickReply"
    case button = "Button"
    case listTemplate = "ListTemplate"
    case cardTemplate = "CardTemplate"
    case email = "Email"
    case document = "Document"
    case faqTemplate = "FAQTemplate"
    case imageMessage = "ImageMessage"
    case allButtons = "AllButtons"
    case form = "Form"
    case staticTopMessage = "staticTopMessage"
    case videoTemplate = "VideoTemplate"
}

// MARK: - MessageViewModel

public protocol ALKMessageViewModel {
    var message: String? { get }
    var isMyMessage: Bool { get }
    var messageType: ALKMessageType { get }
    var identifier: String { get }
    var date: Date { get }
    var time: String? { get }
    var avatarURL: URL? { get }
    var displayName: String? { get }
    var contactId: String? { get }
    var channelKey: NSNumber? { get }
    var conversationId: NSNumber? { get }
    var isSent: Bool { get }
    var isAllReceived: Bool { get }
    var isAllRead: Bool { get }
    var ratio: CGFloat { get }
    var size: Int64 { get }
    var thumbnailURL: URL? { get }
    var imageURL: URL? { get }
    var filePath: String? { get set }
    var geocode: Geocode? { get }
    var voiceData: Data? { get set }
    var voiceTotalDuration: CGFloat { get set }
    var voiceCurrentDuration: CGFloat { get set }
    var voiceCurrentState: ALKVoiceCellState { get set }
    var fileMetaInfo: ALFileMetaInfo? { get }
    var receiverId: String? { get }
    var isReplyMessage: Bool { get }
    var metadata: [String: Any]? { get }
    var source: Int16 { get }
    var contentType: Message.ContentType { get }
    var createdAtTime : NSNumber? { get set }
}

public class ALKMessageModel: ALKMessageViewModel {
    public var contentType = Message.ContentType.text
    public var message: String? = ""
    public var isMyMessage: Bool = false
    public var messageType: ALKMessageType = .text
    public var identifier: String = ""
    public var date = Date()
    public var time: String?
    public var avatarURL: URL?
    public var displayName: String?
    public var contactId: String?
    public var conversationId: NSNumber?
    public var channelKey: NSNumber?
    public var isSent: Bool = false
    public var isAllReceived: Bool = false
    public var isAllRead: Bool = false
    public var ratio: CGFloat = 0.0
    public var size: Int64 = 0
    public var thumbnailURL: URL?
    public var imageURL: URL?
    public var filePath: String?
    public var geocode: Geocode?
    public var voiceTotalDuration: CGFloat = 0
    public var voiceCurrentDuration: CGFloat = 0
    public var voiceCurrentState: ALKVoiceCellState = .stop
    public var voiceData: Data?
    public var fileMetaInfo: ALFileMetaInfo?
    public var receiverId: String?
    public var isReplyMessage: Bool = false
    public var metadata: [String: Any]?
    public var source: Int16 = 0
    public var createdAtTime: NSNumber?
}

extension ALKMessageModel: Equatable {
    public static func == (lhs: ALKMessageModel, rhs: ALKMessageModel) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}

extension ALKMessageViewModel {
    var isMessageEmpty: Bool {
        guard let messageString = message, !messageString.trim().isEmpty else {
            return true
        }
        return false
    }

    var containsMentions: Bool {
        // Only check when it's a group
        guard channelKey != nil, let mentionParser = mentionParser else {
            return false
        }
        return mentionParser.containsMentions
    }

    var mentionedUserIds: Set<String>? {
        return mentionParser?.mentionedUserIds()
    }

    private var mentionParser: MessageMentionDecoder? {
        guard let message = message,
              let metadata = metadata,
              !metadata.isEmpty
        else {
            return nil
        }
        let mentionParser = MessageMentionDecoder(message: message, metadata: metadata)
        return mentionParser
    }

    func attributedTextWithMentions(
        defaultAttributes: [NSAttributedString.Key: Any],
        mentionAttributes: [NSAttributedString.Key: Any],
        displayNames: ((Set<String>) -> ([String: String]?))?
    ) -> NSAttributedString? {
        guard containsMentions,
              let userIds = mentionedUserIds,
              let names = displayNames?(userIds),
              let attributedText = mentionParser?.messageWithMentions(
                  displayNamesOfUsers: names,
                  attributesForMention: mentionAttributes,
                  defaultAttributes: defaultAttributes
              )
        else {
            return nil
        }
        return attributedText
    }

    func payloadFromMetadata() -> [[String: Any]]? {
        guard let metadata = metadata, let payload = metadata["payload"] as? String else { return nil }
        let data = payload.data
        let jsonArray = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
        guard let quickReplyArray = jsonArray as? [[String: Any]] else { return nil }
        return quickReplyArray
    }
}

public extension ALKMessageViewModel {
    var status: ALKMessageStatus {
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

public struct KMField : Decodable {
    public var label: String?
    public var field: String?
    public var fieldType: String?
    public var placeholder: String?
    public var action: Action?
    public var validation: [String : String]?
    
    public struct Action : Decodable {
        public var updateUserDetails : Bool?
    }
    
}

extension ALKMessageViewModel {
    
    func getKmField() -> KMField? {
        do {
            guard let metadata = metadata, let payload = metadata["KM_FIELD"] as? String else {
                return nil
            }
            let kmFieldData = payload.data(using: .utf8)
            guard let kmFieldData = kmFieldData else {
                return nil
            }
            let kmField = try JSONDecoder().decode(KMField.self, from: kmFieldData)
            return kmField
        } catch {
            print("Error decoding KmField: \(error)")
        }
        return nil
    }

    func getReplyMetaData() -> [String:String]? {
        do {
            guard let metadata = metadata, let replyMetadata = metadata["replyMetadata"] as? String else {
                return nil
            }
            let replydata = replyMetadata.data(using: .utf8)
            guard let replydata = replydata else {
                return nil
            }
            let replyMetaData = try JSONDecoder().decode([String : String].self, from: replydata)
            return replyMetaData
        } catch {
            print("Error decoding replyMetaData: \(error)")
        }
        return nil
    }

    func isCustomDataRichMessage() -> Bool {
        guard let metadata = metadata, metadata["KM_FIELD"] != nil else {
            return false
        }
        return true
    }
    
}
