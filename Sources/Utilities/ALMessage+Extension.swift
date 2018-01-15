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

extension ALMessage {

    var isMyMessage: Bool {
        return self.type == myMessage
    }

    var messageType: ALKMessageType {
        if contentType == Int16(ALMESSAGE_CONTENT_DEFAULT) {
            return .text
        } else if contentType == Int16(ALMESSAGE_CONTENT_LOCATION) {
            return .location
        } else if contentType == Int16(ALMESSAGE_CHANNEL_NOTIFICATION) {
            return .information
        } else if contentType == Int16(ALMESSAGE_CONTENT_TEXT_HTML) {
            return .html
        } else if let fileMeta = fileMeta {
            if fileMeta.contentType.hasPrefix("image") {
                return .photo
            } else if fileMeta.contentType.hasPrefix("audio") {
                return .voice
            } else if fileMeta.contentType.hasPrefix("video") {
                return .video
            }
        }
        return .text
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

}

extension ALMessage {

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
