//
//  ALChatManager.swift
//
//  Created by Mukesh Thawani on 04/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import Foundation
import KommunicateChatUI_iOS_SDK
import KommunicateCoreiOSSDK
import UIKit

@objc class ALChatManager: NSObject {
    /// Set your appId here in place of applozic-sample-app
    static let applicationId = "applozic-sample-app"
    @objc static let shared = ALChatManager(applicationKey: ALChatManager.applicationId as NSString)

    @objc var pushNotificationTokenData: Data? {
        didSet {
            updateToken()
        }
    }

    @objc init(applicationKey: NSString) {
        super.init()
        if applicationKey.length == 0 {
            fatalError("Please pass your applicationId in the ALChatManager file.")
        }
        ALUserDefaultsHandler.setApplicationKey(applicationKey as String)
        defaultChatViewSettings()
    }

    class func isNilOrEmpty(_ string: NSString?) -> Bool {
        switch string {
        case let .some(nonNilString):
            return nonNilString.length == 0
        default:
            return true
        }
    }

    @objc func updateToken() {
        guard let deviceToken = pushNotificationTokenData else { return }
        print("DEVICE_TOKEN_DATA :: \(deviceToken.description)") // (SWIFT = 3) : TOKEN PARSING

        var deviceTokenString = ""
        for i in 0 ..< deviceToken.count {
            deviceTokenString += String(format: "%02.2hhx", deviceToken[i] as CVarArg)
        }
        print("DEVICE_TOKEN_STRING :: \(deviceTokenString)")

        if ALUserDefaultsHandler.getApnDeviceToken() != deviceTokenString {
            let alRegisterUserClientService = ALRegisterUserClientService()
            alRegisterUserClientService.updateApnDeviceToken(withCompletion: deviceTokenString, withCompletion: { response, _ in
                print("REGISTRATION_RESPONSE :: \(String(describing: response))")
            })
        }
    }

    /// This method used for Authentication OR User Registration to applozic server
    /// It create a new user in applozic if user doesn't exist OR it will login to the existing user.
    /// - Parameters:
    ///   - alUser: Pass ALUser object.
    ///   - completion: Completion Handler will have ALRegistrationResponse in case of successful login else it will have Error in case of any error in login or registration.
    @objc func connectUser(_ alUser: ALUser, completion: @escaping (_ response: ALRegistrationResponse?, _ error: NSError?) -> Void) {
        ALUserDefaultsHandler.setApplicationKey(getApplicationKey() as String)
        let registerUserClientService = ALRegisterUserClientService()
        registerUserClientService.initWithCompletion(alUser, withCompletion: { response, error in
            guard error == nil else {
                completion(nil, error as NSError?)
                return
            }
            guard let response = response else {
                let apiError = NSError(domain: "Applozic", code: 0, userInfo: [NSLocalizedDescriptionKey: "Api error while registering to applozic"])
                completion(nil, apiError as NSError?)
                return
            }
            guard response.isRegisteredSuccessfully() else {
                let message = response.message ?? "Api error while registering to applozic"
                let errorResponse = NSError(domain: "Applozic", code: 0, userInfo: [NSLocalizedDescriptionKey: message])
                completion(nil, errorResponse)
                return
            }
            print("Registration successfull")
            completion(response, nil)
        })
    }

    func getApplicationKey() -> NSString {
        let appKey = ALUserDefaultsHandler.getApplicationKey() as NSString?
        let applicationKey = (appKey != nil) ? appKey : ALChatManager.applicationId as NSString?
        return applicationKey!
    }

    func isUserPresent() -> Bool {
        guard let _ = ALUserDefaultsHandler.getApplicationKey() as String?,
              let _ = ALUserDefaultsHandler.getUserId() as String?
        else {
            return false
        }
        return true
    }

