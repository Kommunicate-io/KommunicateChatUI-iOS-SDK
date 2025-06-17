//
//  SearchResultViewModel.swift
//  Kommunicate Chat
//
//  Created by Shivam Pokhriyal on 17/06/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import KommunicateCore_iOS_SDK

class BaseMessageViewModel: KMChatConversationListViewModelProtocol {
    var allMessages = [KMCoreMessage]()

    func numberOfSections() -> Int {
        return 1
    }

    func numberOfRowsInSection(_: Int) -> Int {
        return allMessages.count
    }

    func chatFor(indexPath: IndexPath) -> KMChatChatViewModelProtocol? {
        guard indexPath.row < allMessages.count else { return nil }
        return allMessages[indexPath.row]
    }

    func getChatList() -> [Any] {
        return allMessages
    }

    func remove(message: KMCoreMessage) {
        let messageToDelete = allMessages.filter { $0 == message }
        guard let messageDel = messageToDelete.first,
              let index = allMessages.firstIndex(of: messageDel)
        else {
            return
        }
        allMessages.remove(at: index)
    }

    func sendMuteRequestFor(message _: KMCoreMessage, tillTime _: NSNumber, withCompletion _: @escaping (Bool) -> Void) {
        print("Not supported")
    }

    func sendUnmuteRequestFor(message _: KMCoreMessage, withCompletion _: @escaping (Bool) -> Void) {
        print("Not supported")
    }

    func block(conversation _: KMCoreMessage, withCompletion _: @escaping (Error?, Bool) -> Void) {
        print("Not supported")
    }

    func unblock(conversation _: KMCoreMessage, withCompletion _: @escaping (Error?, Bool) -> Void) {
        print("Not supported")
    }

    func conversationViewModelFrom(
        contactId: String?,
        channelId: NSNumber?,
        conversationId: NSNumber?,
        localizationFileName: String
    ) -> KMChatConversationViewModel {
        let conversationProxy = conversationProxyFrom(conversationId: conversationId)

        let convViewModel = KMChatConversationViewModel(
            contactId: contactId,
            channelKey: channelId,
            conversationProxy: conversationProxy,
            localizedStringFileName: localizationFileName
        )
        return convViewModel
    }

    private func conversationProxyFrom(conversationId: NSNumber?) -> KMCoreConversationProxy? {
        guard let convId = conversationId,
              let conversationProxy = KMCoreConversationService().getConversationByKey(convId)
        else {
            return nil
        }
        return conversationProxy
    }
}

// MARK: - SearchResultViewModel

class SearchResultViewModel: BaseMessageViewModel {
    func clear() {
        allMessages.removeAll()
    }

    func searchMessage(with key: String,
                       _ completion: @escaping ((_ result: Bool) -> Void)) {
        searchMessages(with: key) { messages, error in
            guard let messages = messages, error == nil else {
                print("Error \(String(describing: error)) while searching messages")
                completion(false)
                return
            }

            // Sort
            _ = messages
                .sorted(by: {
                    Int(truncating: $0.createdAtTime) > Int(truncating: $1.createdAtTime)
                }).filter {
                    $0.groupId != nil || $0.contactId != nil
                }.map {
                    self.allMessages.append($0)
                }
            completion(true)
        }
    }

    public func searchMessages(
        with key: String,
        _ completion: @escaping (_ message: [KMCoreMessage]?, _ error: Any?) -> Void
    ) {
        let service = KMCoreMessageClientService()
        let request = ALSearchRequest()
        request.searchText = key
        service.searchMessage(with: request) { messages, error in
            guard
                let messages = messages as? [KMCoreMessage]
            else {
                completion(nil, error)
                return
            }
            completion(messages, error)
        }
    }
}
