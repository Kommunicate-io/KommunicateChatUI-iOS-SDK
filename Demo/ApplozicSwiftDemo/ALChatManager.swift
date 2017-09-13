//
//  ALChatManager.swift
//  sampleapp-completeswift
//
//  Created by Mukesh Thawani on 04/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import Foundation
import UIKit
import Applozic
import ApplozicSwift

var TYPE_CLIENT : Int16 = 0
var TYPE_APPLOZIC : Int16 = 1
var TYPE_FACEBOOK : Int16 = 2

var APNS_TYPE_DEVELOPMENT : Int16 = 0
var APNS_TYPE_DISTRIBUTION : Int16 = 1

class ALChatManager: NSObject {

    static let applicationId = "applozic-sample-app"

    static let shared = ALChatManager(applicationKey: ALChatManager.applicationId as NSString)

    init(applicationKey: NSString) {
        super.init()
        ALUserDefaultsHandler.setApplicationKey(applicationKey as String)

        self.defaultChatViewSettings()

    }

    var pushNotificationTokenData: Data? {
        didSet {
            updateToken()
        }
    }

    func updateToken() {
        guard let deviceToken = pushNotificationTokenData else { return }
        print("DEVICE_TOKEN_DATA :: \(deviceToken.description)")  // (SWIFT = 3) : TOKEN PARSING

        var deviceTokenString: String = ""
        for i in 0..<deviceToken.count
        {
            deviceTokenString += String(format: "%02.2hhx", deviceToken[i] as CVarArg)
        }
        print("DEVICE_TOKEN_STRING :: \(deviceTokenString)")

        if (ALUserDefaultsHandler.getApnDeviceToken() != deviceTokenString)
        {
            let alRegisterUserClientService: ALRegisterUserClientService = ALRegisterUserClientService()
            alRegisterUserClientService.updateApnDeviceToken(withCompletion: deviceTokenString, withCompletion: { (response, error) in
                print ("REGISTRATION_RESPONSE :: \(response)")
            })
        }
    }


    // ----------------------
    // Call This at time of your app's user authentication OR User registration.
    // This will register your User at applozic server.
    //----------------------

    func registerUser(_ alUser: ALUser, completion : @escaping (_ response: ALRegistrationResponse?, _ error: NSError?) -> Void) {

        let alChatLauncher: ALChatLauncher = ALChatLauncher(applicationId: getApplicationKey() as String)

        let registerUserClientService: ALRegisterUserClientService = ALRegisterUserClientService()

        registerUserClientService.initWithCompletion(alUser, withCompletion: { (response, error) in

            if (error != nil)
            {
                print("Error while registering to applozic");
                let errorPass = NSError(domain:"Error while registering to applozic", code:0, userInfo:nil)
                completion(response , errorPass as NSError?)
            }
            else if(!(response?.isRegisteredSuccessfully())!)
            {
                ALUtilityClass.showAlertMessage("Invalid Password", andTitle: "Oops!!!")
                let errorPass = NSError(domain:"Invalid Password", code:0, userInfo:nil)
                completion(response , errorPass as NSError?)
            }
            else
            {
                print("registered")
                if(ALChatManager.isNilOrEmpty(ALUserDefaultsHandler.getApnDeviceToken() as NSString?))
                {
                    alChatLauncher.registerForNotification()
                }
                completion(response , error as NSError?)
            }
        })
    }

    class func isNilOrEmpty(_ string: NSString?) -> Bool {

        switch string {
        case .some(let nonNilString): return nonNilString.length == 0
        default:return true

        }
    }

    func getApplicationKey() -> NSString {

        let appKey = ALUserDefaultsHandler.getApplicationKey() as NSString?
        let applicationKey = appKey
        return applicationKey!;
    }

    func isUserPresent() -> Bool {
        guard let _ = ALUserDefaultsHandler.getApplicationKey() as String?,
            let _ = ALUserDefaultsHandler.getUserId() as String? else {
                return false
        }
        return true
    }

    func logoutUser() {
        let registerUserClientService = ALRegisterUserClientService()
        if let _ = ALUserDefaultsHandler.getDeviceKeyString() {
            registerUserClientService.logout(completionHandler: {
                _, _ in
                NSLog("Applozic logout")
            })
        }
    }

    func defaultChatViewSettings() {
        ALApplozicSettings.setListOfViewControllers([ALKConversationListViewController.description(), ALKConversationViewController.description()])
    }

}
