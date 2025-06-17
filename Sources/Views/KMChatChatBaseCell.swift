//
//  KMChatChatBaseCell.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by Mukesh Thawani on 04/05/17.
//

import UIKit

open class KMChatChatBaseCell<T>: KMChatBaseCell<T>, Localizable {
    public enum MenuOption {
        case copy
        case reply
        case report
    }

    var localizedStringFileName: String!
    var menuOptionsToShow: [MenuOption] = []
    var showReport: Bool = false

    public func setLocalizedStringFileName(_ localizedStringFileName: String) {
        self.localizedStringFileName = localizedStringFileName
    }

    fileprivate weak var chatBar: KMChatChatBar?

    lazy var longPressGesture: UILongPressGestureRecognizer = .init(target: self, action: #selector(showMenuController(withLongPress:)))

    var avatarTapped: (() -> Void)?

    /// It will be invoked when one of the actions
    /// is selected.
    var menuAction: ((MenuOption) -> Void)?

    func update(chatBar: KMChatChatBar) {
        self.chatBar = chatBar
    }

    @objc func menuWillShow(_: Any) {
        NotificationCenter.default.removeObserver(self, name: UIMenuController.willShowMenuNotification, object: nil)
    }

    @objc func menuWillHide(_: Any) {
        NotificationCenter.default.removeObserver(self, name: UIMenuController.willHideMenuNotification, object: nil)

        if let chatBar = chatBar {
            chatBar.textView.overrideNextResponder = nil
        }
    }

    @objc func showMenuController(withLongPress sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            NotificationCenter.default.addObserver(self, selector: #selector(menuWillShow(_:)), name: UIMenuController.willShowMenuNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(menuWillHide(_:)), name: UIMenuController.willHideMenuNotification, object: nil)

            if let chatBar = chatBar, chatBar.textView.isFirstResponder {
                chatBar.textView.overrideNextResponder = contentView
            } else {
                _ = canBecomeFirstResponder
            }

            guard let gestureView = sender.view, let _ = sender.view?.superview else {
                return
            }

            let menuController = UIMenuController.shared

            guard !menuController.isMenuVisible, gestureView.canBecomeFirstResponder else {
                return
            }

            gestureView.becomeFirstResponder()

            var menus: [UIMenuItem] = []

            if let copyMenu = getCopyMenuItem(copyItem: self) {
                menus.append(copyMenu)
            }

            if let replyMenu = getReplyMenuItem(replyItem: self) {
                menus.append(replyMenu)
            }

            if showReport, let reportMessageMenu = getReportMessageItem(reportMessageItem: self) {
                menus.append(reportMessageMenu)
            }

            menuController.menuItems = menus
            menuController.showMenu(from: gestureView, rect: gestureView.bounds)
        }
    }
    
    override open var canBecomeFirstResponder: Bool {
        return true
    }

    override open func canPerformAction(_ action: Selector, withSender _: Any?) -> Bool {
        switch self {
        case let menuItem as KMChatCopyMenuItemProtocol where action == menuItem.selector:
            return true
        case let menuItem as KMChatReplyMenuItemProtocol where action == menuItem.selector:
            return true
        case let menuItem as KMChatReportMessageMenuItemProtocol where action == menuItem.selector:
            return true
        default:
            return false
        }
    }

    func getCopyMenuItem(copyItem: Any) -> UIMenuItem? {
        guard menuOptionsToShow.contains(.copy), let copyMenuItem = copyItem as? KMChatCopyMenuItemProtocol else {
            return nil
        }
        let title = localizedString(forKey: "Copy", withDefaultValue: SystemMessage.LabelName.Copy, fileName: localizedStringFileName)
        let copyMenu = UIMenuItem(title: title, action: copyMenuItem.selector)
        return copyMenu
    }

    func getReplyMenuItem(replyItem: Any) -> UIMenuItem? {
        guard menuOptionsToShow.contains(.reply), let replyMenuItem = replyItem as? KMChatReplyMenuItemProtocol else {
            return nil
        }
        let title = localizedString(forKey: "Reply", withDefaultValue: SystemMessage.LabelName.Reply, fileName: localizedStringFileName)
        let replyMenu = UIMenuItem(title: title, action: replyMenuItem.selector)
        return replyMenu
    }

    func getReportMessageItem(reportMessageItem: Any) -> UIMenuItem? {
        guard menuOptionsToShow.contains(.report),
              let reportMessageMenuItem = reportMessageItem as? KMChatReportMessageMenuItemProtocol
        else {
            return nil
        }
        let title = localizedString(forKey: "Report", withDefaultValue: SystemMessage.LabelName.Report, fileName: localizedStringFileName)
        let reportMessageMenu = UIMenuItem(title: title, action: reportMessageMenuItem.selector)
        return reportMessageMenu
    }
}

extension KMChatChatBaseCell where T == KMChatMessageViewModel {
    func setStatusStyle(
        statusView: UIImageView,
        _ style: KMChatMessageStyle.SentMessageStatus,
        _ size: CGSize = CGSize(width: 17, height: 9)
    ) {
        guard let viewModel = viewModel,
              let statusIcon = style.statusIcons[viewModel.status] else { return }
        switch statusIcon {
        case let .templateImageWithTint(image, tintColor):
            statusView.image = image
                .imageFlippedForRightToLeftLayoutDirection()
                .scale(with: size)?
                .withRenderingMode(.alwaysTemplate)
            statusView.tintColor = tintColor
        case let .normalImage(image):
            statusView.image = image
                .imageFlippedForRightToLeftLayoutDirection()
                .scale(with: size)?
                .withRenderingMode(.alwaysOriginal)
        case .none:
            statusView.image = nil
        }
    }
}

// MARK: - KMChatCopyMenuItemProtocol

@objc protocol KMChatCopyMenuItemProtocol {
    func menuCopy(_ sender: Any)
}

extension KMChatCopyMenuItemProtocol {
    var selector: Selector {
        return #selector(menuCopy(_:))
    }
}

// MARK: - KMChatReplyMenuItemProtocol

@objc protocol KMChatReplyMenuItemProtocol {
    func menuReply(_ sender: Any)
}

extension KMChatReplyMenuItemProtocol {
    var selector: Selector {
        return #selector(menuReply(_:))
    }
}

// MARK: - KMChatReportMessageMenuItemProtocol

@objc protocol KMChatReportMessageMenuItemProtocol {
    func menuReport(_ sender: Any)
}

extension KMChatReportMessageMenuItemProtocol {
    var selector: Selector {
        return #selector(menuReport(_:))
    }
}
