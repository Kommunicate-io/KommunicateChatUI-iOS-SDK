//
//  ALKConversationViewController+AutoComplete.swift
//  ApplozicSwift
//
//  Created by Mukesh on 19/09/19.
//

import Foundation

extension ALKConversationViewController: AutoCompletionDelegate {
    public func didMatch(prefix: String, message: String) {
        guard prefix == MessageMention.Prefix else { return }

        let items = viewModel.fetchGroupMembersForAutocompletion()
        // update auto completion items based on the prefix
        if message.isEmpty {
            autocompleteManager.items = items
        } else {
            autocompleteManager.items = items.filter { $0.content.lowercased().contains(message) }
        }

        // Reload and show the view
        UIView.performWithoutAnimation {
            self.autocompleteManager.reloadAutoCompletionView()
        }
        autocompleteManager.hide(false)
    }
}
