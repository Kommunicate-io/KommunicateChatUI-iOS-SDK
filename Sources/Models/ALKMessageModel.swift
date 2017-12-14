//
//  ALKMessageModel.swift
//  
//
//  Created by Mukesh Thawani on 04/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import Foundation
import Applozic

let MessageProgressKey = "Message.ProgressKey"

public class ALKMessageModel: ALKMessageViewModel {

    public var message: String? = ""
    public var isMyMessage: Bool = false
    public var messageType: ALKMessageType = .text
    public var identifier: String = ""
    public var date: Date = Date()
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
}

extension ALKMessageModel: Equatable {
    public static func ==(lhs: ALKMessageModel, rhs: ALKMessageModel) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}