    @objc func logoutUser(completion: @escaping (Bool) -> Void) {
        let registerUserClientService = ALRegisterUserClientService()
        if let _ = ALUserDefaultsHandler.getDeviceKeyString() {
            registerUserClientService.logout(completionHandler: {
                _, _ in
                print("Applozic logout")
                let appSettingsUserDefaults = ALKAppSettingsUserDefaults()
                appSettingsUserDefaults.clear()
                completion(true)
            })
        }
    }

    /// Add the default chat settings here
    func defaultChatViewSettings() {
        ALUserDefaultsHandler.setGoogleMapAPIKey("AIzaSyCOacEeJi-ZWLLrOtYyj3PKMTOFEG7HDlw") // REPLACE WITH YOUR GOOGLE MAPKEY
        ALApplozicSettings.setListOfViewControllers([ALKConversationListViewController.description(), ALKConversationViewController.description()])
        ALApplozicSettings.setFilterContactsStatus(false)
        ALUserDefaultsHandler.setDebugLogsRequire(true)
        ALApplozicSettings.setSwiftFramework(true)
    }

    /// Use this method for launching conversation list screen.
    /// - Parameter viewController: Pass the UIViewController.
    @objc func launchChatList(from viewController: UIViewController) {
        let conversationVC = ALKConversationListViewController(configuration: ALChatManager.defaultConfiguration)
        let navVC = ALKBaseNavigationViewController(rootViewController: conversationVC)
        navVC.modalPresentationStyle = .fullScreen
        viewController.present(navVC, animated: true, completion: nil)
    }

    /// Use this method for launching 1-to-1 chat conversation.
    /// - Parameters:
    ///   - contactId: Pass userId of whom for conversation needs to be launched.
    ///   - viewController: Pass the UIViewController.
    ///   - prefilledMessage: Pass the prefilled Message in case if this needs to prefilled in chat box else it will be nil.
    @objc func launchChatWith(contactId: String, from viewController: UIViewController, prefilledMessage: String? = nil) {
        let alContactDbService = ALContactDBService()
        var title = ""
        if let alContact = alContactDbService.loadContact(byKey: "userId", value: contactId), let name = alContact.getDisplayName() {
            title = name
        }
        title = title.isEmpty ? "No name" : title
        let convViewModel = ALKConversationViewModel(contactId: contactId, channelKey: nil, localizedStringFileName: ALChatManager.defaultConfiguration.localizedStringFileName, prefilledMessage: prefilledMessage)
        let conversationViewController = ALKConversationViewController(configuration: ALChatManager.defaultConfiguration, individualLaunch: true)
        conversationViewController.viewModel = convViewModel
        launch(viewController: conversationViewController, from: viewController)
    }

    /// Use this method to launch the group chat conversation.
    /// - Parameters:
    ///   - clientGroupId: Pass the clientGroupId for launching Group/Channel conversation.
    ///   - viewController: Pass the UIViewController.
    ///   - prefilledMessage: Pass the prefilled Message in case if this needs to prefilled in chat box else it will be nil.
    @objc func launchGroupWith(clientGroupId: String, from viewController: UIViewController, prefilledMessage: String? = nil) {
        let alChannelService = ALChannelService()
        alChannelService.getChannelInformation(nil, orClientChannelKey: clientGroupId) { channel in
            guard let channel = channel, let key = channel.key else { return }
            let convViewModel = ALKConversationViewModel(contactId: nil, channelKey: key, localizedStringFileName: ALChatManager.defaultConfiguration.localizedStringFileName, prefilledMessage: prefilledMessage)
            let conversationViewController = ALKConversationViewController(configuration: ALChatManager.defaultConfiguration, individualLaunch: true)
            conversationViewController.viewModel = convViewModel
            self.launch(viewController: conversationViewController, from: viewController)
        }
    }

