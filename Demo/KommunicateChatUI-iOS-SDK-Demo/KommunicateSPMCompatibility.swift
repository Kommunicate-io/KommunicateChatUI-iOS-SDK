//
//  KommunicateSPMCompatibility.swift
//  KommunicateChatUI-iOS-SDK-Demo
//

import KommunicateChatUI_iOS_SDK
import KommunicateCore_iOS_SDK

// Compatibility aliases for the older demo code after migrating the SDKs from CocoaPods to SPM.
typealias ALUser = KMCoreUser
typealias ALUserDefaultsHandler = KMCoreUserDefaultsHandler
typealias ALApplozicSettings = KMCoreSettings
typealias ALChannelService = KMCoreChannelService
typealias ALChannelInfo = KMCoreChannelInfo
typealias ALChannelDBService = KMCoreChannelDBService
typealias ALConversationProxy = KMCoreConversationProxy
typealias ALConversationService = KMCoreConversationService
typealias ALDBHandler = KMCoreDBHandler

typealias ALKAppSettingsUserDefaults = KMChatAppSettingsUserDefaults
typealias ALKBaseNavigationViewController = KMChatBaseNavigationViewController
typealias ALKConfiguration = KMChatConfiguration
typealias ALKConversationListViewController = KMChatConversationListViewController
typealias ALKConversationViewController = KMChatConversationViewController
typealias ALKConversationViewModel = KMChatConversationViewModel
typealias ALKNewChatViewController = KMChatNewChatViewController
typealias ALKNewChatViewModel = KMChatNewChatViewModel
typealias ALKPushNotificationHandler = KMChatPushNotificationHandler
