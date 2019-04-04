//
//  PushNotificationHandler.swift
//  ApplozicSwiftDemo
//
//  Created by Shivam Pokhriyal on 19/03/19.
//  Copyright © 2019 Applozic. All rights reserved.
//

import Foundation
import Applozic
import ApplozicSwift

class PushNotificationHandler {
    public static let shared = PushNotificationHandler()
    var navVC: UINavigationController?

    var contactId: String?
    var groupId: NSNumber?
    var conversationId: NSNumber?
    var configuration: ALKConfiguration!

    private var alContact: ALContact? {
        let alContactDbService = ALContactDBService()
        guard let alContact = alContactDbService.loadContact(byKey: "userId", value: self.contactId) else {
            return nil
        }
        return alContact
    }

    private var alChannel: ALChannel? {
        let alChannelService = ALChannelService()
        guard let alChannel = alChannelService.getChannelByKey(self.groupId) else {
            return nil
        }
        return alChannel
    }

    public func handleNotification(with configuration: ALKConfiguration) {
        self.configuration = configuration

        // No need to add removeObserver() as it is present in pushAssist.
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "showNotificationAndLaunchChat"), object: nil, queue: nil, using: {[weak self] notification in
            print("launch chat push notification received")
            self?.contactId = nil
            self?.groupId = nil
            self?.conversationId = nil
            //Todo: Handle group

            guard let weakSelf = self, let object = notification.object as? String else { return }
            let components = object.components(separatedBy: ":")

            if components.count > 2 {
                guard let componentElement = Int(components[1]) else { return }
                weakSelf.groupId = NSNumber(integerLiteral: componentElement)
            } else if components.count == 2 {
                guard let conversationComponent = Int(components[1]) else { return }
                weakSelf.conversationId = NSNumber(integerLiteral: conversationComponent)
                weakSelf.contactId = components[0]
            } else {
                weakSelf.contactId = object
            }

            /// If app is active then show notification and handle click.
            /// If app is inactive, then iOS notification will be shown, you only need to handle click.
            if UIApplication.shared.applicationState == .active {
                guard let userInfo = notification.userInfo, let alertValue = userInfo["alertValue"] as? String else {
                    return
                }
                if weakSelf.isNotificationForActiveThread() { return }
                ALUtilityClass.thirdDisplayNotificationTS(alertValue, andForContactId: weakSelf.contactId, withGroupId: weakSelf.groupId, completionHandler: {
                    _ in
                    weakSelf.launchIndividualChatWith(userId: weakSelf.contactId, groupId: weakSelf.groupId)
                })
            } else {
                weakSelf.launchIndividualChatWith(userId: weakSelf.contactId, groupId: weakSelf.groupId)
            }

        })
    }

    func isNotificationForActiveThread() -> Bool {
        let notification = NotificationHelper.NotificationData(userId: self.contactId, groupId: self.groupId, conversationId: self.conversationId)
        return NotificationHelper().isNotificationForActiveThread(notification)
    }

    func launchIndividualChatWith(userId: String?, groupId: NSNumber?) {
        print("Called when user taps on notification.")
       /* Handle following cases ::
         /* 1. Detailed chat screen is at top.
                and chat was happening for the user for whom notification came.
                So, add chat message to chat list.
         */
         /* 2. Detailed chat screen is at top.
                and chat was happening with different user/group.
                Here, refresh chat screen to show chat with the user for whom notification came.
         */
         /* 3. Chat list screen is at top.
                open detailed chat with the user/group.
         */
         /* 4. Any other screen is at top.
                push chat list screen and then push detailed chat.
                Or you can directly push chat list while setting contactId/groupId
                and it will open detailed chat automatically.
         */
       */
        let notification = NotificationHelper.NotificationData(userId: self.contactId, groupId: self.groupId, conversationId: self.conversationId)
        let pushAssistant = ALPushAssist()
        guard let topVC = pushAssistant.topViewController else { return }
        
        if NotificationHelper().isApplozicVCAtTop() {
            NotificationHelper().handleNotificationTap(notification)
        } else {
            print("Applozic Controller not on top. Launch chat using helper methods.")
            /// Below code needs to be changed depending on how you are using SDK.
            /// Currently it shows demonstration on how it can be used with container.
            switch topVC {
                case let vc as ConversationContainerViewController:
                    NotificationHelper().openConversationFromListVC(vc.conversationVC, notification: notification)
                case let vc as ContainerViewController:
                    let listVC = NotificationHelper().getConversationVCToLaunch(notification: notification, configuration: AppDelegate.config)
                    vc.openConversationFromNotification(listVC)
                case let vc as MenuViewController:
                    vc.dismiss(animated: true) {
                        guard let top = pushAssistant.topViewController as? ContainerViewController else {
                            return
                        }
                        let listVC = NotificationHelper().getConversationVCToLaunch(notification: notification, configuration: AppDelegate.config)
                        top.openConversationFromNotification(listVC)
                    }
                default:
                    print("Some other controller Handle yourself")
            }
        }
    }

}
