//
//  ALKConversationViewController+CustomCameraProtocol.swift
//  ApplozicSwift
//
//  Created by Mukesh Thawani on 03/07/18.
//

import Foundation
import Applozic


extension ALKConversationViewController: ALKCustomCameraProtocol {

    func customCameraDidTakePicture(cropedImage: UIImage) {
        print("Image call done")
        isJustSent = true

        let (message, indexPath) =  viewModel.send(photo: cropedImage)
        guard let _ = message, let newIndexPath = indexPath else { return }
        tableView.beginUpdates()
        tableView.insertSections(IndexSet(integer: newIndexPath.section), with: .automatic)
        tableView.endUpdates()
        tableView.scrollToBottom(animated: false)

        guard let cell = tableView.cellForRow(at: newIndexPath) as? ALKMyPhotoPortalCell else { return }
        cell.setLocalizedStringFileName(configuration.localizedStringFileName)
        guard ALDataNetworkConnection.checkDataNetworkAvailable() else {
            let notificationView = ALNotificationView()
            notificationView.noDataConnectionNotificationView()
            return
        }
        viewModel.uploadImage(view: cell, indexPath: newIndexPath)
    }
}
