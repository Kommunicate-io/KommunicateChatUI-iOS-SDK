//
//  KMZendeskChatHandler.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by sathyan elangovan on 28/11/22.
//

import Foundation
import ChatSDK
import ChatProvidersSDK
import KommunicateCore_iOS_SDK

struct KommunicateURL {
    static let attachmentURL = "https://chat.kommunicate.io/rest/ws/attachment/"
    static let dashboardURL = "https://dashboard.kommunicate.io/conversations/"
    static let jwtURL = "https://api.kommunicate.io/rest/ws/zendesk/jwt"
}

public class KMZendeskChatHandler : NSObject, JWTAuthenticator {

    public static let shared = KMZendeskChatHandler()
    var groupId: String = ""
    var zenChatIntialized = false
    var userId = ""
    var isChatTranscriptSent = false
    var isHandOffHappened = false
    var lastUserMessageCreatedTime: NSNumber = 0
    var messageBufffer = [ALMessage]()

    var jwtToken: String = "" {
        didSet {
            guard !jwtToken.isEmpty else {
                resetIdentity()
                return
            }
            Chat.instance?.setIdentity(authenticator: self)
        }
    }
    
    public func initiateZendesk(key: String) {
        Chat.initialize(accountKey: key)
        zenChatIntialized = true
        fetchUserId()
        authenticateUser()
    }
    
    public func updateHandoff(_ value: Bool) {
        self.isHandOffHappened = value
    }
    
    public func getToken(_ completion: @escaping (String?, Error?) -> Void) {
        completion(jwtToken,nil)
    }
    
    func observeChatLogs() {
        guard Chat.connectionProvider?.status == .connected else {
            connectToZendeskSocket()
            return
        }
        
        let stateToken = Chat.chatProvider?.observeChatState { (state) in
            // Handle logs, agent events, queue position changes and other events
            self.processChatLogs(logs: state.logs)
        }
        // TODO: Handle Disconnection of all observe token
        chatLogToken = stateToken
        
        let connectionToken = Chat.connectionProvider?.observeConnectionStatus { [self] (connection) in
            // Handle connection status changes
            guard connection.isConnected else {
               return
            }
            processBufferMessages()
       }
    }
    
    func fetchUserId() {
        guard let id = ALUserDefaultsHandler.getUserId() else {return}
        self.userId = id
    }
    
    public func handedOffToAgent(groupId: String) {
        self.groupId = groupId
        isHandOffHappened = true
        sendChatInfo()
        sendChatTranscript()
    }

    public func getGroupId() -> String {
        return groupId
    }
    
    public func setGroupIdAndUpdateLastMessageCreatedTime(_ groupId: String) {
        self.groupId = groupId
        self.updateLastMessageCreatedTime()
    }
   
    func authenticateUser() {
        let userHandler = ALUserDefaultsHandler.self
        
        if let externalId = userHandler.getUserId(),!externalId.isEmpty,
           let name = userHandler.getDisplayName(),!name.isEmpty,
           let email = userHandler.getEmailId(),!email.isEmpty {
            authenticateUserWithJWT(name: name, email: email, externalId: externalId)
        }
    }
    
    func authenticateUserWithJWT(name: String, email: String, externalId: String) {
        let dictionary = ["name":name, "email": email, "externalId":externalId]

        let postdata: Data? = try? JSONSerialization.data(withJSONObject: dictionary, options: [])
        var theParamString: String? = nil
        if let aPostdata = postdata {
            theParamString = String(data: aPostdata, encoding: .utf8)
        }
        
        guard let postURLRequest = ALRequestHandler.createPOSTRequest(withUrlString: KommunicateURL.jwtURL, paramString: theParamString) as NSMutableURLRequest? else { return }
        let responseHandler = ALResponseHandler()
        
        responseHandler.authenticateAndProcessRequest(postURLRequest, andTag: "") {
            (json, error) in
            guard error == nil else {
                return
            }
            guard let dict = json as? [String: Any], let data = dict["data"] as? [String: Any], let jwtKey = data["jwt"] as? String else {
                return
            }
            self.jwtToken = jwtKey
            // Connect to their server after authentication
            self.connectToZendeskSocket()
        }
    }
    
