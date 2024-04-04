//
//  TableViewDataSource.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by Shivam Pokhriyal on 29/11/18.
//

import Foundation
import KommunicateCore_iOS_SDK

public class ConversationListTableViewDataSource: NSObject, UITableViewDataSource {
    /// A closure to configure tableview cell with the message object
    public typealias CellConfigurator = (ALKChatViewModelProtocol, UITableViewCell) -> Void
    public var cellConfigurator: CellConfigurator

    public var viewModel: ALKConversationListViewModelProtocol

    public init(viewModel: ALKConversationListViewModelProtocol, cellConfigurator: @escaping CellConfigurator) {
        self.viewModel = viewModel
        self.cellConfigurator = cellConfigurator
    }

    public func numberOfSections(in _: UITableView) -> Int {
        return viewModel.numberOfSections()
    }

    public func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Pakka101 conversation count \(viewModel.numberOfRowsInSection(section))")
        return viewModel.numberOfRowsInSection(section)
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let message = viewModel.chatFor(indexPath: indexPath) as? ALMessage else {
            return UITableViewCell()
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cellConfigurator(message, cell)
        return cell
    }
}
