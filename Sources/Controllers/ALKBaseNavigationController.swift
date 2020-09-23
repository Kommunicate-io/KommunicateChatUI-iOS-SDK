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
    let appSettingsUserDefaults = ALKAppSettingsUserDefaults()

    override public func viewDidLoad() {
        super.viewDidLoad()

        setNeedsStatusBarAppearanceUpdate()
        setupAppearance()
    }

    override public var preferredStatusBarStyle: UIStatusBarStyle {
        return ALKBaseNavigationViewController.statusBarStyle
    }

    private func setupAppearance() {
        let navigationBarProxy = UINavigationBar.appearance(whenContainedInInstancesOf: [ALKBaseNavigationViewController.self])
        navigationBarProxy.shadowImage = navigationBarProxy.shadowImage ?? UIImage()
        navigationBarProxy.tintColor = navigationBarProxy.tintColor ?? UIColor.navigationTextOceanBlue()
        navigationBarProxy.titleTextAttributes =
            navigationBarProxy.titleTextAttributes ?? [NSAttributedString.Key.foregroundColor: UIColor.black]

        if navigationBarProxy.backgroundImage(for: .default) == nil {
            navigationBarProxy.barTintColor = appSettingsUserDefaults.getAppBarTintColor()
        }
    }
}
