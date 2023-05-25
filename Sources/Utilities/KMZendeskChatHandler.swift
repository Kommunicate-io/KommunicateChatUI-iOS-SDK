//
//  KMZendeskChatHandler.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by sathyan elangovan on 28/11/22.
//

import Foundation
import ChatProvidersSDK
import KommunicateCore_iOS_SDK

struct KommunicateURL {
    static let attachmentURL = "https://chat.kommunicate.io/rest/ws/attachment/"
    static let dashboardURL = "https://dashboard.kommunicate.io/conversations/"
    static let jwtURL = "https://api.kommunicate.io/rest/ws/zendesk/jwt"
    static let sendMessage = "https://api.kommunicate.io/rest/ws/zendesk/message/send"
    static let sendAttachment = "https://api.kommunicate.io/rest/ws/zendesk/file/send"
    static let resolveConversation = "https://chat.kommunicate.io/rest/ws/group/status/change?groupId="
    static let logApi = "https://api.kommunicate.io/rest/ws/tools/log"
}

public protocol KMZendeskChatProtocol {
    func initiateZendesk(key: String)
    func updateHandoffFlag(_ value: Bool)
    func handedOffToAgent(groupId: String)
    func disconnectFromZendesk()
    func resetConfiguration()
    func endChat()
    func setGroupId(_ groupId: String)
}

public class KMZendeskChatHandler : NSObject, JWTAuthenticator, KMZendeskChatProtocol {
    
    public static let shared = KMZendeskChatHandler()
    var groupId: String = ""
    var zenChatIntialized = false
    var userId = ""
    var isChatTranscriptSent = false
    var isHandOffHappened = false
    var messageBufffer = [ALMessage]()
    
