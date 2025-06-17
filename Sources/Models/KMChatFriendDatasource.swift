//
//  KMChatFriendDatasource.swift
//
//
//  Created by Mukesh Thawani on 04/05/17.
//

import Foundation

enum KMChatDatasourceState {
    case full, filtered

    init(isInUsed: Bool) {
        if isInUsed {
            self = .filtered
        } else {
            self = .full
        }
    }
}

protocol KMChatFriendDatasourceProtocol: AnyObject {
    func getDatasource(state: KMChatDatasourceState) -> [KMChatFriendViewModel]
    func count(state: KMChatDatasourceState) -> Int
    func getItem(atIndex: Int, state: KMChatDatasourceState) -> KMChatFriendViewModel?
    func updateItem(item: KMChatFriendViewModel, atIndex: Int, state: KMChatDatasourceState)
    func update(datasource: [KMChatFriendViewModel], state: KMChatDatasourceState)
}

final class KMChatFriendDatasource: KMChatFriendDatasourceProtocol {
    private var filteredList = [KMChatFriendViewModel]()
    private var friendList = [KMChatFriendViewModel]()

    func getDatasource(state: KMChatDatasourceState) -> [KMChatFriendViewModel] {
        switch state {
        case .full:
            return friendList
        case .filtered:
            return filteredList
        }
    }

    func count(state: KMChatDatasourceState) -> Int {
        switch state {
        case .full:
            return friendList.count
        case .filtered:
            return filteredList.count
        }
    }

    func getItem(atIndex: Int, state: KMChatDatasourceState) -> KMChatFriendViewModel? {
        let count = self.count(state: state)
        if count > atIndex {
            switch state {
            case .full:
                return friendList[atIndex]
            case .filtered:
                return filteredList[atIndex]
            }
        }
        return nil
    }

    func updateItem(item: KMChatFriendViewModel, atIndex: Int, state: KMChatDatasourceState) {
        let count = self.count(state: state)
        if count > atIndex {
            switch state {
            case .full:
                friendList[atIndex] = item
            case .filtered:
                filteredList[atIndex] = item
            }
        }
    }

    func update(datasource: [KMChatFriendViewModel], state: KMChatDatasourceState) {
        switch state {
        case .full:
            friendList = datasource
        case .filtered:
            filteredList = datasource
        }
    }
}
