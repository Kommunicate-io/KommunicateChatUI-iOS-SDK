//
//  ALKConversationListViewModel.swift
//  
//
//  Created by Mukesh Thawani on 04/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import Foundation
import Applozic

protocol ALKConversationListViewModelDelegate: class {

    func startedLoading()
    func listUpdated()
    func rowUpdatedAt(position: Int)
}


final public class ALKConversationListViewModel: NSObject, Localizable {

    weak var delegate: ALKConversationListViewModelDelegate?

    var localizationFileName = String()
    var alChannelService = ALChannelService()
    var alContactService = ALContactService()
    var conversationService = ALConversationService()

    fileprivate var allMessages = [Any]()

    func prepareController(dbService: ALMessageDBService) {
        self.delegate?.startedLoading()
        dbService.getMessages(nil)
    }

    func getChatList() -> [Any] {
        return allMessages
    }

    func numberOfSection() -> Int {
        return 1
    }

    func numberOfRowsInSection(section: Int) -> Int {
        return allMessages.count
    }

    func chatForRow(indexPath: IndexPath) -> ALKChatViewModelProtocol? {
        guard indexPath.row < allMessages.count else {
            return nil
        }

        guard let alMessage = allMessages[indexPath.row] as? ALMessage else {
            return nil
        }
        return alMessage
    }

    func remove(message: ALMessage) {
        let messageToDelete = allMessages.filter { ($0 as? ALMessage) == message }
        guard let messageDel = messageToDelete.first as? ALMessage,
            let index = (allMessages as? [ALMessage])?.index(of: messageDel) else {
                return
        }
        allMessages.remove(at: index)
    }

    func updateTypingStatus(in viewController: ALKConversationViewController, userId: String, status: Bool) {
        let contactDbService = ALContactDBService()
        let contact = contactDbService.loadContact(byKey: "userId", value: userId)
        guard let alContact = contact else { return }
        guard !alContact.block || !alContact.blockBy else { return }

        viewController.showTypingLabel(status: status, userId: userId)
    }

    func updateMessageList(messages: [Any]) {
        allMessages = messages
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01, execute: {
            self.delegate?.listUpdated()
        })
    }

    func updateDeliveryReport(convVC: ALKConversationViewController?, messageKey: String?, contactId: String?, status: Int32?) {
        guard let vc = convVC  else { return }
        vc.updateDeliveryReport(messageKey: messageKey, contactId: contactId, status: status)
    }

    func updateStatusReport(convVC: ALKConversationViewController?, forContact contact: String?, status: Int32?) {
        guard let vc = convVC  else { return }
        vc.updateStatusReport(contactId: contact, status: status)
    }

    func addMessages(messages: Any) {
        guard let alMessages = messages as? [ALMessage], var allMessages = allMessages as? [ALMessage] else {
            return
        }

        for currentMessage in alMessages {
            var messagePresent = [ALMessage]()
            if let _ = currentMessage.groupId {
                messagePresent = allMessages.filter { ($0.groupId != nil) ? $0.groupId == currentMessage.groupId:false }
            } else {
                messagePresent = allMessages.filter {
                    $0.groupId == nil ? (($0.contactId != nil) ? $0.contactId == currentMessage.contactId:false) : false
                }
            }

            if let firstElement = messagePresent.first, let index = allMessages.index(of: firstElement)  {
                allMessages[index] = currentMessage
                self.allMessages[index] = currentMessage
            } else {
                self.allMessages.append(currentMessage)
            }
        }
        if self.allMessages.count > 1 {

            self.allMessages = allMessages.sorted { ($0.createdAtTime != nil && $1.createdAtTime != nil) ? Int(truncating: $0.createdAtTime) > Int(truncating: $1.createdAtTime):false }
        }
        delegate?.listUpdated()
        
    }

    func updateStatusFor(userDetail: ALUserDetail) {
        guard let alMessages = allMessages as? [ALMessage], let userId = userDetail.userId else { return }
        let messages = alMessages.filter { ($0.contactId != nil) ? $0.contactId == userId :false }
        guard let firstMessage = messages.first, let index = alMessages.index(of: firstMessage) else { return }
        delegate?.rowUpdatedAt(position: index)
    }

    func syncCall(viewController: ALKConversationViewController?, message: ALMessage, isChatOpen: Bool) {
        if isChatOpen {
            viewController?.sync(message: message)
        }
    }

    func fetchMoreMessages(dbService: ALMessageDBService) {
        guard !ALUserDefaultsHandler.getFlagForAllConversationFetched() else { return }
        delegate?.startedLoading()
        dbService.fetchConversationfromServer(completion: {
            _ in
            NSLog("List updated")
        })
    }
    
    func sendUnmuteRequestFor(conversation: ALMessage, withCompletion: @escaping (Bool) -> ()) {

        let time = (Int(Date().timeIntervalSince1970) * 1000)
        sendMuteRequestFor(conversation: conversation, tillTime: time as NSNumber) { (success) in
            withCompletion(success)
        }
    }
    
    func sendMuteRequestFor(conversation: ALMessage, tillTime: NSNumber, withCompletion: @escaping (Bool)->()) {
        if conversation.isGroupChat, let channel = ALChannelService().getChannelByKey(conversation.groupId) {
            // Unmute channel
            let muteRequest = ALMuteRequest()
            muteRequest.id = channel.key
            muteRequest.notificationAfterTime = tillTime as NSNumber
            ALChannelService().muteChannel(muteRequest) { (response, error) in
                if error != nil {
                    withCompletion(false)
                }
                withCompletion(true)
            }
        } else if let contact = ALContactService().loadContact(byKey: "userId", value: conversation.contactId){
            // Unmute Contact
            let muteRequest = ALMuteRequest()
            muteRequest.userId = contact.userId
            muteRequest.notificationAfterTime = tillTime as NSNumber
            ALUserService().muteUser(muteRequest) { (response, error) in
                if error != nil {
                    withCompletion(false)
                }
                withCompletion(true)
            }
        }else {
            withCompletion(false)
        }
    }

    func titleFor(contactId: String?, channelId: NSNumber?) -> String {
        var title = ""
        if let key = channelId,
            let alChannel = alChannelService.getChannelByKey(key),
            let name = alChannel.name {
            title = name
        } else if let key = contactId,
            let alContact = alContactService.loadContact(byKey: "userId", value: key),
            let name = alContact.getDisplayName() {
            title = name
        }

        let noName = localizedString(
            forKey: "NoNameMessage",
            withDefaultValue: SystemMessage.NoData.NoName,
            fileName: localizationFileName)
        title = title.isEmpty ? noName : title
        return title
    }

    func conversationViewModelOf(
        type conversationViewModelType: ALKConversationViewModel.Type,
        contactId: String?,
        channelId: NSNumber?,
        conversationId: NSNumber?) -> ALKConversationViewModel {

        var convProxy: ALConversationProxy?
        if let convId = conversationId, let conversationProxy = conversationService.getConversationByKey(convId) {
            convProxy = conversationProxy
        }

        let convViewModel = conversationViewModelType.init(
            contactId: contactId,
            channelKey: channelId,
            conversationProxy: convProxy,
            localizedStringFileName : localizationFileName)
        return convViewModel
    }
}
