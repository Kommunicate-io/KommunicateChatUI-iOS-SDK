//
//  ALBaseNavigationController.swift
//  ApplozicSwift
//
//  Created by Mukesh Thawani on 04/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import Foundation
public class ALKBaseNavigationViewController: UINavigationController {

    static var statusBarStyle: UIStatusBarStyle = .lightContent

    override public func viewDidLoad() {
        super.viewDidLoad()

        setNeedsStatusBarAppearanceUpdate()
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override public var preferredStatusBarStyle: UIStatusBarStyle {
        return ALKBaseNavigationViewController.statusBarStyle
    }

}
