//
//  KMChatConversationViewController+DocumentManager.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by Mukesh on 07/08/20.
//

import KommunicateCore_iOS_SDK
import UIKit

extension KMChatConversationViewController: KMChatDocumentManagerDelegate {
    func documentSelected(at url: URL, fileName: String) {
        // We are getting file size in KB
        if let size = FileManager().sizeOfFile(atPath: url.path), size > (KMCoreSettings.getMaxImageSizeForUploadInMB() * 1024) {
            showUploadRestrictionAlert()
            return
        }

        let (message, indexPath) = viewModel.sendFile(
            at: url,
            fileName: fileName,
            metadata: configuration.messageMetadata
        )
        guard message != nil, let newIndexPath = indexPath else { return }
        tableView.beginUpdates()
        tableView.insertSections(IndexSet(integer: newIndexPath.section), with: .automatic)
        tableView.endUpdates()
        tableView.scrollToBottom(animated: false)
        guard let cell = tableView.cellForRow(at: newIndexPath) as? KMChatMyDocumentCell else { return }
        guard ALDataNetworkConnection.checkDataNetworkAvailable() else {
            let notificationView = ALNotificationView()
            notificationView.noDataConnectionNotificationView()
            return
        }
        viewModel.uploadImage(view: cell, indexPath: newIndexPath)
    }
}
