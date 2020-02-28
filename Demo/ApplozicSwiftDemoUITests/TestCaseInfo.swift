//
//  Constante.swift
//  ApplozicSwiftDemoUITests
//
//  Created by Kommunicate on 26/12/19.
//  Copyright © 2019 Applozic. All rights reserved.
//

import Foundation

enum AppPermission {
    enum AlertMessage {
        static let accessNotificationInApplication = "“ApplozicSwiftDemo” Would Like to Send You Notifications"
        static let accessPhoto = "“ApplozicSwiftDemo” Would Like to Access Your Photos"
        static let accessContact = "“ApplozicSwiftDemo” Would Like to Access Your Contacts"
        static let accessLocation = "“ApplozicSwiftDemo” to access your location while you are using the app?"
    }

    enum AlertButton {
        static let allow = "Allow"
        static let ok = "OK"
        static let allowLoation = "Allow While Using App"
    }
}

enum InAppButton {
    enum LaunchScreen {
        static let getStarted = "Get Started"
        static let launchChat = "Launch Chat"
    }

    enum CreatingGroup {
        static let newChat = "fill 214"
        static let createGroup = "Create Group"
        static let addParticipant = "Add participants"
        static let invite = "InviteButton"
        static let leave = "Leave"
        static let remove = "Remove"
        static let save = "Save"
        static let removeUser = "Remove user"
    }

    enum ConversationScreen {
        static let send = "sendButton"
        static let back = "conversationBackButton"
        static let openPhotos = "galleryButtonInConversationScreen"
        static let selectPhoto = "Photos"
        static let openContact = "contactButtonInConversationScreen"
        static let selectcontact = "ContactsListView"
        static let openLocation = "locationButtonInConversationScreen"
        static let sendLocation = "Send Location"
        static let done = "Done"
        static let swippableDelete = "SwippableDeleteIcon"
    }
}

enum AppScreen {
    static let myChatScreen = "My Chats"
    static let chatBar = "chatBar"
    static let selectParticipantView = "SelectParticipantTableView"
    static let conversationList = "OuterChatScreenTableView"
}

enum AppTextFeild {
    static let userId = "User id"
    static let password = "Password"
    static let typeGroupName = "Type group name"
    static let chatTextView = "chatTextView"
}
