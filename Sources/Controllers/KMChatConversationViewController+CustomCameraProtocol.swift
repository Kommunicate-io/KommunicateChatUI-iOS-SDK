//
//  KMChatConversationViewController+CustomCameraProtocol.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by Mukesh Thawani on 03/07/18.
//

import Foundation
import KommunicateCore_iOS_SDK

extension KMChatConversationViewController: KMChatCustomCameraProtocol {
    func customCameraDidTakePicture(cropedImage: UIImage) {
        print("Image call done")
        isJustSent = true

        let (message, indexPath) = viewModel.send(photo: cropedImage, metadata: configuration.messageMetadata, caption: "")
        guard message != nil, let newIndexPath = indexPath else { return }
        tableView.beginUpdates()
        tableView.insertSections(IndexSet(integer: newIndexPath.section), with: .automatic)
        tableView.endUpdates()
        tableView.scrollToBottom(animated: false)

        guard let cell = tableView.cellForRow(at: newIndexPath) as? KMChatMyPhotoPortalCell else { return }
        cell.setLocalizedStringFileName(configuration.localizedStringFileName)
        guard ALDataNetworkConnection.checkDataNetworkAvailable() else {
            let notificationView = ALNotificationView()
            notificationView.noDataConnectionNotificationView()
            return
        }
        viewModel.uploadImage(view: cell, indexPath: newIndexPath)
    }
}
