//
//  ALKUIConfiguration.swift
//  ApplozicSwift
//
//  Created by Mukesh Thawani on 13/06/18.
//

import Foundation

public struct ALKConfiguration {

    /// If enabled then tapping on navigation bar in
    /// conversation view will open the group detail screen.
    /// - NOTE: Only works in case of groups.
    public var isTapOnNavigationBarEnabled = true

    /// If enabled then tapping on the user's profile
    /// icon in group chat will open a thread with that user.
    /// - NOTE: You will see the previous messages(if there are any).
    public var isProfileTapActionEnabled = true

    /// The background color of the ALKConversationViewController.
    public var backgroundColor = UIColor(netHex: 0xf9f9f9)

    /// Hides the bottom line in the navigation bar.
    /// It will be hidden in all the ViewControllers where
    /// navigation bar is visible. Default value is true.
    public var hideNavigationBarBottomLine = true

    /// Navigation bar's background color. It will be used in all the
    /// ViewControllers where navigation bar is visible.
    public var navigationBarBackgroundColor = UIColor.navigationOceanBlue()

    /// Navigation bar's tint color. It will be used in all the
    /// ViewControllers where navigation bar is visible.
    public var navigationBarItemColor = UIColor.navigationTextOceanBlue()

    /// Navigation bar's title color. It will be used in all the
    /// ViewControllers where navigation bar is visible.
    public var navigationBarTitleColor = UIColor.black

    /// ChatBar's bottom view color. This is the view which contains
    /// all the attachment and other options.
    public var chatBarAttachmentViewBackgroundColor = UIColor.background(.grayEF)

    /// If true then all the media options in Chat bar will be hidden.
    public var hideAllOptionsInChatBar = false

    /// If true then audio option in chat bar will be hidden.
    public var hideAudioOptionInChatBar = false

    /// If true then the start new chat button will be hidden.
    public var hideStartChatButton = false
    
    /// Pass the name of Localizable Strings file
    public var localizedStringFileName = "Localizable"

    /// Send message icon in chat bar.
    public var sendMessageIcon = UIImage(named: "send", in: Bundle.applozic, compatibleWith: nil)

    /// Image for navigation bar right side icon in conversation view.
    public var rightNavBarImageForConversationView: UIImage?

    /// System icon for right side navigation bar in conversation view.
    public var rightNavBarSystemIconForConversationView = UIBarButtonItem.SystemItem.refresh

    /// If true then right side navigation icon in conversation view will be hidden.
    public var hideRightNavBarButtonForConversationView = false

    /// If true then back  navigation icon in conversation list will be hidden.
    public var hideBackButtonInConversationList = false

    /// conversationlist view navigation icon for right side.
    /// By default, create group icon image will be used.
    public var rightNavBarImageForConversationListView = UIImage(named: "fill_214", in: Bundle.applozic, compatibleWith: nil)

    /// If true then click action on navigation icon in conversation list view will be handled from outside
    public var handleNavIconClickOnConversationListView = false

    /// Notification name for navigation icon click in conversation list
    public var nsNotificationNameForNavIconClick = "handleNavigationItemClick"

    /// If true then line between send button and text view will be hidden.
    public var hideLineImageFromChatBar = false

    /// If true then typing status will show user names.
    public var showNameWhenUserTypesInGroup = true

    /// If true then start new conversation button shown in the empty state will be disabled
    public var hideEmptyStateStartNewButtonInConversationList = false

    /// Date cell and  information cell  background color
    public var conversationViewCustomCellBackgroundColor = UIColor.gray

    /// Date cell and  information cell  text color
    public var conversationViewCustomCellTextColor = UIColor.white

    public init() { }
}
