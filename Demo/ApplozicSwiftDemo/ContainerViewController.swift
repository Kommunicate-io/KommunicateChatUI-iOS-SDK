//
//  ContainerViewController.swift
//  ApplozicSwiftDemo
//
//  Created by Shivam Pokhriyal on 03/04/19.
//  Copyright © 2019 Applozic. All rights reserved.
//

/// This is a sample to illustrate usage of custom in-app notifications.

import ApplozicSwift
import UIKit

enum Menu: String {
    case simple
    case conversation
    case profile
}

class ContainerViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.backgroundColor = UIColor.lightGray
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.pause, target: self, action: #selector(navigationItemTapped))
        view.backgroundColor = .blue
    }

    @objc func navigationItemTapped() {
        let menuController = MenuViewController()
        let navVC = UINavigationController(rootViewController: menuController)
        menuController.menuSelected = menuSelected(_:)
        navVC.modalTransitionStyle = .flipHorizontal
        navVC.modalPresentationStyle = .overCurrentContext
        present(navVC, animated: true, completion: nil)
    }

    func menuSelected(_ menu: Menu) {
        switch menu {
        case .simple:
            print("Simple")
        case .conversation:
            print("Conversation")
            /// Use this to embed one more container.
//            let vc = ConversationContainerViewController()
//            let navVC = UINavigationController(rootViewController: vc)
//            self.present(navVC, animated: true, completion: nil)
            let conversationVC = ALKConversationListViewController(configuration: AppDelegate.config)
            let nav = ALKBaseNavigationViewController(rootViewController: conversationVC)
            present(nav, animated: false, completion: nil)
        case .profile:
            print("Profile")
        }
    }

    func openConversationFromNotification(_ viewController: ALKConversationListViewController) {
        /// Use this if you'd used `ConversationContainerViewController` above.
//        let vc = ConversationContainerViewController()
//        vc.conversationVC = viewController
//        let navVC = UINavigationController(rootViewController: vc)
//        self.present(navVC, animated: true, completion: nil)
        let nav = ALKBaseNavigationViewController(rootViewController: viewController)
        present(nav, animated: false, completion: nil)
    }
}

class ConversationContainerViewController: UIViewController {
    lazy var conversationVC = ALKConversationListViewController(configuration: AppDelegate.config)

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(back))
        add(conversationVC)
        conversationVC.view.frame = view.bounds
        conversationVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        conversationVC.view.translatesAutoresizingMaskIntoConstraints = true
    }

    @objc func back() {
        dismiss(animated: true, completion: nil)
    }

    deinit {
        conversationVC.remove()
    }
}

class MenuViewController: UIViewController {
    let simpleButton: UIButton = {
        let button = UIButton()
        button.setTitle(Menu.simple.rawValue, for: .normal)
        return button
    }()

    let conversationButton: UIButton = {
        let button = UIButton()
        button.setTitle(Menu.conversation.rawValue, for: .normal)
        return button
    }()

    let profileButton: UIButton = {
        let button = UIButton()
        button.setTitle(Menu.profile.rawValue, for: .normal)
        return button
    }()

    let modalView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray
        return view
    }()

    var menuSelected: ((Menu) -> Void)?

    init() {
        super.init(nibName: nil, bundle: nil)
        navigationController?.navigationBar.backgroundColor = UIColor.lightGray
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(backTapped))
        setupConstraints()
        setTarget()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupConstraints() {
        view.addViewsForAutolayout(views: [modalView])
        modalView.addViewsForAutolayout(views: [simpleButton, conversationButton, profileButton])

        modalView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6).isActive = true
        modalView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        modalView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        modalView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        simpleButton.leadingAnchor.constraint(equalTo: modalView.leadingAnchor).isActive = true
        simpleButton.trailingAnchor.constraint(equalTo: modalView.trailingAnchor).isActive = true
        simpleButton.topAnchor.constraint(equalTo: modalView.topAnchor).isActive = true
        simpleButton.heightAnchor.constraint(equalToConstant: 30).isActive = true

        conversationButton.leadingAnchor.constraint(equalTo: modalView.leadingAnchor).isActive = true
        conversationButton.trailingAnchor.constraint(equalTo: modalView.trailingAnchor).isActive = true
        conversationButton.topAnchor.constraint(equalTo: simpleButton.bottomAnchor, constant: 10).isActive = true
        conversationButton.heightAnchor.constraint(equalToConstant: 30).isActive = true

        profileButton.leadingAnchor.constraint(equalTo: modalView.leadingAnchor).isActive = true
        profileButton.trailingAnchor.constraint(equalTo: modalView.trailingAnchor).isActive = true
        profileButton.topAnchor.constraint(equalTo: conversationButton.bottomAnchor, constant: 10).isActive = true
        profileButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }

    @objc func buttonTapped(_ button: UIButton) {
        guard
            let title = button.title(for: .normal),
            let menu = Menu(rawValue: title),
            let menuSelected = menuSelected
        else {
            return
        }
        dismiss(animated: true) {
            menuSelected(menu)
        }
    }

    @objc func backTapped() {
        dismiss(animated: true, completion: nil)
    }

    func setTarget() {
        simpleButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        conversationButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        profileButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
    }
}

extension UIView {
    func addViewsForAutolayout(views: [UIView]) {
        for view in views {
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
        }
    }
}

extension UIViewController {
    var bottomAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.view.safeAreaLayoutGuide.bottomAnchor
        } else {
            return view.bottomAnchor
        }
    }

    var topAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.view.safeAreaLayoutGuide.topAnchor
        } else {
            return view.topAnchor
        }
    }

    var leadingAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.view.safeAreaLayoutGuide.leadingAnchor
        } else {
            return view.leadingAnchor
        }
    }

    var trailingAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.view.safeAreaLayoutGuide.trailingAnchor
        } else {
            return view.trailingAnchor
        }
    }

    func add(_ child: UIViewController) {
        addChild(child)
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }

    func remove() {
        guard parent != nil else { return }
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}