    var chatLogToken : ObservationToken?
    
    func connectToZendeskSocket() {
        guard let connectionProvider = Chat.connectionProvider else {
            return
        }
        connectionProvider.connect()
        self.observeChatLogs()
    }
    
    func sendMessage(message: ALMessage) {
        guard isHandOffHappened else {return}
        
        guard let connectionProvider = Chat.connectionProvider, connectionProvider.status == .connected else {
            addMessageToBuffer(message: message)
            connectToZendeskSocket()
            return
        }
        sendMessageToZendesk(message: message.message) { (result) in
            switch result {
            case .success:
                print("Message Sent to Zendesk Successfully")
                self.lastUserMessageCreatedTime = message.createdAtTime
                if self.messageBufffer.contains(message) {
                    self.messageBufffer.remove(object: message)
                }
            case .failure(let error):
                print("Failed Send the Message to Zendesk \(error)")
            }
        }
    }
    
    func sendMessageToZendesk(message: String, completionHandler: @escaping (Result<String, ChatProvidersSDK.DeliveryStatusError>) -> Void) {
        guard let connectionProvider = Chat.connectionProvider, connectionProvider.status == .connected else {
            connectToZendeskSocket()
            return
        }
        Chat.chatProvider?.sendMessage(message) { (result) in
            print("send message result \(result) for message \(message)")
            completionHandler(result)
        }
    }
    
    func addMessageToBuffer(message:ALMessage) {
        guard !messageBufffer.contains(message) else {
            return
        }
        messageBufffer.append(message)
    }
    
    func sendChatTranscript() {
        let channelKey = NSNumber(value: Int(groupId) ?? 0)
        guard channelKey != 0 else {
            print("Failed to fetch messages for channel key \(channelKey)")
            return
        }
     
        fetchMessages(channelKey:channelKey){[self] messages,error,userArray in
            print("FETCHED MESSAGES FOR CHAT TRANSCRIPT")
            guard let messageList = messages,
                  let userDetails = userArray as? [ALUserDetail],
                  !userDetails.isEmpty,
                  let almessages = messageList.reversed() as? [ALMessage] else {
                return
            }
            // Set Last user Message created time
            lastUserMessageCreatedTime = almessages.last?.createdAtTime ?? 0
            var transcriptString = "Transcript:\n"

            for currentMessage in almessages {
                guard !currentMessage.isMsgHidden() || currentMessage.isAssignmentMessage() else {continue}
                var userName = ""
                if currentMessage.to == self.userId {
                    userName = "User"
                } else {
                    //get the bot name
                    userName = getBotNameById(botId: currentMessage.to, userdetails: userDetails)
                }
                let message = getMessageForTranscript(message: currentMessage)
                guard !userName.isEmpty && !message.isEmpty else {continue}
                transcriptString.append("\(userName): \(message)\n")
            }

            sendMessageToZendesk(message: transcriptString, completionHandler: { (result) in
                switch result {
                case .success:
                    self.isChatTranscriptSent = true
                    print("Chat Transcript Sent to Zendesk Successfully")
                case .failure(let error):
                    print("Failed Send the chat transcript to Zendesk \(error)")
                }
            })
        }
    }
    
    func getBotNameById(botId: String,userdetails:[ALUserDetail]) -> String {
        for userdetail in userdetails {
            if userdetail.userId == botId {
                return userdetail.displayName ?? ""
            }
        }
        return ""
    }
    
    func processChatLogs(logs: [ChatLog]) {
        guard lastUserMessageCreatedTime != 0 else { return }
        let filteredArray = logs.filter{$0.createdTimestamp >= TimeInterval(truncating: lastUserMessageCreatedTime)}
        processAgentMessage(message: filteredArray)
    }
    
    func getMessageForTranscript(message:ALMessage) -> String {
        //To be handled for other scenarios
        if let message = message.message, !message.isEmpty {
            return message
        } else if let fileMeta = message.fileMeta, let blobkey = fileMeta.blobKey {
            return "\(KommunicateURL.attachmentURL)\(blobkey)"
        } else if let metadata = message.metadata, let templateId = metadata["templateId"] {
            return "TemplateId: \(templateId)"
        }
        return ""
    }
    
