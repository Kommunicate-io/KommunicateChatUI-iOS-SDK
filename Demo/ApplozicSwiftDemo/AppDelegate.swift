//
//  AppDelegate.swift
//  ApplozicSwiftDemo
//
//  Created by Mukesh Thawani on 11/08/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import ApplozicCore
import ApplozicSwift
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let navigationBarProxy = UINavigationBar.appearance(whenContainedInInstancesOf: [ALKBaseNavigationViewController.self])
        navigationBarProxy.barTintColor
            = UIColor(red: 0.93, green: 0.94, blue: 0.95, alpha: 1.0) // light nav blue
        navigationBarProxy.isTranslucent = false

        if ALUserDefaultsHandler.isLoggedIn() {
            // Get login screen from storyboard and present it
            let viewController: UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as UIViewController
            window?.makeKeyAndVisible()
            viewController.modalPresentationStyle = .fullScreen
            window?.rootViewController!.present(viewController, animated: true, completion: nil)
        }

        UNUserNotificationCenter.current().delegate = self
        ALChatManager.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        return true
    }

    func applicationWillResignActive(_: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_: UIApplication) {
        print("APP_ENTER_IN_BACKGROUND")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        print("APP_ENTER_IN_FOREGROUND")
        ALChatManager.shared.applicationWillEnterForeground(application)
    }

    func applicationDidBecomeActive(_: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        ALChatManager.shared.applicationWillTerminate(application: application)
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Register device token to applozic server.
        ALChatManager.shared.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }

    func application(_: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Couldn’t register: \(error)")
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        ALChatManager.shared.application(application, didReceiveRemoteNotification: userInfo) { result in
            // Process your own notification here.
            completionHandler(result)
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Pass the notification to applozic method for processing.
        ALChatManager.shared.userNotificationCenter(center, willPresent: notification) { options in
            // Process your own notification here.
            completionHandler(options)
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Pass the response to applozic method for processing notification.
        ALChatManager.shared.userNotificationCenter(center, didReceive: response) {
            // Process your own notification here.
            completionHandler()
        }
    }
}
