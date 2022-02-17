//
//  ViewController.swift
//  ApplozicSwiftDemo
//
//  Created by Mukesh Thawani on 11/08/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import KommunicateChatUI_iOS_SDK
import ApplozicCore
import UIKit

class ViewController: UIViewController {
    override func viewDidAppear(_: Bool) {
        //        registerAndLaunch()
    }

    override func viewDidLoad() {}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func logoutAction(_: UIButton) {
        ALChatManager.shared.logoutUser { _ in
            self.dismiss(animated: true, completion: nil)
        }
    }

    @IBAction func launchChatList(_: Any) {
        ALChatManager.shared.launchChatList(from: self)
    }
}
