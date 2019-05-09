//
//  CreateGroupViewModel.swift
//  
//
//  Created by Mukesh Thawani on 04/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import Foundation
import Applozic

protocol ALKCreateGroupViewModelDelegate {
    func membersFetched()
    func remove(at index: Int)
    func makeAdmin(at index: Int)
    func dismissAdmin(at index: Int)
    func sendMessage(at index: Int)
}

class ALKCreateGroupViewModel {
    
    var groupName: String = ""
    var originalGroupName: String = ""
    var groupId: NSNumber
    let adminText: String = "Admin"

    var membersId = [String]()
    var membersInfo = [GroupMemberInfo]()

    let delegate: ALKCreateGroupViewModelDelegate

    lazy var isCurrentUserAdmin: Bool = {
        let user = ALChannelDBService().loadChannelUserX(
            byUserId: self.groupId,
            andUserId: ALUserDefaultsHandler.getUserId())
        return user?.isAdminUser() ?? false
    }()

    lazy var isAddAllowed: Bool = {
        let channel = ALChannelDBService().loadChannel(byKey: groupId)!
        return channel.type == PUBLIC.rawValue || isCurrentUserAdmin
    }()

    init(groupName name: String, groupId: NSNumber, delegate: ALKCreateGroupViewModelDelegate) {
        groupName = name
        originalGroupName = name
        self.groupId = groupId
        self.delegate = delegate
        membersInfo.append(GroupMemberInfo(name: "Add Participants"))
    }

    func isAddParticipantButtonEnabled() -> Bool {
        let name = groupName.trimmingCharacters(in: .whitespacesAndNewlines)
        return !name.isEmpty
    }

    func fetchParticipants() {
        ALChannelDBService().fetchChannelMembersAsync(withChannelKey: groupId) { (members) in
            guard let members = members as? [String] else {
                return
            }
            self.membersId = members
            let alContactDbService = ALContactDBService()
            let alContacts = self.membersId.map {
                alContactDbService.loadContact(byKey: "userId", value: $0)
            }
            let channelDbService = ALChannelDBService()
            self.membersInfo =
                alContacts
                    .filter { $0 != nil && $0?.userId != ALUserDefaultsHandler.getUserId() }
                    .map {
                        let user = $0!
                        let isAdmin = channelDbService.loadChannelUserX(byUserId: self.groupId, andUserId: user.userId!)?.isAdminUser() ?? false
                        return GroupMemberInfo(
                            id: user.userId!,
                            name: user.getDisplayName()!,
                            image: user.contactImageUrl,
                            isAdmin: isAdmin,
                            addCell: false,
                            adminText: self.adminText)
                    }
            self.membersInfo.append(self.getCurrentUserInfo())
            if self.isAddAllowed {
                self.membersInfo.insert(GroupMemberInfo(name: "Add Participants"), at: 0)
            }
            self.delegate.membersFetched()
        }
    }

    /// Listen to notification.... for real time updates
    func updateGroupMembers(_ notification: NSNotification) {
        guard
            let channel = notification.object as? ALChannel,
            channel.key == groupId
        else {
            return
        }
        fetchParticipants()
    }

    func numberOfRows() -> Int {
        return membersInfo.count
    }

    func rowAt(index: Int) -> GroupMemberInfo {
        return membersInfo[index]
    }

    func optionsForCell(at index: Int) -> (Bool, [options]?) {
        guard index != membersInfo.count - 1 else {
            return (false, nil)
        }
        if isAddAllowed && index == 0 {
            return (true, nil)
        }
        if isCurrentUserAdmin {
            var options: [options] = [.remove, .sendMessage]
            membersInfo[index].isAdmin ? options.append(.dismissAdmin) : options.append(.makeAdmin)
            options.append(.cancel)
            return (false, options)
        } else {
            return (false, [.sendMessage, .cancel])
        }
    }

    enum options: String, Localizable {
        case remove
        case makeAdmin
        case dismissAdmin
        case sendMessage
        case cancel

        func value(localizationFileName: String, index: Int) -> UIAlertAction {
            switch self {
                case .remove:
                    let title = localizedString(forKey: "Remove", withDefaultValue: "Remove", fileName: localizationFileName)
                    return UIAlertAction(title: title, style: .destructive, handler: { (action) in
                        print("Will remove \(action)")
                    })
                case .makeAdmin:
                    let title = localizedString(forKey: "MakeAdmin", withDefaultValue: "Make Admin", fileName: localizationFileName)
                    return UIAlertAction(title: title, style: .default, handler: { (action) in
                        print("Will make admin \(action)")
                    })
                case .dismissAdmin:
                    let title = localizedString(forKey: "DismissAdmin", withDefaultValue: "Dismiss Admin", fileName: localizationFileName)
                    return UIAlertAction(title: title, style: .destructive, handler: { (action) in
                        print("\(action) dismiss admin")
                    })
                case .sendMessage:
                    let title = localizedString(forKey: "SendMessage", withDefaultValue: "Send message", fileName: localizationFileName)
                    return UIAlertAction(title: title, style: .default, handler: { (action) in
                        print("\(action) sending message")
                    })
                case .cancel:
                    let title = localizedString(forKey: "Cancel", withDefaultValue: "Cancel", fileName: localizationFileName)
                    return UIAlertAction(title: title, style: .cancel, handler: { (action) in
                        print("Cancel")
                    })
            }
        }
    }

    private func getCurrentUserInfo() -> GroupMemberInfo {
        let currentUser = ALContactDBService().loadContact(byKey: "userId", value: ALUserDefaultsHandler.getUserId())!
        return GroupMemberInfo(
            id: currentUser.userId,
            name: "You",
            image: currentUser.contactImageUrl,
            isAdmin: isCurrentUserAdmin,
            addCell: false,
            adminText: self.adminText)
    }

}
