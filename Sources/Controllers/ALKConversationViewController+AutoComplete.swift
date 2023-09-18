//
//  ALKConversationViewController+AutoComplete.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by Mukesh on 19/09/19.
//

import Foundation
import UIKit

extension ALKConversationViewController: AutoCompletionDelegate {
    public func didMatch(prefix: String, message: String, updated: Bool) {
        if isAutoSuggestionRichMessage , message.count >= 2 {
            var arrayOfAutocomplete: [AutoCompleteItem] = []
            if suggestionArray.isEmpty {
                if !autoSuggestionApi.isEmpty {
                    if !updated {
                        fetchData(from: autoSuggestionApi, message: message)
                        currentText = message
                    }
                    let items = suggestionDict
                    for dictionary in items {
                        if let key = dictionary["searchKey"] as? String, let content = dictionary["message"] as? String {
                            let autoCompleteItem = AutoCompleteItem(key: key, content: content)
                            arrayOfAutocomplete.append(autoCompleteItem)
                        }
                    }
                }
                else {
                    let items = suggestionDict
                    for dictionary in items {
                        if let key = dictionary["searchKey" ] as? String, let content = dictionary["message"] as? String{
                            let autoCompleteItem = AutoCompleteItem(key: key, content: content)
                            arrayOfAutocomplete.append(autoCompleteItem)
                        }
                    }
                }
            } else {
                let items = suggestionArray
                arrayOfAutocomplete = items.map{ AutoCompleteItem(key: $0, content: $0)}
            }
            if message.isEmpty {
                autoSuggestionManager.items = arrayOfAutocomplete
            } else {
                let searchMessage = message.dropFirst()
                autoSuggestionManager.items = arrayOfAutocomplete.filter{ $0.key.lowercased().contains(searchMessage) }
            }
                    
            UIView.performWithoutAnimation {
                self.autoSuggestionManager.reloadAutoCompletionView()
            }
            autoSuggestionManager.hide(false)
        } else {
            autoSuggestionManager.hide(true)
            if !updated{
                currentText = message
            }
        }
        
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
