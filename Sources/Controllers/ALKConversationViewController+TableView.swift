//
//  ALKConversationViewController+TableView.swift
//  
//
//  Created by Mukesh Thawani on 04/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import Applozic

extension ALKConversationViewController: UITableViewDelegate, UITableViewDataSource {

    public func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(section: section)
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard var message = viewModel.messageForRow(indexPath: indexPath) else {
            return UITableViewCell()
        }
        print("Cell updated at row: ", indexPath.row, "and type is: ", message.messageType)

        guard !message.isReplyMessage else {
            // Get reply cell and return
            if message.isMyMessage {

                let cell: ALKMyMessageCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.update(viewModel: message)
                cell.update(chatBar: self.chatBar)
                cell.menuAction = {[weak self] action in
                    self?.menuItemSelected(action: action, message: message) }
                cell.replyViewAction = {[weak self] in
                    self?.scrollTo(message: message)
                }
                return cell

            } else {
                let cell: ALKFriendMessageCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.update(viewModel: message)
                cell.update(chatBar: self.chatBar)
                cell.avatarTapped = {[weak self] in
                    guard let currentModel = cell.viewModel else {return}
                    self?.messageAvatarViewDidTap(messageVM: currentModel, indexPath: indexPath)
                }
                cell.menuAction = {[weak self] action in
                    self?.menuItemSelected(action: action, message: message) }
                cell.replyViewAction = {[weak self] in
                    self?.scrollTo(message: message)
                }
                return cell
            }
        }
        switch message.messageType {
        case .text, .html:
            if message.isMyMessage {

                let cell: ALKMyMessageCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.update(viewModel: message)
                cell.update(chatBar: self.chatBar)
                cell.menuAction = {[weak self] action in
                    self?.menuItemSelected(action: action, message: message) }
                return cell

            } else {
                let cell: ALKFriendMessageCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.update(viewModel: message)
                cell.update(chatBar: self.chatBar)
                cell.avatarTapped = {[weak self] in
                    guard let currentModel = cell.viewModel else {return}
                    self?.messageAvatarViewDidTap(messageVM: currentModel, indexPath: indexPath)
                }
                cell.menuAction = {[weak self] action in
                    self?.menuItemSelected(action: action, message: message) }
                return cell
            }
        case .photo:
            if message.isMyMessage {
                // Right now ratio is fixed to 1.77
                if message.ratio < 1 {
                    print("image messsage called")
                    let cell: ALKMyPhotoPortalCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                    // Set the value to nil so that previous image gets removed before reuse
                    cell.photoView.image = nil
                    cell.update(viewModel: message)
                    cell.uploadTapped = {[weak self]
                        value in
                        // upload
                        self?.attachmentViewDidTapUpload(view: cell, indexPath: indexPath)
                    }
                    cell.uploadCompleted = {[weak self]
                        responseDict in
                        self?.attachmentUploadDidCompleteWith(response: responseDict, indexPath: indexPath)
                    }
                    cell.downloadTapped = {[weak self]
                        value in
                        self?.attachmentViewDidTapDownload(view: cell, indexPath: indexPath)
                    }
                    cell.menuAction = {[weak self] action in
                        self?.menuItemSelected(action: action, message: message) }
                    return cell

                } else {
                    let cell: ALKMyPhotoLandscapeCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                    cell.update(viewModel: message)
                    cell.uploadCompleted = {[weak self]
                        responseDict in
                        self?.attachmentUploadDidCompleteWith(response: responseDict, indexPath: indexPath)
                    }
                    return cell
                }

            } else {
                if message.ratio < 1 {

                    let cell: ALKFriendPhotoPortalCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                    cell.update(viewModel: message)
                    cell.downloadTapped = {[weak self]
                        value in
                        self?.attachmentViewDidTapDownload(view: cell, indexPath: indexPath)
                    }
                    cell.avatarTapped = {[weak self] in
                        guard let currentModel = cell.viewModel else {return}
                        self?.messageAvatarViewDidTap(messageVM: currentModel, indexPath: indexPath)
                    }
                    cell.menuAction = {[weak self] action in
                        self?.menuItemSelected(action: action, message: message) }
                    return cell

                } else {
                    let cell: ALKFriendPhotoLandscapeCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                    cell.update(viewModel: message)
                    return cell
                }
            }
        case .voice:
            print("voice cell loaded with url", message.filePath as Any)
            print("current voice state: ", message.voiceCurrentState, "row", indexPath.row, message.voiceTotalDuration, message.voiceData as Any)
            print("voice identifier: ", message.identifier, "and row: ", indexPath.row)

            if message.isMyMessage {
                let cell: ALKMyVoiceCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.update(viewModel: message)
                cell.setCellDelegate(delegate: self)
                cell.downloadTapped = {[weak self] value in
                    self?.attachmentViewDidTapDownload(view: cell, indexPath: indexPath)
                }
                cell.menuAction = {[weak self] action in
                    self?.menuItemSelected(action: action, message: message) }
                return cell
            } else {
                let cell: ALKFriendVoiceCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.downloadTapped = {[weak self] value in
                    self?.attachmentViewDidTapDownload(view: cell, indexPath: indexPath)
                }
                cell.update(viewModel: message)
                cell.setCellDelegate(delegate: self)
                cell.avatarTapped = {[weak self] in
                    guard let currentModel = cell.viewModel else {return}
                    self?.messageAvatarViewDidTap(messageVM: currentModel, indexPath: indexPath)
                }
                cell.menuAction = {[weak self] action in
                    self?.menuItemSelected(action: action, message: message) }
                return cell
            }
        case .location:
            if message.isMyMessage {
                let cell: ALKMyLocationCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.update(viewModel: message)
                cell.setDelegate(locDelegate: self)
                cell.menuAction = {[weak self] action in
                    self?.menuItemSelected(action: action, message: message) }
                return cell

            } else {
                let cell: ALKFriendLocationCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.update(viewModel: message)
                cell.setDelegate(locDelegate: self)
                cell.avatarTapped = {[weak self] in
                    guard let currentModel = cell.viewModel else {return}
                    self?.messageAvatarViewDidTap(messageVM: currentModel, indexPath: indexPath)
                }
                cell.menuAction = {[weak self] action in
                    self?.menuItemSelected(action: action, message: message) }
                return cell
            }
        case .information:
            let cell: ALKInformationCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            cell.update(viewModel: message)
            return cell
        case .video:
            if message.isMyMessage {
                let cell: ALKMyVideoCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.update(viewModel: message)
                cell.uploadTapped = {[weak self]
                    value in
                    // upload
                    self?.attachmentViewDidTapUpload(view: cell, indexPath: indexPath)
                }
                cell.uploadCompleted = {[weak self]
                    responseDict in
                    self?.attachmentUploadDidCompleteWith(response: responseDict, indexPath: indexPath)
                }
                cell.downloadTapped = {[weak self]
                    value in
                    self?.attachmentViewDidTapDownload(view: cell, indexPath: indexPath)
                }
                cell.menuAction = {[weak self] action in
                    self?.menuItemSelected(action: action, message: message) }
                return cell
            } else {
                let cell: ALKFriendVideoCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.update(viewModel: message)
                cell.downloadTapped = {[weak self]
                    value in
                    self?.attachmentViewDidTapDownload(view: cell, indexPath: indexPath)
                }
                cell.avatarTapped = {[weak self] in
                    guard let currentModel = cell.viewModel else {return}
                    self?.messageAvatarViewDidTap(messageVM: currentModel, indexPath: indexPath)
                }
                cell.menuAction = {[weak self] action in
                    self?.menuItemSelected(action: action, message: message) }
                return cell
            }
        }
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.heightForRow(indexPath: indexPath, cellFrame: self.view.frame)
    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let heightForHeaderInSection: CGFloat = 40.0

