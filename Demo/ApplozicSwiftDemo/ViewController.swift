//
//  ViewController.swift
//  ApplozicSwiftDemo
//
//  Created by Mukesh Thawani on 11/08/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import UIKit
import Applozic
import ApplozicSwift

class ViewController: UIViewController {

    override func viewDidAppear(_ animated: Bool) {
        //        registerAndLaunch()

    }

    override func viewDidLoad() {

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func logoutAction(_ sender: UIButton) {
        let registerUserClientService: ALRegisterUserClientService = ALRegisterUserClientService()
        registerUserClientService.logout { (response, error) in

        }
        self.dismiss(animated: false, completion: nil)
    }

    @IBAction func launchChatList(_ sender: Any) {
        let conversationVC = ALKConversationListViewController(configuration: AppDelegate.config)
        let nav = ALKBaseNavigationViewController(rootViewController: conversationVC)
        self.present(nav, animated: false, completion: nil)
    }
}
