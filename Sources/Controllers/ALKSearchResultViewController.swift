//
//  SearchResultViewController.swift
//  Kommunicate Chat
//
//  Created by Shivam Pokhriyal on 17/06/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Applozic
import UIKit

class ALKSearchResultViewController: UIViewController {
    fileprivate let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)

    let viewModel = SearchResultViewModel()
    let configuration: ALKConfiguration

    lazy var viewController = ALKConversationListTableViewController(
        viewModel: self.viewModel,
        dbService: ALMessageDBService(),
        configuration: self.configuration,
        showSearch: false
    )

    var conversationViewController: ALKConversationViewController?

    init(configuration: ALKConfiguration) {
        self.configuration = configuration
        super.init(nibName: nil, bundle: nil)
        viewController.delegate = self
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    func search(key: String) {
        activityIndicator.startAnimating()
        clear()
        viewController.replaceViewModel(viewModel)
        viewModel.searchMessage(with: key) { result in
            self.activityIndicator.stopAnimating()
            if result {
                self.viewController.replaceViewModel(self.viewModel)
            }
        }
    }

    func clear() {
        viewModel.clear()
    }

    func clearAndReload() {
        clear()
        viewController.tableView.reloadData()
    }

    private func setupView() {
        /// Add TableViewController
        add(viewController)
        viewController.view.frame = view.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewController.view.translatesAutoresizingMaskIntoConstraints = true

        /// Add Activity Indicator
        activityIndicator.center = CGPoint(x: view.bounds.size.width / 2, y: view.bounds.size.height / 2)
        activityIndicator.color = UIColor.gray
        view.addSubview(activityIndicator)
        view.bringSubviewToFront(activityIndicator)
    }
}

extension ALKSearchResultViewController: ALKConversationListTableViewDelegate {
    func muteNotification(conversation _: ALMessage, isMuted _: Bool) {}

    func userBlockNotification(userId _: String, isBlocked _: Bool) {}

    func tapped(_ chat: ALKChatViewModelProtocol, at _: Int) {
        let convViewModel = viewModel.conversationViewModelFrom(
            contactId: chat.contactId,
            channelId: chat.channelKey,
            conversationId: chat.conversationId,
            localizationFileName: configuration.localizedStringFileName
        )
        convViewModel.isSearch = true

        let viewController = conversationViewController ?? ALKConversationViewController(configuration: configuration)
        viewController.viewModel = convViewModel
        viewController.individualLaunch = false
        conversationViewController = viewController

        let navVC = ALKBaseNavigationViewController(rootViewController: viewController)
        present(navVC, animated: false, completion: nil)
    }

    func emptyChatCellTapped() {}

    func scrolledToBottom() {}
}
