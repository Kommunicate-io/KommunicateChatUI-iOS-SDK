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
}

public class KMZendeskChatHandler {
    
   public static let shared = KMZendeskChatHandler()
    var groupId: String = ""
    var connectionStatus = false
    var messages:[ALMessage]? = nil
    var zenChatIntialized = false
    var userId = ""
    var isChatTranscriptSent = false
    
    public func initiateZendesk(key: String, conversationId: String) {
        Chat.initialize(accountKey: key)
        groupId = conversationId
        zenChatIntialized = true
        fetchUserId()
        authenticateUser()

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.sendChatInfo()
            self.sendChatTranscript()
            
            let connectionToken = Chat.connectionProvider?.observeConnectionStatus { [self] (connection) in
                // Handle connection status changes
                guard connection.isConnected && connectionStatus != true else {
                   self.connectToZendeskSocket()
                   return
                }
                connectionStatus = true
                observeChatLogs()
                if !isChatTranscriptSent {
                    sendChatTranscript()
                }
               
           }
           
       }
    }
    
    func fetchUserId() {
        guard let id = ALUserDefaultsHandler.getUserId() else {return}
        self.userId = id
    }
    
    public func getGroupId() -> String {
        return groupId
    }
    func authenticateUser() {
        let chatAPIConfiguration = ChatAPIConfiguration()
        chatAPIConfiguration.visitorInfo = VisitorInfo(name: ALUserDefaultsHandler.getDisplayName() ?? "", email: ALUserDefaultsHandler.getEmailId() ?? "", phoneNumber: "")
        Chat.instance?.configuration = chatAPIConfiguration
        connectToZendeskSocket()
    }
    var chatLogToken : ObservationToken?
    
    func observeChatLogs() {
        guard Chat.connectionProvider?.status == .connected else {
            connectToZendeskSocket()
            return
        }
        
        let stateToken = Chat.chatProvider?.observeChatState { (state) in
            // Handle logs, agent events, queue position changes and other events
        }
        chatLogToken = stateToken
    }
    
    func connectToZendeskSocket() {
        Chat.connectionProvider?.connect()
    }
    
    func sendMessage(message: ALMessage) {
        guard Chat.connectionProvider?.status == .connected else {
            connectToZendeskSocket()
            return
        }
        
        sendMessageToZendesk(message: message.message) { (result) in
            switch result {
            case .success:
                print("Message Sent to Zendesk Successfully")
            case .failure(let error):
                print("Failed Send the Message to Zendesk \(error)")
            }
        }
    }
    
    func sendMessageToZendesk(message: String, completionHandler: @escaping (Result<String, ChatProvidersSDK.DeliveryStatusError>) -> Void) {
        Chat.chatProvider?.sendMessage(message) { (result) in
            completionHandler(result)
        }
    }
    
    func sendChatTranscript() {
        let chanelKey = NSNumber(value: Int(groupId) ?? 0)
        let messageListRequest = MessageListRequest()
        messageListRequest.channelKey = chanelKey
        
        if let channel = ALChannelService().getChannelByKey(chanelKey) {
            messageListRequest.channelType = channel.type
        }
        
        
        ALMessageClientService().getMessageList(forUser: messageListRequest, withOpenGroup: messageListRequest.channelType == 6) {[self] messages,error,userArray in
            guard let messageList = messages,
                  let userDetails = userArray as? [ALUserDetail],
                  !userDetails.isEmpty,
                  let almessages = messageList.reversed() as? [ALMessage] else {
                return
            }
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
                return userdetail.displayName
            }
        }
        return ""
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
        Chat.chatProvider?.endChat()
        chatLogToken?.cancel()
        Chat.connectionProvider?.disconnect()
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
        //This API proactively connects to web sockets for authenticated users. This connection is kept alive. You should call disconnect() on the ConnectionProvider if you don't need to keep it open.
        guard let chatProvider = Chat.chatProvider else{return completion(false)}
        chatProvider.getChatInfo { (result) in
            switch result {
            case .success(let chatInfo):
                completion(chatInfo.isChatting)
            case .failure(let error):
                print("Failed to get chat info \(error)")
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
}

