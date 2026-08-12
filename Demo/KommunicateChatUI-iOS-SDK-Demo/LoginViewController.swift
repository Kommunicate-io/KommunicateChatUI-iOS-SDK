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
        KMCoreUserDefaultsHandler.setUserAuthenticationTypeId(1)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func getStartedBtn(_: AnyObject) {
        let appId = ALChatManager.applicationId
        let alUser = KMCoreUser()
        alUser.applicationId = appId

        if ALChatManager.isNilOrEmpty(userName.text as NSString?) {
            let alert = UIAlertController(title: "Kommunicate", message: "Please enter userId ", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        alUser.userId = userName.text
        KMCoreUserDefaultsHandler.setUserId(alUser.userId)
        print("userName:: ", alUser.userId ?? "")
        if let email = emailId.text, !email.isEmpty {
            alUser.email = email
            KMCoreUserDefaultsHandler.setEmailId(email)
        }
        if let password = password.text, !password.isEmpty {
            alUser.password = password
            KMCoreUserDefaultsHandler.setPassword(password)
        }
        registerUserToKommunicate(alUser: alUser)
    }

    private func registerUserToKommunicate(alUser: KMCoreUser) {
        let alChatManager = ALChatManager(applicationKey: ALChatManager.applicationId as NSString)
        alChatManager.connectUser(alUser, completion: { response, error in
            DispatchQueue.main.async {
                if error == nil {
                    self.addContacts()
                    NSLog(
                        "[REGISTRATION] Kommunicate user registration was successful: %@",
                        String(describing: response?.isRegisteredSuccessfully())
                    )
                    guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") else {
                        self.showLoginError(
                            NSLocalizedString("chat_demo_open_error", bundle: .main, comment: "")
                        )
                        return
                    }
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                } else {
                    let message = error?.localizedDescription
                        ?? NSLocalizedString("user_registration_error", bundle: .main, comment: "")
                    NSLog("[REGISTRATION] Kommunicate user registration error: %@", error.debugDescription)
                    self.showLoginError(message)
                }
            }
        })
    }

    private func showLoginError(_ message: String) {
        let alert = UIAlertController(title: "Kommunicate", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
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
