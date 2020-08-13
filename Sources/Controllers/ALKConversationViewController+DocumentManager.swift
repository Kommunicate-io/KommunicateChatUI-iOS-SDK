//
//  ALKConversationViewController+DocumentManager.swift
//  ApplozicSwift
//
//  Created by Mukesh on 07/08/20.
//

import UIKit
import Applozic

extension ALKConversationViewController: ALKDocumentManagerDelegate {
    func documentSelected(at url: URL, fileName: String) {
        let (message, indexPath) = viewModel.sendFile(
            at: url,
            fileName: fileName,
            metadata: configuration.messageMetadata
        )
        guard message != nil, let newIndexPath = indexPath else { return }
        self.tableView.beginUpdates()
        self.tableView.insertSections(IndexSet(integer: newIndexPath.section), with: .automatic)
        self.tableView.endUpdates()
        self.tableView.scrollToBottom(animated: false)
        guard let cell = tableView.cellForRow(at: newIndexPath) as? ALKMyDocumentCell else { return }
        guard ALDataNetworkConnection.checkDataNetworkAvailable() else {
            let notificationView = ALNotificationView()
            notificationView.noDataConnectionNotificationView()
            return
        }
        viewModel.uploadImage(view: cell, indexPath: newIndexPath)
    }
}
