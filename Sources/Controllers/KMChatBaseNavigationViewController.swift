//
//  KMChatBaseNavigationViewController.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by Mukesh Thawani on 04/05/17.
//

import Foundation
import UIKit

public class KMChatBaseNavigationViewController: UINavigationController {
    static var statusBarStyle: UIStatusBarStyle = .lightContent
    let appSettingsUserDefaults = KMChatAppSettingsUserDefaults()

    override public func viewDidLoad() {
        super.viewDidLoad()

        setNeedsStatusBarAppearanceUpdate()
        setupAppearance()
    }

    override public var preferredStatusBarStyle: UIStatusBarStyle {
        return KMChatBaseNavigationViewController.statusBarStyle
    }

    private func setupAppearance() {
        let navigationBarProxy = UINavigationBar.appearance(whenContainedInInstancesOf: [KMChatBaseNavigationViewController.self])
        navigationBarProxy.shadowImage = navigationBarProxy.shadowImage ?? UIImage()
        navigationBarProxy.tintColor = navigationBarProxy.tintColor ?? UIColor.navigationTextOceanBlue()
        navigationBarProxy.titleTextAttributes =
        navigationBarProxy.titleTextAttributes ?? [NSAttributedString.Key.foregroundColor: UIColor.kmDynamicColor(light: .black, dark: .white)]

        if navigationBarProxy.backgroundImage(for: .default) == nil {
            navigationBarProxy.barTintColor = appSettingsUserDefaults.getAppBarTintColor()
        }
        if #available(iOS 13.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.titleTextAttributes =
            navigationBarProxy.titleTextAttributes ?? [NSAttributedString.Key.foregroundColor: UIColor.kmDynamicColor(light: .black, dark: .white)]
            if navigationBarProxy.backgroundImage(for: .default) == nil {
                navBarAppearance.backgroundColor = UIColor.kmDynamicColor(light: appSettingsUserDefaults.getAppBarTintColor(), dark: UIColor.appBarDarkColor())
            } else {
                navBarAppearance.backgroundImage = navigationBarProxy.backgroundImage(for: .default)
            }
            navigationBarProxy.standardAppearance = navBarAppearance
            navigationBarProxy.scrollEdgeAppearance = navigationBarProxy.standardAppearance
        }
    }
}
