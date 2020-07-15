//
//  ALKConversationViewController+ALKFormCell.swift
//  ApplozicSwift
//
//  Created by Mukesh on 13/07/20.
//

import Foundation

extension ALKConversationViewController {
    func scrollTableViewUpForActiveField(notification: Notification) {
        guard let activeTextField = activeTextField else { return }
        let info = notification.userInfo as! [String: AnyObject]
        let kbSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue.size
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: kbSize.height, right: 0)

        tableView.contentInset = contentInsets
        tableView.scrollIndicatorInsets = contentInsets

        var aRect = view.frame
        aRect.size.height -= kbSize.height

        let pointInTable = activeTextField.superview!.convert(activeTextField.frame.origin, to: tableView)
        let rectInTable = activeTextField.superview!.convert(activeTextField.frame, to: tableView)

        if !aRect.contains(pointInTable) {
            tableView.scrollRectToVisible(rectInTable, animated: true)
        }
    }

    func scrollTableViewDownForActiveField() {
        let contentInsets = UIEdgeInsets.zero
        tableView.contentInset = contentInsets
        tableView.scrollIndicatorInsets = contentInsets
    }
}
