
//
//  UIViewController+Extension.swift
//  ApplozicSwift
//
//  Created by Mukesh Thawani on 04/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController
{
    @objc func hideKeyboard()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
    
    func alert(msg: String) {
    }
    
    class func topViewController() -> UIViewController? {
        return self.topViewControllerWithRootViewController(rootViewController: UIApplication.shared.keyWindow?.rootViewController)
    }
    
    class func topViewControllerWithRootViewController(rootViewController: UIViewController?) -> UIViewController? {
        
        if rootViewController is UITabBarController {
            let control = rootViewController as! UITabBarController
            return self.topViewControllerWithRootViewController(rootViewController: control.selectedViewController)
        } else if rootViewController is UINavigationController {
            let control = rootViewController as! UINavigationController
            return self.topViewControllerWithRootViewController(rootViewController: control.visibleViewController)
        } else if let control = rootViewController?.presentedViewController {
            return self.topViewControllerWithRootViewController(rootViewController: control)
        }
        
        return rootViewController
        
    }
    
    func add(_ child: UIViewController) {
        addChildViewController(child)
        view.addSubview(child.view)
        child.didMove(toParentViewController: self)
    }
    
    func remove() {
        guard parent != nil else { return }
        willMove(toParentViewController: nil)
        view.removeFromSuperview()
        removeFromParentViewController()
    }
}

