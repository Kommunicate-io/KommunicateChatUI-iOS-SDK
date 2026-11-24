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
        guard let message = message, let newIndexPath = indexPath else { return }
        tableView.beginUpdates()
        tableView.insertSections(IndexSet(integer: newIndexPath.section), with: .automatic)
        tableView.endUpdates()
        tableView.scrollToBottom(animated: false)
        // Audio files are shown in the voice cell, not the document cell.
        let isAudio = message.fileMeta?.contentType?.hasPrefix("audio") == true
        let documentCell = tableView.cellForRow(at: newIndexPath) as? KMChatMyDocumentCell
        guard isAudio || documentCell != nil else { return }
        guard ALDataNetworkConnection.checkDataNetworkAvailable() else {
            let notificationView = ALNotificationView()
            notificationView.noDataConnectionNotificationView()
            return
        }
        if let documentCell = documentCell {
            viewModel.uploadImage(view: documentCell, indexPath: newIndexPath)
        } else {
            viewModel.uploadAudio(alMessage: message, indexPath: newIndexPath)
        }
    }
}
