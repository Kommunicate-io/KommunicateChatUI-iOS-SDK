//
//  KMChatConversationViewController+Alert.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by Mukesh on 19/09/19.
//

import Foundation
import KommunicateCore_iOS_SDK

extension KMChatConversationViewController: ALAlertButtonClickProtocol {
    func confirmButtonClick(action: String, messageKey: String) {
        let alPushAssist = ALPushAssist()

        if action == KMChatAlertViewController.Action.reportMessage {
            alPushAssist.topViewController.dismiss(animated: true, completion: nil)

            guard ALDataNetworkConnection.checkDataNetworkAvailable() else {
                return
            }

            let userService = ALUserService()
            let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
            activityIndicator.center = CGPoint(x: view.bounds.size.width / 2,
                                               y: view.bounds.size.height / 2)
            activityIndicator.color = UIColor.gray
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()

            let message = localizedString(forKey: "ReportMessageSuccess", withDefaultValue: SystemMessage.Information.ReportMessageSuccess, fileName: configuration.localizedStringFileName)

            let errorMessage = localizedString(forKey: "ReportMessageError", withDefaultValue: SystemMessage.Information.ReportMessageError, fileName: configuration.localizedStringFileName)

            userService.reportUser(withMessageKey: messageKey) { _, error in
                activityIndicator.stopAnimating()
                if error == nil {
                    self.showAlert(alertTitle: "", alertMessage: message)
                } else {
                    self.showAlert(alertTitle: "", alertMessage: errorMessage)
                }
            }
        }
    }

    func showAlert(alertTitle: String, alertMessage: String) {
        let alPushAssist = ALPushAssist()
        let title = localizedString(forKey: "OkMessage", withDefaultValue: SystemMessage.ButtonName.ok, fileName: configuration.localizedStringFileName)
        let alert = UIAlertController(
            title: alertTitle,
            message: alertMessage,
            preferredStyle: UIAlertController.Style.alert
        )
        alert.addAction(UIAlertAction(title: title, style: UIAlertAction.Style.default, handler: nil))
        alPushAssist.topViewController.present(alert, animated: true, completion: nil)
    }

    func menuItemSelected(
        action: KMChatChatBaseCell<KMChatMessageViewModel>.MenuOption,
        message: KMChatMessageViewModel
    ) {
        switch action {
        case .reply:
            print("Reply selected")
            viewModel.setSelectedMessageToReply(message)
            replyMessageView.update(message: message)
            showReplyMessageView()
        case .report:
            let muteConversationVC = KMChatAlertViewController(action: KMChatAlertViewController.Action.reportMessage, delegate: self, messageKey: message.identifier, configuration: configuration)
            let title = localizedString(forKey: "ReportAlertTitle", withDefaultValue: SystemMessage.Information.ReportAlertTitle, fileName: configuration.localizedStringFileName)
            let message = localizedString(forKey: "ReportAlertMessage", withDefaultValue: SystemMessage.Information.ReportAlertMessage, fileName: configuration.localizedStringFileName)
            muteConversationVC.updateTitleAndMessage(title, message: message)
            muteConversationVC.modalPresentationStyle = .overCurrentContext
            present(muteConversationVC, animated: true, completion: nil)
        case .copy:
            UIPasteboard.general.string = message.message ?? ""
        case .delete:
            showDeleteMessageConfirmation(message: message)
        }
    }

    private func showDeleteMessageConfirmation(message: KMChatMessageViewModel) {
        let fileName = configuration.localizedStringFileName
        let alertMessage = message.isMyMessage
            ? localizedString(forKey: "DeleteMessageAlertMessage", withDefaultValue: SystemMessage.Information.DeleteMessageAlertMessage, fileName: fileName)
            : localizedString(forKey: "DeleteMessageForMeAlertMessage", withDefaultValue: SystemMessage.Information.DeleteMessageForMeAlertMessage, fileName: fileName)
        let alert = UIAlertController(
            title: localizedString(forKey: "DeleteMessageAlertTitle", withDefaultValue: SystemMessage.Information.DeleteMessageAlertTitle, fileName: fileName),
            message: alertMessage,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: localizedString(forKey: "ButtonCancel", withDefaultValue: SystemMessage.ButtonName.Cancel, fileName: fileName), style: .cancel))
        alert.addAction(UIAlertAction(title: localizedString(forKey: "DeleteButtonName", withDefaultValue: SystemMessage.ButtonName.Delete, fileName: fileName), style: .destructive) { [weak self] _ in
            self?.deleteMessage(message: message)
        })
        present(alert, animated: true)
    }

    private typealias RemovedMessage = (message: KMCoreMessage, messageIndex: Int, modelIndex: Int)

    private func deleteMessage(message: KMChatMessageViewModel) {
        let messageService = KMCoreMessageService()
        let removedMessage = removeMessageFromUI(identifier: message.identifier)

        guard message.isMyMessage else {
            messageService.deleteMessage(message.identifier, andContactId: nil) { _, _ in }
            return
        }

        messageService.deleteMessageForAll(withKey: message.identifier) { [weak self] _, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                guard error == nil else {
                    if let removedMessage = removedMessage {
                        self.restoreMessageInUI(removedMessage)
                    }
                    let errorMessage = self.localizedString(forKey: "DeleteMessageError", withDefaultValue: SystemMessage.Information.DeleteMessageError, fileName: self.configuration.localizedStringFileName)
                    self.showAlert(alertTitle: "", alertMessage: errorMessage)
                    return
                }
                KMCoreMessageDBService().deleteMessage(byKey: message.identifier)
            }
        }
    }

    private func removeMessageFromUI(identifier: String) -> RemovedMessage? {
        guard let messageIndex = viewModel.alMessages.firstIndex(where: { $0.identifier == identifier }),
              let modelIndex = viewModel.messageModels.firstIndex(where: { $0.identifier == identifier })
        else { return nil }
        tableView.endEditing(true)
        let isTableInSync = tableView.numberOfSections == viewModel.messageModels.count
        let message = viewModel.alMessages.remove(at: messageIndex)
        viewModel.messageModels.remove(at: modelIndex)
        if isTableInSync {
            tableView.performBatchUpdates {
                self.tableView.deleteSections(IndexSet(integer: modelIndex), with: .fade)
            }
        } else {
            tableView.reloadData()
        }
        return (message, messageIndex, modelIndex)
    }

    private func restoreMessageInUI(_ removed: RemovedMessage) {
        guard !viewModel.alMessages.contains(where: { $0.identifier == removed.message.identifier }) else { return }
        viewModel.alMessages.insert(removed.message, at: min(removed.messageIndex, viewModel.alMessages.count))
        viewModel.messageModels.insert(removed.message.messageModel, at: min(removed.modelIndex, viewModel.messageModels.count))
        tableView.reloadData()
    }
}