    /// Use [launchGroupOfTwo](x-source-tag://GroupOfTwo) method instead.
    @objc func launchChatWith(conversationProxy: ALConversationProxy, from viewController: UIViewController) {
        let userId = conversationProxy.userId
        let groupId = conversationProxy.groupId
        let convViewModel = ALKConversationViewModel(contactId: userId, channelKey: groupId, conversationProxy: conversationProxy, localizedStringFileName: ALChatManager.defaultConfiguration.localizedStringFileName)
        let conversationViewController = ALKConversationViewController(configuration: ALChatManager.defaultConfiguration, individualLaunch: true)
        conversationViewController.viewModel = convViewModel
        launch(viewController: conversationViewController, from: viewController)
    }

    /// Use [launchGroupOfTwo](x-source-tag://GroupOfTwo) method instead.
    func createAndLaunchChatWith(conversationProxy: ALConversationProxy, from viewController: UIViewController, configuration _: ALKConfiguration) {
        let conversationService = ALConversationService()
        conversationService.createConversation(conversationProxy) { error, response in
            guard let proxy = response, error == nil else {
                print("Error creating conversation :: \(String(describing: error))")
                return
            }
            let alConversationProxy = self.conversationProxyFrom(original: conversationProxy, generated: proxy)
            self.launchChatWith(conversationProxy: alConversationProxy, from: viewController)
        }
    }

    /// Use this to launch context based Group of two.
    ///
    /// - Parameters:
    ///   - userId: UserId of the user with whom you want to start conversation.
    ///   - metadata: Dictionary that contains details about contextual chat.
    ///   - topic: A unique topic to identify conversation.
    ///   - viewController: ViewController from where chat will be pushed
    /// - Tag: GroupOfTwo
    /// - Usage:
    ///
    /// let metadata = NSMutableDictionary()
    /// metadata["title"] = "<ITEM_TITLE>"
    /// metadata["price"] = "<ITEM_PRICE>"
    /// metadata["link"] = "<IMAGE_URL>"
    /// metadata["AL_CONTEXT_BASED_CHAT"] = "true"
    /// launchGroupOfTwo(with: "<RECEIVER_USER_ID>", metadata: metadata, topic: "<UNIQUE_TOPIC_ID>", from: self)
    @objc func launchGroupOfTwo(
        with userId: String,
        metadata: NSMutableDictionary,
        topic: String,
        from viewController: UIViewController
    ) {
        let clientGroupId = String(format: "%@_%@_%@", topic, ALUserDefaultsHandler.getUserId(), userId)
        let channelService = ALChannelService()
        channelService.getChannelInformation(nil, orClientChannelKey: clientGroupId) {
            channel in
            guard let channel = channel else {
                let channelInfo = ALChannelInfo()
                channelInfo.clientGroupId = clientGroupId
                channelInfo.groupName = userId
                channelInfo.groupMemberList = [userId]
                channelInfo.type = Int16(GROUP_OF_TWO.rawValue)
                channelInfo.metadata = metadata

                channelService.createChannel(with: channelInfo) { response, error in
                    guard error == nil, let channel = response?.alChannel else {
                        print("Error while creating channel : \(String(describing: error))")
                        return
                    }
                    ALChannelDBService().addMember(toChannel: userId, andChannelKey: channel.key)
                    self.launchGroupWith(clientGroupId: clientGroupId, from: viewController)
                }
                return
            }
            if channel.metadata == metadata {
                self.launchGroupWith(clientGroupId: clientGroupId, from: viewController)
            } else {
                channelService.updateChannelMetaData(channel.key, orClientChannelKey: nil, metadata: metadata, withCompletion: { error in
                    print("Failed to update channel metadata: \(String(describing: error))")
                    self.launchGroupWith(clientGroupId: clientGroupId, from: viewController)
                })
            }
        }
    }

    func launchContactList(from viewController: UIViewController) {
        let newChatVC = ALKNewChatViewController(configuration: ALChatManager.defaultConfiguration, viewModel: ALKNewChatViewModel(localizedStringFileName: ALChatManager.defaultConfiguration.localizedStringFileName))
        let navVC = UINavigationController(rootViewController: newChatVC)
        viewController.present(navVC, animated: true, completion: nil)
    }