        guard let message1 = viewModel.messageForRow(indexPath: IndexPath(row: 0, section: section)) else {
            return 0.0
        }

        // If it is the first section then no need to check the difference,
        // just show the start date. (message list is not empty)
        if section == 0 {
            return heightForHeaderInSection
        }

        // Get previous message
        guard let message2 = viewModel.messageForRow(indexPath: IndexPath(row: 0, section: section - 1)) else {
            return 0.0
        }
        let date1 = message1.date
        let date2 = message2.date
        switch Calendar.current.compare(date1, to: date2, toGranularity: .day) {
        case .orderedDescending:
            // There is a day difference between current message and the previous message.
            return heightForHeaderInSection
        default:
            return 0.0
        }
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let message = viewModel.messageForRow(indexPath: IndexPath(row: 0, section: section)) else {
            return nil
        }

        // Get message creation date
        let date = message.date

        let dateView = ALKDateSectionHeaderView.instanceFromNib()
        dateView.backgroundColor = UIColor.clear

        // Set date text
        dateView.setupDate(withDateFormat: date.stringCompareCurrentDate())
        return dateView
    }

    //MARK: Paging

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (decelerate) {return}
        configurePaginationWindow()
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        configurePaginationWindow()
    }

    public func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        configurePaginationWindow()
    }

    func configurePaginationWindow() {
        if (self.tableView.frame.equalTo(CGRect.zero)) {return}
        if (self.tableView.isDragging) {return}
        if (self.tableView.isDecelerating) {return}
        let topOffset = -self.tableView.contentInset.top
        let distanceFromTop = self.tableView.contentOffset.y - topOffset
        let minimumDistanceFromTopToTriggerLoadingMore: CGFloat = 200
        let nearTop = distanceFromTop <= minimumDistanceFromTopToTriggerLoadingMore
        if (!nearTop) {return}
        
        self.viewModel.nextPage()
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if tableView.isCellVisible(section: viewModel.messageModels.count-2, row: 0) {
            unreadScrollButton.isHidden = true
        }
    }
}

extension ALTopicDetail: ALKContextTitleDataType {
    public var titleText: String {
        return title ?? ""
    }

    public var subtitleText: String {
        return subtitle
    }

    public var imageURL: URL? {
        guard let urlStr = link, let url = URL(string: urlStr) else {
            return nil
        }
        return url
    }

    public var infoLabel1Text: String? {
        guard let key = key1, let value = value1 else {
            return nil
        }
        return "\(key): \(value)"
    }

    public var infoLabel2Text: String? {
        guard let key = key2, let value = value2 else {
            return nil
        }
        return "\(key): \(value)"
    }

}
