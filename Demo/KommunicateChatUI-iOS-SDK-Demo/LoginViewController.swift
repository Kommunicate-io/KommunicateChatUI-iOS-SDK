//
//  AppLogicLoginViewController.swift
//
//  Created by Mukesh Thawani on 11/09/17.
//
//

import KommunicateCore_iOS_SDK
import UIKit

class LoginViewController: UIViewController {
    @IBOutlet var userName: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var emailId: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        ALUserDefaultsHandler.setUserAuthenticationTypeId(1)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func getStartedBtn(_: AnyObject) {
        let appId = ALChatManager.applicationId
        let alUser = ALUser()
        alUser.applicationId = appId

        if ALChatManager.isNilOrEmpty(userName.text as NSString?) {
            let alert = UIAlertController(title: "Kommunicate", message: "Please enter userId ", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        alUser.userId = userName.text
        ALUserDefaultsHandler.setUserId(alUser.userId)
        print("userName:: ", alUser.userId ?? "")
        if !((emailId.text?.isEmpty)!) {
            alUser.email = emailId.text
            ALUserDefaultsHandler.setEmailId(alUser.email)
        }
        if !((password.text?.isEmpty)!) {
            alUser.password = password.text
            ALUserDefaultsHandler.setPassword(alUser.password)
        }
        registerUserToKommunicate(alUser: alUser)
    }

    private func registerUserToKommunicate(alUser: ALUser) {
        let alChatManager = ALChatManager(applicationKey: ALChatManager.applicationId as NSString)
        alChatManager.connectUser(alUser, completion: { response, error in
            if error == nil {
                self.addContacts()
                NSLog("[REGISTRATION] Kommunicate user registration was successful: %@ \(String(describing: response?.isRegisteredSuccessfully()))")
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewController")
                self.present(vc!, animated: true, completion: nil)
            } else {
                NSLog("[REGISTRATION] Kommunicate user registration error: %@", error.debugDescription)
            }
        })
    }

    func addContacts() {
        let contact1 = ALContact()
        let contact2 = ALContact()
        let contact3 = ALContact()
        contact1.userId = "iOSDemoContact1"
        contact1.displayName = "iOS Demo Contact 1"
        contact2.userId = "iOSDemoContact2"
        contact2.displayName = "iOS Demo Contact 2"
        contact3.userId = "iOSDemoContact3"
        contact3.displayName = "iOS Demo Contact 3"
        let contactService = ALContactService()
        contactService.addList(ofContacts: [contact1, contact2, contact3])
    }
}