    func setApplicationBaseUrl() {
        guard let dict = Bundle.main.infoDictionary?["APPLOZIC_PRODUCTION"] as? [AnyHashable: Any] else {
            return
        }
        /// Change URLs if they are present in the info dictionary.
        if let baseUrl = dict["AL_KBASE_URL"] as? String {
            ALUserDefaultsHandler.setBASEURL(baseUrl)
        }

        if let mqttUrl = dict["AL_MQTT_URL"] as? String {
            ALUserDefaultsHandler.setMQTTURL(mqttUrl)
        }

        if let fileUrl = dict["AL_FILE_URL"] as? String {
            ALUserDefaultsHandler.setFILEURL(fileUrl)
        }

        if let mqttPort = dict["AL_MQTT_PORT"] as? String {
            ALUserDefaultsHandler.setMQTTPort(mqttPort)
        }
    }

    /// A convenient method to get logged-in user's information.
    ///
    /// If user information is stored in DB or preference, Code to get user's information should go here.
    /// This can also be used to get existing user information in case of app update.
    /// - Returns: Logged-in user information
    func getLoggedInUserInfo() -> ALUser {
        let user = ALUser()
        user.applicationId = getApplicationKey() as String
        user.appModuleName = ALUserDefaultsHandler.getAppModuleName()
        user.userId = ALUserDefaultsHandler.getUserId()
        user.email = ALUserDefaultsHandler.getEmailId()
        user.password = ALUserDefaultsHandler.getPassword()
        user.displayName = ALUserDefaultsHandler.getDisplayName()
        return user
    }

    private func conversationProxyFrom(original: ALConversationProxy, generated: ALConversationProxy) -> ALConversationProxy {
        let finalProxy = ALConversationProxy()
        finalProxy.userId = generated.userId
        finalProxy.topicDetailJson = generated.topicDetailJson
        finalProxy.id = original.id
        finalProxy.groupId = original.groupId
        return finalProxy
    }

    private func chatTitleUsing(userId: String?, groupId: NSNumber?) -> String {
        if let contactId = userId,
           let contact = ALContactDBService().loadContact(byKey: "userId", value: contactId),
           let name = contact.getDisplayName()
        {
            return name
        }
        if let channelKey = groupId,
           let channel = ALChannelService().getChannelByKey(channelKey)
        {
            return channel.name
        }
        return "No name"
    }

    /// This method is used for updating APN's device token to applozic server.
    /// - Parameters:
    ///   - application: Pass the UIApplication object.
    ///   - deviceToken: Pass the device token data.
    @objc func application(_: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("Device token data :: \(String(describing: deviceToken.description))")
        var deviceTokenString = ""
        for i in 0 ..< deviceToken.count {
            deviceTokenString += String(format: "%02.2hhx", deviceToken[i] as CVarArg)
        }
        print("Device token :: \(String(describing: deviceToken.description))")
        if ALUserDefaultsHandler.getApnDeviceToken() != deviceTokenString {
            let alRegisterUserClientService = ALRegisterUserClientService()
            alRegisterUserClientService.updateApnDeviceToken(withCompletion: deviceTokenString, withCompletion: { response, error in
                if error != nil {
                    print("Error in Registration: " + error!.localizedDescription)
                    return
                }
                print("Registration Response :: \(String(describing: response))")
            })
        }
    }