    func sendChatInfo() {
        let infoString = "This chat is initiated from kommunicate widget, look for more here: \(KommunicateURL.dashboardURL)\(groupId)"

        sendMessageToZendesk(message: infoString, completionHandler: {(result) in
            switch result {
            case .success(let messageId):
              print("info message sent successfully \(messageId)")
            case .failure(let error):
              print("Failed to send info message due to \(error)")
            }
        })
    }
    
    public func disconnectFromZendesk() {
        Chat.connectionProvider?.disconnect()
        resetConfiguration()
        resetIdentity()
    }
    
    public func resetConfiguration() {
        isHandOffHappened = false
        zenChatIntialized = false
        lastUserMessageCreatedTime = 0
        messageBufffer.removeAll()
    }
    
    func sendAttachment(message:ALMessage){
        ALMessageClientService().downloadImageUrlV2(message.fileMetaInfo?.blobKey, isS3URL: message.fileMetaInfo?.url != nil) { fileUrl, error in
            guard error == nil, let fileUrl = fileUrl, let url = URL(string: fileUrl) else {
                print("Error Finding attachment URL :: \(String(describing: error))")
                return
            }

            Chat.chatProvider?.sendFile(url:url , onProgress: { (progress) in
                print("attachment progress \(progress)")}, completion: { result in
                    switch result {
                        case .success:
                            print("Attachment sent to zendesk successfully")
                            break
                        case .failure(let error):
                            print("Failed to send attachment \(error)")
                            break
                    }
                })
            }
    }
        
    public func isChatGoingOn(completion: @escaping (Bool) -> Void) {
        // This API proactively connects to web sockets for authenticated users. This connection is kept alive. You should call disconnect() on the ConnectionProvider if you don't need to keep it open.
        guard let chatProvider = Chat.chatProvider else {
            return completion(false)
        }
        chatProvider.getChatInfo { (result) in
            switch result {
            case .success(let chatInfo):
                completion(chatInfo.isChatting)
            case .failure(let error):
                completion(false)
            }
        }
    }
    
    public func isZendeskEnabled() -> Bool {
        guard let key = ALApplozicSettings.getZendeskSdkAccountKey(), !key.isEmpty, zenChatIntialized else {
            return false
        }
        return true
    }
    
    func updateLastMessageCreatedTime() {
        let channelKey = NSNumber(value: Int(groupId) ?? 0)
        guard channelKey != 0 else {
            print("Failed to fetch messages for group Id")
            return
        }
        
        fetchMessages(channelKey: channelKey){ messages,error,userArray in
            guard let messageList = messages,
                  let almessages = messageList.reversed() as? [ALMessage] else {
                return
            }
            self.lastUserMessageCreatedTime = almessages.last?.createdAtTime ?? 0
        }
    }
    
    func processBufferMessages() {
        for message in messageBufffer {
            sendMessage(message: message)
        }
    }
    
    func processAgentMessage(message: [ChatLog]) {
        // TODO: Send only Agent messsages to Kommunicate Server via api
        // TODO: Call resolve api when zendesk agent leaves the conversation
    }
    
    func fetchMessages(channelKey: NSNumber,completion: @escaping (_ messages: NSMutableArray?, _ error: Error?, _ userDetails: NSMutableArray?) -> Void) {
        
        let messageListRequest = MessageListRequest()
        messageListRequest.channelKey = channelKey
        if let channel = ALChannelService().getChannelByKey(channelKey) {
            messageListRequest.channelType = channel.type
        }
        
        ALMessageClientService().getMessageList(forUser: messageListRequest, withOpenGroup: messageListRequest.channelType == 6) { messages,error,userArray in
            completion(messages,error,userArray)
        }
    }
    
    func resetIdentity() {
        /// Any ongoing chat will be ended, and locally stored information about the visitor will be cleared
        Chat.instance?.resetIdentity {}
    }
}


