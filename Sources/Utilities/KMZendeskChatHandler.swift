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


public class KMZendeskChatHandler {
    
   public static let shared = KMZendeskChatHandler()
    var groupId: String = ""
    var connectionStatus = false
    var messages:[ALMessage]? = nil
    var zenChatIntialized = false
    var userId = ""
    var userDetailsList = [ALUserDetail]()
    
    public func initiateZendesk(key: String, conversationId: String) {
        Chat.initialize(accountKey: key)
        groupId = conversationId
        zenChatIntialized = true
        print("Pakka101 intialized zendesk chat")
        fetchUserId()
        authenticateUser()

        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {

            let connectionToken = Chat.connectionProvider?.observeConnectionStatus { [self] (connection) in
                // Handle connection status changes
                print("pakka101 connect status \(connection.isConnected)")

                guard connection.isConnected && connectionStatus != true else {
                   self.connectToZendeskSocket()
                   return
                }
                connectionStatus = true
                observeChatLogs()
                self.sendChatInfo()
                self.sendChatTranscript()
           }
           
       }
    }
    
    func setMessages(messages : [ALMessage]) {
        self.messages = messages
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
        
        print("Pakka101 trying to observe chat logs")
        let stateToken = Chat.chatProvider?.observeChatState { (state) in
            // Handle logs, agent events, queue position changes and other events
            print("Pakka101 conversation state logs \(state.logs)")
        }
        chatLogToken = stateToken
    }
    
    func connectToZendeskSocket() {
        print("Pakka101 trying to connect zendesk socket")
        Chat.connectionProvider?.connect()
    }
    var messageBuffer = [ALMessage]()
    
    func sendMessage(message: ALMessage) {
        
        guard Chat.connectionProvider?.status == .connected else {
            messageBuffer.append(message)
            connectToZendeskSocket()
            return
        }
        print("Pakka101 trying to send message to zenchat")
        sendMessageToZendesk(message: message)
    }
    
    func sendMessageToZendesk(message: ALMessage) {
        Chat.chatProvider?.sendMessage(message.message) { (result) in
                switch result {
                case .success(let messageId):
                  print("Pakka101 message sent successfully \(messageId)")
                  // The message was successfully sent
                case .failure(let error):
                  // Something went wrong
                  // You can easily retrieve the messageId to use when retrying
                  let messageId = error.messageId
                  print("Pakka101 message send error \(error)")
                }
          }
    }
    
    func sendChatTranscript() {
        print("Pakka101 send chat transcript called")
        let chanelKey = NSNumber(value: Int(groupId) ?? 0)
        let messageListRequest = MessageListRequest()
        messageListRequest.userId = nil
        messageListRequest.channelKey = chanelKey
        messageListRequest.conversationId = nil
        messageListRequest.endTimeStamp = nil
        
        if let channel = ALChannelService().getChannelByKey(chanelKey) {
            messageListRequest.channelType = channel.type
        }
        var transcriptString = "Transcript:\n"
        ALMessageClientService().getMessageList(forUser: messageListRequest, withOpenGroup: messageListRequest.channelType == 6) {[self] messages,error,userArray in
            print("Pakka101 messages \(messages)")
            guard let messageList = messages,
                  let userDetails = userArray as? [ALUserDetail],
                  !userDetails.isEmpty,
                  let almessages = messageList.reversed() as? [ALMessage] else {
                return
            }
            for currentMessage in almessages {
                guard !currentMessage.isMsgHidden() || currentMessage.isAssignmentMessage() else {continue}
                var userName = ""
                if currentMessage.to == self.userId {
                    userName = "User"
                } else {
                    //get the bot name
                    userName = getBotNameById(botId: currentMessage.to, userdetails: userDetails)
                }
                var message = getMessageForTranscript(message: currentMessage)
                guard !userName.isEmpty && !message.isEmpty else{continue}
                transcriptString.append("\(userName): \(message)\n")
            }
            
            Chat.chatProvider?.sendMessage(transcriptString) { (result) in
                    switch result {
                    case .success(let messageId):
                      print("Pakka101 Transcript message sent successfully \(messageId)")
                      // The message was successfully sent
                    case .failure(let error):
                      // Something went wrong
                      // You can easily retrieve the messageId to use when retrying
                      let messageId = error.messageId
                      print("Pakka101 Transcript message send error \(error)")
                    }
              }
            
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
            return ""
        } else if let metadata = message.metadata, let templateId = metadata["templateId"] {
            return "TemplateId: \(templateId)"
        }
        
        return ""
    }
    
    func sendChatInfo() {
        let infoString = "This chat is initiated from kommunicate widget, look for more here: https://dashboard.kommunicate.io/conversations/\(groupId)"
        Chat.chatProvider?.sendMessage(infoString) { (result) in
                switch result {
                case .success(let messageId):
                  print("Pakka101 infomessage sent successfully \(messageId)")
                  // The message was successfully sent
                case .failure(let error):
                  // Something went wrong
                  // You can easily retrieve the messageId to use when retrying
                  let messageId = error.messageId
                  print("Pakka101 infomessage send error \(error)")
                }
          }
    }
    
    public func disconnectFromZendesk() {
        Chat.chatProvider?.endChat()
        chatLogToken?.cancel()
        Chat.connectionProvider?.disconnect()
        print("Pakka101 disconnected from Zendesk Chat")
    }
    
    func sendAttachment(message:ALMessage){
        ALMessageClientService().downloadImageUrlV2(message.fileMetaInfo?.blobKey, isS3URL: message.fileMetaInfo?.url != nil) { fileUrl, error in
            guard error == nil, let fileUrl = fileUrl, let url = URL(string: fileUrl) else {
                print("Error Finding attachment URL :: \(String(describing: error))")
                return
            }
            
            print("pakka101 file URL \(fileUrl)")
            Chat.chatProvider?.sendFile(url:url , onProgress: { (progress) in
                        // Do something with the progress
                        print("Pakka101 attchment progress \(progress)")
            
                    }, completion: { result in
                        switch result {
                        case .success:
                            // The attachment was sent
                            print("Pakka101 attchment send")
                            break
                        case .failure(let error):
                            // Something went wrong
                            print("Pakka101 failed to send attachment\(error)")
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
                print("Pakka101 isChatGoingOn \(chatInfo.isChatting)")
                completion(chatInfo.isChatting)
            case .failure(let error):
                print("Pakka101 Failed to get chatinfo error \(error)")
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
