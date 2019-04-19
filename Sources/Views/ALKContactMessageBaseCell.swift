//
//  ALKContactMessageBaseCell.swift
//  ApplozicSwift
//
//  Created by Shivam Pokhriyal on 19/04/19.
//

import Applozic
import Contacts

class ALKContactMessageBaseCell: ALKChatBaseCell<ALKMessageViewModel>, ALKHTTPManagerDownloadDelegate {

    let contactView = ContactView(frame: .zero)
    let loadingIndicator = ALKLoadingIndicator(frame: .zero, color: UIColor.red)

    func updateContactDetails(key: String, filePath: String) {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fullPath = documentsURL.appendingPathComponent(filePath)
        guard
            let data = try? Data(contentsOf: fullPath),
            let contacts = try? CNContactVCardSerialization.contacts(with: data),
            !contacts.isEmpty
            else {
                return
        }
        loadingIndicator.stopLoading()
        let contact = contacts[0]
        let contactModel = ContactModel(
            identifier: key,
            contact: contact)
        contactView.update(contactModel: contactModel)
        contactView.isHidden = false
    }

    private func updateDbMessageWith(key: String, value: String, filePath: String) {
        let messageService = ALMessageDBService()
        let alHandler = ALDBHandler.sharedInstance()
        let dbMessage: DB_Message = messageService.getMessageByKey(key, value: value) as! DB_Message
        dbMessage.filePath = filePath
        do {
            try alHandler?.managedObjectContext.save()
        } catch {
            NSLog("Not saved due to error")
        }
    }
    
    func dataDownloaded(task: ALKDownloadTask) {
        NSLog("Bytes downloaded: %i", task.totalBytesDownloaded)
    }

    func dataDownloadingFinished(task: ALKDownloadTask) {
        guard task.downloadError == nil, let filePath = task.filePath, let identifier = task.identifier else {
            return
        }
        self.updateDbMessageWith(key: "key", value: identifier, filePath: filePath)
        DispatchQueue.main.async {
            self.updateContactDetails(key: identifier, filePath: filePath)
        }
    }
}
