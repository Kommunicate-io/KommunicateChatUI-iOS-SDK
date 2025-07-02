//
//  KMChatBaseViewController.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by Mukesh Thawani on 04/05/17.
//

import KommunicateCore_iOS_SDK
import UIKit

open class KMChatBaseViewController: UIViewController, KMChatConfigurable {
    public var configuration: KMChatConfiguration!

    public required init(configuration: KMChatConfiguration) {
        self.configuration = configuration
        super.init(nibName: nil, bundle: nil)
        addObserver()
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        NSLog("🐸 \(#function) 🍀🍀 \(self) 🐥🐥🐥🐥")
        addObserver()
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard !configuration.hideNavigationBarOnChat  else {
            navigationController?.setNavigationBarHidden(true, animated: true)
            return
        }
        
        // Add the back button in case if first view controller is nil or is not same as current VC OR
        // Add the back button in case if first view controller is  KMChatConversationViewController and current VC is KMChatConversationViewController
        if navigationController?.viewControllers.first != self {
            navigationItem.leftBarButtonItem = backBarButtonItem()
        } else if let vc = navigationController?.viewControllers.first,
                  vc.isKind(of: KMChatConversationViewController.self) {
            navigationItem.leftBarButtonItem = backBarButtonItem()
        }

        if configuration.hideNavigationBarBottomLine {
            navigationController?.navigationBar.hideBottomHairline()
        }
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        checkPricingPackage()
        checkForLanguageDirection()
    }

    func checkForLanguageDirection() {
        let language = NSLocale.preferredLanguages[0]
        let direction = NSLocale.characterDirection(forLanguage: language)

        if direction == NSLocale.LanguageDirection.rightToLeft {
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
        }
    }

    @objc func backTapped() {
        _ = navigationController?.popViewController(animated: true)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        NSLog("🐸 \(#function) 🍀🍀 \(self) 🐥🐥🐥🐥")
        addObserver()
    }

    open func addObserver() {}

    open func removeObserver() {}

    deinit {
        removeObserver()
        NSLog("💩 \(#function) ❌❌ \(self)‼️‼️‼️‼️")
    }

    func checkPricingPackage() {
        if ALApplicationInfo().isChatSuspended() {
            showAccountSuspensionView()
        }
    }

    open func showAccountSuspensionView() {}

    func backBarButtonItem() -> UIBarButtonItem {
        var backImage = UIImage(named: "icon_back", in: Bundle.km, compatibleWith: nil)
        backImage = backImage?.imageFlippedForRightToLeftLayoutDirection()
        let backButton = UIBarButtonItem(
            image: backImage,
            style: .plain,
            target: self,
            action: #selector(backTapped)
        )
        backButton.accessibilityIdentifier = "conversationBackButton"
        return backButton
    }
}