    /// Use this method in AppDelegate didFinishLaunchingWithOptions for register totification and data connection handlers.
    /// - Parameters:
    ///   - application: Pass UIApplication object.
    ///   - launchOptions: Pass the Launch Options Key.
    /// - Returns: True for the didFinishLaunchingWithOptions setup.
    @objc func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) {
        // Register for push notification.
        registerForNotification()

        /// Use this for Customizing notification.
        /// - NOTE:
        ///       Before using, comment ALKPushNotification line and remove
        ///       ALApplozicSetting.setListOfViewController from ALChatManager.
        ///       If you want to try this in our sample, then comment lines in ViewController's launchChatList method.
        ///       Finally, Uncomment below line
        /// PushNotificationHandler.shared.handleNotification(with: AppDelegate.config)
        ALKPushNotificationHandler.shared.dataConnectionNotificationHandlerWith(ALChatManager.defaultConfiguration)
        let alApplocalNotificationHnadler = ALAppLocalNotifications.appLocalNotificationHandler()
        alApplocalNotificationHnadler?.dataConnectionNotificationHandler()
    }

    /// Use this method in AppDelegate applicationWillEnterForeground to reset the unread badge count in App.
    /// - Parameter application: Pass the UIApplication object.
    @objc func applicationWillEnterForeground(_: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    /// Use this method in AppDelegate applicationWillTerminate to save the context of the database.
    /// - Parameter application: Pass the UIApplication object.
    @objc func applicationWillTerminate(application _: UIApplication) {
        ALDBHandler.sharedInstance().saveContext()
    }

    /// Use this method for proccessing the notificiation of background.
    /// - Parameters:
    ///   - application: Pass UIApplication object.
    ///   - userInfo: Pass the userInfo dictionary of notification.
    ///   - completionHandler: Use the completionHandler UIBackgroundFetchResult and pass it to didReceiveRemoteNotification completion.
    @objc func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("Received notification With Completion :: \(userInfo.description)")
        let service = ALPushNotificationService()
        guard !service.isApplozicNotification(userInfo) else {
            service.notificationArrived(to: application, with: userInfo)
            completionHandler(UIBackgroundFetchResult.newData)
            return
        }
        completionHandler(UIBackgroundFetchResult.newData)
    }

    /// Use this method for proccessing local notification data of UNUserNotificationCenter.
    /// - Parameters:
    ///   - center: Pass UNUserNotificationCenter object.
    ///   - notification: Pass the UNNotificationResponse object.
    ///   - completionHandler: Completion Handler call back will have UNNotificationPresentationOptions if notification is proccessed it will be empty else it will have other options.
    @objc func userNotificationCenter(_: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let service = ALPushNotificationService()
        guard !service.isApplozicNotification(notification.request.content.userInfo) else {
            service.notificationArrived(to: UIApplication.shared, with: notification.request.content.userInfo)
            completionHandler([])
            return
        }
        completionHandler([.sound, .badge, .alert])
    }

    /// Use this method for proccessing User Notification Center response in didReceive method of UNUserNotificationCenter.
    /// - Parameters:
    ///   - center: Pass UNUserNotificationCenter object.
    ///   - response: Pass the UNNotificationResponse object.
    ///   - completionHandler: Completion Handler call back will be called after proccessing notification.
    @objc func userNotificationCenter(_: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let service = ALPushNotificationService()
        let dict = response.notification.request.content.userInfo
        guard !service.isApplozicNotification(dict) else {
            switch UIApplication.shared.applicationState {
            case .active:
                service.processPushNotification(dict, updateUI: NSNumber(value: APP_STATE_ACTIVE.rawValue))
            case .background:
                service.processPushNotification(dict, updateUI: NSNumber(value: APP_STATE_BACKGROUND.rawValue))
            case .inactive:
                service.processPushNotification(dict, updateUI: NSNumber(value: APP_STATE_INACTIVE.rawValue))
            @unknown default:
                print("unknown state in push notification")
            }
            completionHandler()
            return
        }
        completionHandler()
    }

    /// Use this method for register notification.
    @objc func registerForNotification() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .alert, .sound]) { granted, _ in

            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }

    /// Setup your configuration here
    static let defaultConfiguration: ALKConfiguration = {
        var config = ALKConfiguration()
        // Change config based on requirement like:
        // config.isTapOnNavigationBarEnabled = false
        return config
    }()

    private func launch(viewController: UIViewController, from vc: UIViewController) {
        let navVC = ALKBaseNavigationViewController(rootViewController: viewController)
        navVC.modalPresentationStyle = .fullScreen
        vc.present(navVC, animated: true, completion: nil)
    }
}