    var lastSyncTime: NSNumber = 0
    var rootViewController : UIViewController? = nil
    var chatLogToken : ObservationToken?
    var connectionToken: ObservationToken?
    let sendUserMessageGroup = DispatchGroup()
    let sendAgentMessageGroup = DispatchGroup()
    
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
        guard !zenChatIntialized else {
            return
        }
        Chat.initialize(accountKey: key)
        zenChatIntialized = true
        fetchUserId()
        authenticateUser()
    }
    
    public func updateHandoffFlag(_ value: Bool) {
        self.isHandOffHappened = value
    }
    
    public func getToken(_ completion: @escaping (String?, Error?) -> Void) {
        completion(jwtToken,nil)
    }
    
    public func handedOffToAgent(groupId: String) {
        lastSyncTime = NSDate().timeIntervalSince1970 * 1000 as NSNumber
        self.groupId = groupId
        isHandOffHappened = true
        sendChatInfo()
        sendChatTranscript()
    }
    
    public func setGroupId(_ groupId: String) {
        self.groupId = groupId
    }
    
    public func disconnectFromZendesk() {
        Chat.connectionProvider?.disconnect()
        resetConfiguration()
        resetIdentity()
    }
    
    public func resetConfiguration() {
        isHandOffHappened = false
        zenChatIntialized = false
        lastSyncTime = 0
        messageBufffer.removeAll()
        chatLogToken?.cancel()
        connectionToken?.cancel()
    }
    
    public func isZendeskEnabled() -> Bool {
        guard let key = ALApplozicSettings.getZendeskSdkAccountKey(), !key.isEmpty, zenChatIntialized else {
            return false
        }
        return true
    }
    
    public func endChat() {
        guard zenChatIntialized else  { return }
        Chat.instance?.chatProvider.endChat(){ result in
            switch result {
            case let .success(status):
                print("Successfully ended the zendesk chat", status)
                self.disconnectFromZendesk()
            case let .failure(error):
                print("Failed to end the zendesk chat : %@", error.localizedDescription)
            }
        }
    }
    
    func connectToZendeskSocket() {
        guard let connectionProvider = Chat.connectionProvider else {
            return
        }
        // Connecting to zeendesk server
        connectionProvider.connect()

        connectionToken = Chat.instance?.connectionProvider.observeConnectionStatus { [self] (connection) in
            // Handle connection status changes
            guard connection.isConnected else {
                sendLogToKMServer(message: "iOS SDK: Socket connnection status is false in observer for conversation \(groupId).Retrying Connection..")
                print("connecting to zendesk socket")
                connectionProvider.connect()
                return
            }
            self.observeChatLogs()
            self.processBufferMessages()
       }
    }
    
    func observeChatLogs() {
        lastSyncTime = ALApplozicSettings.getZendeskLastSyncTime() ?? 0
        let stateToken = Chat.chatProvider?.observeChatState { (state) in
            // Handle logs, agent events, queue position changes and other events
            self.processChatLogs(logs: state.logs)
        }
        chatLogToken = stateToken
    }
    
    func fetchUserId() {
        guard let id = ALUserDefaultsHandler.getUserId() else {return}
        self.userId = id
    }
    
    func authenticateUser() {
        let userHandler = ALUserDefaultsHandler.self
        
        if let externalId = userHandler.getUserId(),!externalId.isEmpty,
           let name = userHandler.getDisplayName(),!name.isEmpty,
           let email = userHandler.getEmailId(),!email.isEmpty {
            authenticateUserWithJWT(name: name, email: email, externalId: externalId)
        } else {
            // Connect to Zendesk Socket as a visitor.
            connectToZendeskSocket()
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
                self.connectToZendeskSocket()
                return
            }
            guard let dict = json as? [String: Any], let data = dict["data"] as? [String: Any], let jwtKey = data["jwt"] as? String else {
                self.connectToZendeskSocket()
                return
            }
            self.jwtToken = jwtKey
            // Connect to Zendesk server after authentication
            self.connectToZendeskSocket()
        }
    }
    
    func sendLogToKMServer(message: String) {
        let body = ["message":message]
        let postdata: Data? = try? JSONSerialization.data(withJSONObject: body, options: [])
        var theParamString: String? = nil
        if let aPostdata = postdata {
            theParamString = String(data: aPostdata, encoding: .utf8)
        }
        
        guard let postURLRequest = ALRequestHandler.createPOSTRequest(withUrlString: KommunicateURL.logApi, paramString: theParamString) as NSMutableURLRequest? else { return }
        let responseHandler = ALResponseHandler()
        
        responseHandler.authenticateAndProcessRequest(postURLRequest, andTag: "") {
            (json, error) in
            guard error == nil else {
                print("Failed to send zendesk logs to server \(error?.localizedDescription)")
                return
            }
            guard let dict = json as? [String: Any], let code = dict["code"] as? String, code == "SUCCESS" else {
                print("Failed to send zendesk logs to server")
                return
            }
        }
    }
    
    func sendMessage(message: ALMessage) {
        guard isHandOffHappened else {
            sendLogToKMServer(message: "iOS SDK:Failed to send message\(message.messageId) to zendesk due to handoff")
            return
        }
        
        guard let connectionProvider = Chat.connectionProvider, connectionProvider.status == .connected else {
            addMessageToBuffer(message: message)
            connectToZendeskSocket()
            sendLogToKMServer(message: "iOS SDK:Failed to send message\(message.messageId) to zendesk due to Socket Connection. Retrying connection..")
            return
        }
        sendMessageToZendesk(message: message.message) { (result) in
            switch result {
            case .success:
                print("Message Sent to Zendesk Successfully")
                self.removeMessageFromBuffer(message: message)
            case .failure(let error):
                print("Failed Send the Message to Zendesk \(error)")
                self.addMessageToBuffer(message: message)
                self.sendLogToKMServer(message: "iOS SDK:Failed to send message\(message.messageId) to zendesk due to error zendesk api error: \(error.localizedDescription)")
            }
        }
    }
    
    func sendMessageToZendesk(message: String, completionHandler: @escaping (Result<String, ChatProvidersSDK.DeliveryStatusError>) -> Void) {
        sendUserMessageGroup.enter()
        Chat.chatProvider?.sendMessage(message) { (result) in
            print("send message result \(result) for message \(message)")
            self.sendUserMessageGroup.leave()
            completionHandler(result)
        }
    }
    
    func addMessageToBuffer(message:ALMessage) {
        guard !messageBufffer.contains(message) else {
            return
        }
        messageBufffer.append(message)
    }
    
    func removeMessageFromBuffer(message:ALMessage) {
        if messageBufffer.contains(message) {
            messageBufffer.remove(object: message)
        }
    }
    func sendChatTranscript() {
        let channelKey = NSNumber(value: Int(groupId) ?? 0)
        guard channelKey != 0 else {
            sendLogToKMServer(message: "iOS SDK:Failed to send Chat Transcript \(channelKey) to zendesk due invalid groupid")
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
            //for logs
            let transcriptMessage = ALMessage()
            transcriptMessage.message = transcriptString
            
            guard isHandOffHappened else {
                addMessageToBuffer(message: transcriptMessage)
                sendLogToKMServer(message: "iOS SDK: Failed to send Chat Transcript \(channelKey) to zendesk due to handoff")
                return
            }
            

            guard let connectionProvider = Chat.connectionProvider, connectionProvider.status == .connected else {
                addMessageToBuffer(message: transcriptMessage)
                connectToZendeskSocket()
                sendLogToKMServer(message: "iOS SDK: Failed Send the Chat Transcript \(channelKey)  due to socket conneciton.Retrying connection..")
                return
            }

            sendMessageToZendesk(message: transcriptString, completionHandler: { (result) in
                switch result {
                case .success:
                    self.isChatTranscriptSent = true
                    print("Chat Transcript Sent to Zendesk Successfully")
                case .failure(let error):
                    print("Failed Send the chat transcript to due Zendesk api \(error)")
                    self.addMessageToBuffer(message: transcriptMessage)
                    self.sendLogToKMServer(message: "iOS SDK: Failed Send the Chat Transcript due to Zendesk api \(error)")
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
        let filteredArray = logs.filter{$0.createdTimestamp >= TimeInterval(truncating: lastSyncTime)}
        for log in filteredArray {
            // If log is not from agent, then no need to consider the log.
            guard log.participant == .agent else { continue }
            
            switch log.type {
                case .message:
                    print("Received Agent Message \(log.description)")
                    processAgentMessage(message: log)
                    break
                case .attachmentMessage:
                    print("Received Attachment Message \(log.description)")
                    processAgentAttachmentMessage(message: log)
                    break
                case .memberLeave:
                    print("Received Member Leave Message")
                    processAgentLeave()
                default:
                    break
            }
            lastSyncTime = log.createdTimestamp as NSNumber
        }
        // Save the last sync time
        ALApplozicSettings.saveZendeskLastSyncTime(lastSyncTime)
    }
    
    func getMessageForTranscript(message:ALMessage) -> String {
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
        let infoString = "This chat is initiated from Kommunicate widget, look for more here: \(KommunicateURL.dashboardURL)\(groupId)"
        let infoMessage = ALMessage()
        infoMessage.message = infoString
        
        guard isHandOffHappened else {
            addMessageToBuffer(message: infoMessage)
            sendLogToKMServer(message: "iOS SDK: Failed to send chat info \(groupId) due to handoff")
            return
        }
        
        guard let connectionProvider = Chat.connectionProvider, connectionProvider.status == .connected else {
            sendLogToKMServer(message: "iOS SDK: Failed to send chat info \(groupId) due to socket connection.Retrying connection..")
            connectToZendeskSocket()
            return
        }
        
        sendMessageToZendesk(message: infoString, completionHandler: {(result) in
            switch result {
            case .success(let messageId):
              print("info message sent successfully \(messageId)")
            case .failure(let error):
              print("Failed to send info message due to \(error)")
                self.sendLogToKMServer(message: "iOS SDK:Failed to send chat info \(self.groupId) due to Zendesk api error \(error.localizedDescription)")
                self.addMessageToBuffer(message: infoMessage)
            }
        })
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
            
    func processBufferMessages() {
        for message in messageBufffer {
            sendMessage(message: message)
        }
    }
    
    // Send Agent Message comes from zendesk dashboard to Kommunicate server
    func processAgentMessage(message: ChatLog) {
        guard let chatMessage = message as? ChatMessage else { return }
        // Kommunicate server accepts "-" but Zendesk sends ":"
        let agentId = message.nick.replace(":", with: "-")
        
        var messageDict = createMessageProxy(displayName:message.displayName , agentId: agentId, conversationId: groupId, messageTimeStamp: message.createdTimestamp)
        messageDict["message"] = chatMessage.message
        let postdata: Data? = try? JSONSerialization.data(withJSONObject: messageDict, options: [])
        var theParamString: String? = nil
        if let aPostdata = postdata {
            theParamString = String(data: aPostdata, encoding: .utf8)
        }
        
        sendAgentMessageGroup.enter()
        
        guard let postURLRequest = ALRequestHandler.createPOSTRequest(withUrlString: KommunicateURL.sendMessage, paramString: theParamString) as NSMutableURLRequest? else { return }
        let responseHandler = ALResponseHandler()
        
        responseHandler.authenticateAndProcessRequest(postURLRequest, andTag: "") {
            (json, error) in
            self.sendAgentMessageGroup.leave()
            guard error == nil else {
                print("Failed to send agent message \(chatMessage.message)")
                return
            }
            print("Successfully sent agent message \(chatMessage.message)")
        }
        
    }
    
    // Send Agent's attachment Message comes from zendesk dashboard to Kommunicate server
    func processAgentAttachmentMessage(message: ChatLog) {
        guard let attachmentMessage = message as? ChatAttachmentMessage else { return }
        var messageProxy = createMessageProxy(displayName: message.displayName, agentId: message.nick.replace(":", with: "-"), conversationId: groupId, messageTimeStamp: message.createdTimestamp)
        let attachmentDict = createAttachmentDict(attachment: attachmentMessage.attachment)
        messageProxy["fileAttachment"] = attachmentDict
        messageProxy["auth"] = ALUserDefaultsHandler.getAuthToken()
        sendAgentMessageGroup.enter()
        let postdata: Data? = try? JSONSerialization.data(withJSONObject: messageProxy, options: [])
        var theParamString: String? = nil
        if let aPostdata = postdata {
            theParamString = String(data: aPostdata, encoding: .utf8)
        }
        
        guard let postURLRequest = ALRequestHandler.createPOSTRequest(withUrlString: KommunicateURL.sendAttachment, paramString: theParamString) as NSMutableURLRequest? else { return }
        let responseHandler = ALResponseHandler()
        
        responseHandler.authenticateAndProcessRequest(postURLRequest, andTag: "") {
            (json, error) in
            self.sendAgentMessageGroup.leave()
            guard error == nil else {
                return
            }
        }
    }
    
    // Resolve the conversation if agent leaves the conversation
    func processAgentLeave() {
        let url = "\(KommunicateURL.resolveConversation)\(groupId)&status=\(2)&sendNotifyMessage=true"
        let theRequest: NSMutableURLRequest? =
            ALRequestHandler.createPatchRequest(
                withUrlString: url,
                paramString: nil
            )
        ALResponseHandler().authenticateAndProcessRequest(theRequest, andTag: "KM-RESOLVE-CONVERSATION") {
            json, error in
            guard error == nil else {
                return
            }
            self.endChat()
        }
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
    
    func createMessageProxy(displayName: String,agentId: String,conversationId: String,messageTimeStamp: Double) -> [String:Any] {
        let agentInfo = ["displayName": displayName, "agentId": agentId]
        let messageDict = ["agentInfo": agentInfo,"messageDeduplicationKey": "\(agentId)-\(messageTimeStamp)","groupId":conversationId,"fromUserName":agentId] as [String : Any]
        return messageDict
    }
    
    func createAttachmentDict(attachment: ChatAttachment) -> [String:Any] {
        return ["name":attachment.name, "mime_type": attachment.mimeType, "size": attachment.size, "url": attachment.url]
    }
}
