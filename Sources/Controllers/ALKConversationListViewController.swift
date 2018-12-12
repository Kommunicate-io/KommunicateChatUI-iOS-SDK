//
//  ALKConversationListViewController.swift
//
//
//  Created by Mukesh Thawani on 04/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import Foundation
import UIKit
import ContactsUI
import Applozic

/// The delegate of an `ALKConversationListViewController` object.
/// Provides different methods to manage chat thread selections.
public protocol ALKConversationListDelegate {
    func conversation(
        _ message: ALKChatViewModelProtocol,
        willSelectItemAt index: Int,
        viewController: ALKConversationListViewController
    )
}

open class ALKConversationListViewController: ALKBaseViewController, Localizable {

    public var conversationViewController: ALKConversationViewController?
    public var dbServiceType = ALMessageDBService.self
    public var viewModelType = ALKConversationListViewModel.self
    public var conversationViewModelType = ALKConversationViewModel.self
    public var delegate: ALKConversationListDelegate?

    var viewModel: ALKConversationListViewModel!

    // To check if coming from push notification
    var contactId: String?
    var channelKey: NSNumber?

    fileprivate var tapToDismiss:UITapGestureRecognizer!
    fileprivate let searchController = UISearchController(searchResultsController: nil)
    fileprivate var searchActive : Bool = false
    fileprivate var searchFilteredChat:[Any] = []
    fileprivate var alMqttConversationService: ALMQTTConversationService!
    fileprivate var dbService: ALMessageDBService!
    fileprivate let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)

    fileprivate var localizedStringFileName: String!

    let tableView : UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.estimatedRowHeight = 75
        tv.rowHeight = 75
        tv.separatorStyle = .none
        tv.backgroundColor = UIColor.white
        tv.keyboardDismissMode = .onDrag
        tv.accessibilityIdentifier = "OuterChatScreenTableView"
        return tv
    }()

    lazy var rightBarButtonItem: UIBarButtonItem = {
        let barButton = UIBarButtonItem(
            image: configuration.rightNavBarImageForConversationListView,
            style: .plain,
            target: self, action: #selector(compose))
        return barButton
    }()

    fileprivate lazy var searchBar: UISearchBar = {
        var bar = UISearchBar()
        bar.autocapitalizationType = .sentences
        return bar
    }()

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    required public init(configuration: ALKConfiguration) {
        super.init(configuration: configuration)
        self.localizedStringFileName = configuration.localizedStringFileName
    }

    override func addObserver() {

        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "newMessageNotification"), object: nil, queue: nil, using: {[weak self] notification in
            guard let weakSelf = self, let viewModel = weakSelf.viewModel else { return }
            let msgArray = notification.object as? [ALMessage]
            print("new notification received: ", msgArray?.first?.message ?? "")
            guard let list = notification.object as? [Any], !list.isEmpty else { return }
            viewModel.addMessages(messages: list)

        })


        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "pushNotification"), object: nil, queue: nil, using: {[weak self] notification in
            print("push notification received: ", notification.object ?? "")
            guard let weakSelf = self, let object = notification.object as? String else { return }
            let components = object.components(separatedBy: ":")
            var groupId: NSNumber? = nil
            var contactId: String? = nil
            if components.count > 1, let secondComponent = Int(components[1]) {
                let id = NSNumber(integerLiteral: secondComponent)
                groupId = id
            } else {
                contactId = object
            }
            let message = ALMessage()
            message.contactIds = contactId
            message.groupId = groupId
            let info = notification.userInfo
            let alertValue = info?["alertValue"]
            guard let updateUI = info?["updateUI"] as? Int else { return }
            if updateUI == Int(APP_STATE_ACTIVE.rawValue), weakSelf.isViewLoaded, (weakSelf.view.window != nil) {
                guard let alert = alertValue as? String else { return }
                let alertComponents = alert.components(separatedBy: ":")
                if alertComponents.count > 1 {
                    message.message = alertComponents[1]
                } else {
                    message.message = alertComponents.first
                }
                weakSelf.viewModel.addMessages(messages: [message])
            } else if updateUI == Int(APP_STATE_INACTIVE.rawValue) {
                // Coming from background

                guard contactId != nil || groupId != nil else { return }
               weakSelf.launchChat(contactId: contactId, groupId: groupId)
            }
        })

        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "reloadTable"), object: nil, queue: nil, using: {[weak self] notification in
            NSLog("Reloadtable notification received")

            guard let weakSelf = self, let list = notification.object as? [Any] else { return }
            weakSelf.viewModel.updateMessageList(messages: list)
        })

        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "USER_DETAILS_UPDATE_CALL"), object: nil, queue: nil, using: {[weak self] notification in
            NSLog("update user detail notification received")

            guard let weakSelf = self, let userId = notification.object as? String else { return }
            print("update user detail")
            ALUserService.updateUserDetail(userId, withCompletion: {
                userDetail in
                guard let detail = userDetail else { return }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "USER_DETAIL_OTHER_VC"), object: detail)
                weakSelf.tableView.reloadData()
            })
        })

        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "UPDATE_CHANNEL_NAME"), object: nil, queue: nil, using: {[weak self] notification in
            NSLog("update group name notification received")
            guard let weakSelf = self, (weakSelf.view.window != nil) else { return }
            print("update group detail")
            weakSelf.tableView.reloadData()
        })

    }

    override func removeObserver() {
        if (alMqttConversationService) != nil {
            alMqttConversationService.unsubscribeToConversation()
        }
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "pushNotification"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "newMessageNotification"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "reloadTable"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "USER_DETAILS_UPDATE_CALL"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "UPDATE_CHANNEL_NAME"), object: nil)
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dbService = dbServiceType.init()
        dbService.delegate = self
        viewModel = viewModelType.init()
        viewModel.delegate = self
        viewModel.localizationFileName = configuration.localizedStringFileName
        activityIndicator.center = CGPoint(x: view.bounds.size.width/2, y: view.bounds.size.height/2)
        activityIndicator.color = UIColor.gray
        view.addSubview(activityIndicator)
        self.view.bringSubview(toFront: activityIndicator)
        viewModel.prepareController(dbService: dbService)
        self.edgesForExtendedLayout = []
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        searchBar.delegate = self
        alMqttConversationService = ALMQTTConversationService.sharedInstance()
        alMqttConversationService.mqttConversationDelegate = self
        alMqttConversationService.subscribeToConversation()
    }

    override open func viewDidAppear(_ animated: Bool) {
        print("contact id: ", contactId as Any)
        if contactId != nil || channelKey != nil {
            print("contact id present")
            launchChat(contactId: contactId, groupId: channelKey)
            self.contactId = nil
            self.channelKey = nil
        }
    }

    override open func viewWillDisappear(_ animated: Bool) {
        if let text = searchBar.text, !text.isEmpty {
            searchBar.text = ""
        }
        searchBar.endEditing(true)
        searchActive = false
        tableView.reloadData()
    }

    private func setupView() {

        title = localizedString(forKey: "ConversationListVCTitle", withDefaultValue: SystemMessage.ChatList.title, fileName: localizedStringFileName)

        if !configuration.hideStartChatButton {
            navigationItem.rightBarButtonItem = rightBarButtonItem
        }

        let back = localizedString(forKey: "Back", withDefaultValue: SystemMessage.ChatList.leftBarBackButton, fileName: localizedStringFileName)
        let leftBarButtonItem = UIBarButtonItem(title: back, style: .plain, target: self, action: #selector(customBackAction))

        if !configuration.hideBackButtonInConversationList {
            navigationItem.leftBarButtonItem = leftBarButtonItem
        }

        #if DEVELOPMENT
            let indicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
            indicator.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
            indicator.hidesWhenStopped = true
            indicator.stopAnimating()
            let indicatorButton = UIBarButtonItem(customView: indicator)

            navigationItem.leftBarButtonItem = indicatorButton
        #endif
        view.addViewsForAutolayout(views: [tableView])

        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true

        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.automaticallyAdjustsScrollViewInsets = false
        tableView.register(ALKChatCell.self)
        tableView.estimatedRowHeight = 0
    }

    func launchChat(contactId: String?, groupId: NSNumber?, conversationId: NSNumber? = nil) {
        let title = viewModel.titleFor(contactId: contactId, channelId: groupId)
        let conversationViewModel = viewModel.conversationViewModelOf(type: conversationViewModelType, contactId: contactId, channelId: groupId, conversationId: conversationId)

        let viewController: ALKConversationViewController!
        if conversationViewController == nil {
            viewController = ALKConversationViewController(configuration: configuration)
            viewController.title = title
            viewController.viewModel = conversationViewModel
            conversationViewController = viewController
        } else {
            viewController = conversationViewController
            viewController.title = title
            viewController.viewModel.contactId = conversationViewModel.contactId
            viewController.viewModel.channelKey = conversationViewModel.channelKey
            viewController.viewModel.conversationProxy = conversationViewModel.conversationProxy
        }
        push(conversationVC: viewController, with: conversationViewModel, title: title)
    }

    @objc func compose() {
        // Send notification outside that button is clicked
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: configuration.nsNotificationNameForNavIconClick), object: self)
        if configuration.handleNavIconClickOnConversationListView {
            return
        }
        let newChatVC = ALKNewChatViewController(configuration: configuration, viewModel: ALKNewChatViewModel(localizedStringFileName: configuration.localizedStringFileName))
        navigationController?.pushViewController(newChatVC, animated: true)
    }

    func sync(message: ALMessage) {

        if let viewController = conversationViewController, viewController.viewModel.contactId == message.contactId,viewController.viewModel.channelKey == message.groupId {
            print("Contact id matched1")
            viewController.viewModel.addMessagesToList([message])
        }
        if let dbService = dbService {
            viewModel.prepareController(dbService: dbService)
        }
    }

    //MARK: - Handle keyboard
    override func hideKeyboard()
    {
        tapToDismiss = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tapToDismiss)
    }

    override func dismissKeyboard()
    {
        searchBar.endEditing(true)
        view.endEditing(true)
    }

    @objc func customBackAction() {
        guard let nav = self.navigationController else { return }
        let dd = nav.popViewController(animated: true)
        if dd == nil {
            self.dismiss(animated: true, completion: nil)
        }
    }

    override func showAccountSuspensionView() {
        let accountVC = ALKAccountSuspensionController()
        self.present(accountVC, animated: false, completion: nil)
        accountVC.closePressed = {[weak self] in
            let popVC = self?.navigationController?.popViewController(animated: true)
            if popVC == nil {
                self?.navigationController?.dismiss(animated: true, completion: nil)
            }
        }
    }


    fileprivate func push(conversationVC: ALKConversationViewController, with viewModel: ALKConversationViewModel, title: String) {
        if let topVC = navigationController?.topViewController as? ALKConversationViewController {
            // Update the details and refresh
            topVC.title = title
            topVC.viewModel.contactId = viewModel.contactId
            topVC.viewModel.channelKey = viewModel.channelKey
            topVC.viewModel.conversationProxy = viewModel.conversationProxy
            topVC.viewWillLoadFromTappingOnNotification()
            topVC.viewModel.prepareController()
        } else {
            // push conversation VC
            conversationVC.viewWillLoadFromTappingOnNotification()
            self.navigationController?.pushViewController(conversationVC, animated: false)
        }
    }
}

extension ALKConversationListViewController: UITableViewDelegate, UITableViewDataSource {
    open func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSection()
    }

    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchActive {
            return searchFilteredChat.count
        }
        return viewModel.numberOfRowsInSection(section: section)
    }

    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {


        guard let chat = (searchActive ? searchFilteredChat[indexPath.row] as? ALMessage : viewModel.chatForRow(indexPath: indexPath)) as? ALMessage else {
            return UITableViewCell()
        }
        let cell: ALKChatCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        cell.update(viewModel: chat, identity: nil)
//        cell.setComingSoonDelegate(delegate: self.view)
        cell.chatCellDelegate = self
        return cell
    }

    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if searchActive {
            guard let chat = searchFilteredChat[indexPath.row] as? ALMessage else {return}
            delegate?.conversation(
                chat,
                willSelectItemAt: indexPath.row,
                viewController: self
            )
            let convViewModel = conversationViewModelType.init(contactId: chat.contactId, channelKey: chat.channelKey, localizedStringFileName: configuration.localizedStringFileName)
            let convService = ALConversationService()
            if let convId = chat.conversationId, let convProxy = convService.getConversationByKey(convId) {
                convViewModel.conversationProxy = convProxy
            }
            let viewController = conversationViewController ?? ALKConversationViewController(configuration: configuration)
            let chatName = chat.name.count > 0 ? chat.name : localizedString(forKey: "NoNameMessage", withDefaultValue: SystemMessage.NoData.NoName, fileName: localizedStringFileName)
            viewController.title = chat.isGroupChat ? chat.groupName:chatName
            viewController.viewModel = convViewModel
            conversationViewController = viewController
            self.navigationController?.pushViewController(viewController, animated: false)
        } else {
            guard let chat = viewModel.chatForRow(indexPath: indexPath) else { return }

            delegate?.conversation(
                chat,
                willSelectItemAt: indexPath.row,
                viewController: self
            )
            let convViewModel = conversationViewModelType.init(contactId: chat.contactId, channelKey: chat.channelKey, localizedStringFileName: configuration.localizedStringFileName)
            let convService = ALConversationService()
            if let convId = chat.conversationId, let convProxy = convService.getConversationByKey(convId) {
                convViewModel.conversationProxy = convProxy
            }
            let viewController = conversationViewController ?? ALKConversationViewController(configuration: configuration)
            viewController.title = chat.isGroupChat ? chat.groupName:chat.name
            viewController.viewModel = convViewModel
            conversationViewController = viewController
            self.navigationController?.pushViewController(viewController, animated: false)
        }
    }

    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return searchBar
    }

    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }

    open func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {

        let emptyCellView = ALKEmptyView.instanceFromNib()

        let noConversationLabelText = localizedString(forKey: "NoConversationsLabelText", withDefaultValue: SystemMessage.ChatList.NoConversationsLabelText, fileName: localizedStringFileName)
        emptyCellView.conversationLabel.text = noConversationLabelText
        emptyCellView.startNewConversationButtonIcon.isHidden = configuration.hideEmptyStateStartNewButtonInConversationList

        if !configuration.hideEmptyStateStartNewButtonInConversationList{
            if let tap = emptyCellView.gestureRecognizers?.first {
                emptyCellView.removeGestureRecognizer(tap)
            }

            let tap = UITapGestureRecognizer.init(target: self, action: #selector(compose))
            tap.numberOfTapsRequired = 1

            emptyCellView.addGestureRecognizer(tap)
        }


        return emptyCellView
    }

    open func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return viewModel.numberOfRowsInSection(section: 0) == 0 ? 325 : 0
    }

    open func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}

extension ALKConversationListViewController: UIScrollViewDelegate {
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let  height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let reloadDistance: CGFloat = 40.0 // Added this so that loading starts 40 points before the end
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset - reloadDistance
        if distanceFromBottom < height {
            viewModel.fetchMoreMessages(dbService: dbService)
        }
    }
}

//MARK: ALMessagesDelegate
extension ALKConversationListViewController: ALMessagesDelegate {
    public func getMessagesArray(_ messagesArray: NSMutableArray!) {
        guard let messages = messagesArray as? [Any] else {
            return
        }
        print("Messages loaded: \(messages)")
        viewModel.updateMessageList(messages: messages)
    }

    public func updateMessageList(_ messagesArray: NSMutableArray!) {
        print("updated message array: ", messagesArray)
    }
}

extension ALKConversationListViewController: ALKConversationListViewModelDelegate {

    open func startedLoading() {
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
            self.tableView.isUserInteractionEnabled = false
        }
    }

    open func listUpdated() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.activityIndicator.stopAnimating()
            self.tableView.isUserInteractionEnabled = true
        }
    }

    open func rowUpdatedAt(position: Int) {
        tableView.reloadRows(at: [IndexPath(row: position, section: 0)], with: .automatic)
    }
}

extension ALKConversationListViewController: ALMQTTConversationDelegate {

    open func mqttDidConnected() {
        print("MQTT did connected")
    }

    open func updateUserDetail(_ userId: String!) {
        guard let userId = userId else { return }
        print("update user detail")

        ALUserService.updateUserDetail(userId, withCompletion: {
            userDetail in
            guard let detail = userDetail else { return }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "USER_DETAIL_OTHER_VC"), object: detail)
            self.tableView.reloadData()
        })
    }

    func isNewMessageForActiveThread(alMessage: ALMessage, vm: ALKConversationViewModel) -> Bool{
        let isGroupMessage = alMessage.groupId != nil && alMessage.groupId == vm.channelKey
        let isOneToOneMessage = alMessage.groupId == nil && vm.channelKey == nil && alMessage.contactId == vm.contactId
        if ( isGroupMessage || isOneToOneMessage){
            return true
        }
        return false
    }
    
    func isMessageSentByLoggedInUser(alMessage: ALMessage) -> Bool {
        if ALUserDefaultsHandler.getUserId() == alMessage.contactId {
            return true
        }
        return false
    }


    open func syncCall(_ alMessage: ALMessage!, andMessageList messageArray: NSMutableArray!) {
        print("sync call: ", alMessage.message)
        guard let message = alMessage else { return }
        let viewController = self.navigationController?.visibleViewController  as? ALKConversationViewController
        if let vm = viewController?.viewModel, (vm.contactId != nil || vm.channelKey != nil),
            let visibleController = self.navigationController?.visibleViewController,
            visibleController.isKind(of: ALKConversationViewController.self),
            isNewMessageForActiveThread(alMessage: alMessage, vm: vm) {
                viewModel.syncCall(viewController: viewController, message: message, isChatOpen: true)

        } else if !isMessageSentByLoggedInUser(alMessage: alMessage){
            let notificationView = ALNotificationView(alMessage: message, withAlertMessage: message.message)
            notificationView?.showNativeNotificationWithcompletionHandler({
                response in
                self.launchChat(contactId: message.contactId, groupId: message.groupId, conversationId: message.conversationId)
            })
        }
        if let visibleController = self.navigationController?.visibleViewController,
            visibleController.isKind(of: ALKConversationListViewController.self) {
            sync(message: alMessage)
        }
    }

    open func delivered(_ messageKey: String!, contactId: String!, withStatus status: Int32) {
        viewModel.updateDeliveryReport(convVC: conversationViewController, messageKey: messageKey, contactId: contactId, status: status)
    }

    open func updateStatus(forContact contactId: String!, withStatus status: Int32) {
        viewModel.updateStatusReport(convVC: conversationViewController, forContact: contactId, status: status)
    }

    open func updateTypingStatus(_ applicationKey: String!, userId: String!, status: Bool) {
        print("Typing status is", status)

        guard let viewController = conversationViewController, let vm = viewController.viewModel else { return
        }
        guard (vm.contactId != nil && vm.contactId == userId) || vm.channelKey != nil else {
            return
        }
        print("Contact id matched")
        viewModel.updateTypingStatus(in: viewController, userId: userId, status: status)

    }

    open func reloadData(forUserBlockNotification userId: String!, andBlockFlag flag: Bool) {
        print("reload data")
    }

    open func updateLastSeen(atStatus alUserDetail: ALUserDetail!) {
        print("Last seen updated")
        viewModel.updateStatusFor(userDetail: alUserDetail)
    }

    open func mqttConnectionClosed() {
        NSLog("MQTT connection closed")
    }
}

extension ALKConversationListViewController: UISearchResultsUpdating,UISearchBarDelegate {

    func filterContentForSearchText(searchText: String, scope: String = "All") {
        searchFilteredChat = viewModel.getChatList().filter { (chatViewModel) -> Bool in
            guard let conversation = chatViewModel as? ALMessage else {
                return false
            }
            if conversation.isGroupChat {
                return conversation.groupName.lowercased().isCompose(of: searchText.lowercased())
            } else {
                let conversationName = conversation.name.count > 0 ? conversation.name : localizedString(forKey: "NoNameMessage", withDefaultValue: SystemMessage.NoData.NoName, fileName: localizedStringFileName)
                return conversationName.lowercased().isCompose(of: searchText.lowercased())
            }
        }
        self.tableView.reloadData()
    }

    public func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }

    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        searchFilteredChat = viewModel.getChatList().filter { (chatViewModel) -> Bool in
            guard let conversation = chatViewModel as? ALMessage else {
                return false
            }
            if conversation.isGroupChat {
                return conversation.groupName.lowercased().isCompose(of: searchText.lowercased())
            } else {
                let conversationName = conversation.name.count > 0 ? conversation.name : localizedString(forKey: "NoNameMessage", withDefaultValue: SystemMessage.NoData.NoName, fileName: localizedStringFileName)
                return conversationName.lowercased().isCompose(of: searchText.lowercased())
            }
        }
        searchActive = !searchText.isEmpty
        self.tableView.reloadData()
    }

    public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {

        hideKeyboard()

        if(searchBar.text?.isEmpty)! {
            self.tableView.reloadData()
        }
    }

    public func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {

        view.removeGestureRecognizer(tapToDismiss)

        guard let text = searchBar.text else { return }

        if text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
            if searchActive {
                searchActive = false
            }
            tableView.reloadData()
        }
    }

    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
        self.tableView.reloadData()
    }

    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.tableView.reloadData()
    }

}

extension ALKConversationListViewController: ALKChatCellDelegate {

    private func prefixAndButtonTitleForDeletePopup(conversation: ALMessage) -> (String, String){

        let deleteGroupPopupMessage = localizedString(forKey: "DeleteGroupConversation", withDefaultValue: SystemMessage.Warning.DeleteGroupConversation, fileName: localizedStringFileName)
        let leaveGroupPopupMessage = localizedString(forKey: "LeaveGroupConversation", withDefaultValue: SystemMessage.Warning.LeaveGroupConoversation, fileName: localizedStringFileName)
        let deleteSingleConversationPopupMessage = localizedString(forKey: "DeleteSingleConversation", withDefaultValue: SystemMessage.Warning.DeleteSingleConversation, fileName: localizedStringFileName)
        let removeButtonText = localizedString(forKey: "ButtonRemove", withDefaultValue: SystemMessage.ButtonName.Remove, fileName: localizedStringFileName)
        let leaveButtonText = localizedString(forKey: "ButtonLeave", withDefaultValue: SystemMessage.ButtonName.Leave, fileName: localizedStringFileName)

        let isChannelLeft = ALChannelService().isChannelLeft(conversation.groupId)

        let popupMessageForChannel = isChannelLeft ?  deleteGroupPopupMessage : leaveGroupPopupMessage
        let prefixTextForPopupMessage = conversation.isGroupChat ? popupMessageForChannel : deleteSingleConversationPopupMessage
        let buttonTitleForChannel = isChannelLeft ? removeButtonText : leaveButtonText
        let buttonTitleForPopupMessage = conversation.isGroupChat ? buttonTitleForChannel : removeButtonText

        return (prefixTextForPopupMessage, buttonTitleForPopupMessage)
    }

    private func alertMessageAndButtonTitleToUnmute(conversation: ALMessage) -> (String?, String?) {
        let unmuteButton = localizedString(forKey: "UnmuteButton", withDefaultValue: SystemMessage.Mute.UnmuteButton, fileName: localizedStringFileName)
        
        if conversation.isGroupChat, let channel = ALChannelService().getChannelByKey(conversation.groupId) {
            let unmuteChannelFormat = localizedString(forKey: "UnmuteChannel", withDefaultValue: SystemMessage.Mute.UnmuteChannel, fileName: localizedStringFileName)
            let unmuteChannelMessage = String(format: unmuteChannelFormat, channel.name)
            return (unmuteChannelMessage, unmuteButton)
        }else if let contact = ALContactService().loadContact(byKey: "userId", value: conversation.contactId) {
            let unmuteUserFormat = localizedString(forKey: "UnmuteUser", withDefaultValue: SystemMessage.Mute.UnmuteUser, fileName: localizedStringFileName)
            let unmuteUserMessage = String(format: unmuteUserFormat, contact.getDisplayName())
            return (unmuteUserMessage, unmuteButton)
        }else {
            return (nil, nil)
        }
    }

    private func sendUnmuteRequestFor(conversation: ALMessage, atIndexPath: IndexPath) {
        //Start activity indicator
        self.activityIndicator.startAnimating()

        viewModel.sendUnmuteRequestFor(conversation: conversation, withCompletion: { (success) in

            //Stop activity indicator
            self.activityIndicator.stopAnimating()

            guard success == true else {
                return
            }
            //Update UI
            if let cell = self.tableView.cellForRow(at: atIndexPath) as? ALKChatCell{
                guard let chat = self.searchActive ? self.searchFilteredChat[atIndexPath.row] as? ALMessage : self.viewModel.chatForRow(indexPath: atIndexPath) as? ALMessage else {
                    return
                }
                cell.update(viewModel: chat, identity: nil)
            }
        })
    }

    private func handleUnmuteActionFor(conversation: ALMessage, atIndexPath: IndexPath) {
        let (message, buttonTitle) = alertMessageAndButtonTitleToUnmute(conversation: conversation)
        guard message != nil && buttonTitle != nil else{
            return
        }

        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let cancelButton = UIAlertAction(title: NSLocalizedString("ButtonCancel", value: SystemMessage.ButtonName.Cancel, comment: ""), style: .cancel, handler: nil)
        let unmuteButton = UIAlertAction(title: buttonTitle, style: .destructive, handler: { [weak self] (alert) in
            guard let weakSelf = self else { return }
            weakSelf.sendUnmuteRequestFor(conversation: conversation, atIndexPath: atIndexPath)
        })
        alert.addAction(cancelButton)
        alert.addAction(unmuteButton)
        present(alert, animated: true, completion: nil)
    }


    private func popupTitleToMute(conversation: ALMessage) -> String? {
        if conversation.isGroupChat, let channel = ALChannelService().getChannelByKey(conversation.groupId) {
            let muteChannelFormat = localizedString(forKey: "MuteChannel", withDefaultValue: SystemMessage.Mute.MuteChannel, fileName: localizedStringFileName)
            return String(format: muteChannelFormat, channel.name)
        }else if let contact = ALContactService().loadContact(byKey: "userId", value: conversation.contactId) {
            let muteUserFormat = localizedString(forKey: "MuteUser", withDefaultValue: SystemMessage.Mute.MuteUser, fileName: localizedStringFileName)
            return String(format: muteUserFormat, contact.getDisplayName())
        }else {
            return nil
        }
    }

    private func handleMuteActionFor(conversation: ALMessage, atIndexPath: IndexPath) {
        guard let title = popupTitleToMute(conversation: conversation) else {
            return
        }
        let muteConversationVC = MuteConversationViewController(delegate: self, conversation: conversation, atIndexPath: atIndexPath, configuration: configuration)
        muteConversationVC.updateTitle(title)
        muteConversationVC.modalPresentationStyle = .overCurrentContext
        self.present(muteConversationVC, animated: true, completion: nil)
    }

    func chatCell(cell: ALKChatCell, action: ALKChatCellAction, viewModel: ALKChatViewModelProtocol) {

        switch action {

        case .delete:

            guard let indexPath = self.tableView.indexPath(for: cell) else {return}
//            guard let account = ChatManager.shared.currentUser else {return}

            //TODO: Add activity indicator

            if searchActive {
                guard let conversation = searchFilteredChat[indexPath.row] as? ALMessage else {return}

                let(prefixText, buttonTitle) = prefixAndButtonTitleForDeletePopup(conversation: conversation)
                let conversationName = conversation.name.count > 0 ? conversation.name : localizedString(forKey: "NoNameMessage", withDefaultValue: SystemMessage.NoData.NoName, fileName: localizedStringFileName)
                let name = conversation.isGroupChat ? conversation.groupName : conversationName
                let text = "\(prefixText) \(name)?"
                let alert = UIAlertController(title: nil, message: text, preferredStyle: .alert)

                let cancelButton = UIAlertAction(title: localizedString(forKey: "ButtonCancel", withDefaultValue: SystemMessage.ButtonName.Cancel, fileName: localizedStringFileName), style: .cancel, handler: nil)
                let deleteButton = UIAlertAction(title: buttonTitle, style: .destructive, handler: { [weak self] (alert) in
                    guard let weakSelf = self, ALDataNetworkConnection.checkDataNetworkAvailable() else { return }

                    if conversation.isGroupChat {
                        let channelService = ALChannelService()
                        if  channelService.isChannelLeft(conversation.groupId) {
                            weakSelf.dbService.deleteAllMessages(byContact: nil, orChannelKey: conversation.groupId)
                            ALChannelService.setUnreadCountZeroForGroupID(conversation.groupId)
                            weakSelf.searchFilteredChat.remove(at: indexPath.row)
                            weakSelf.viewModel.remove(message: conversation)
                            weakSelf.tableView.reloadData()
                        } else if ALChannelService.isChannelDeleted(conversation.groupId) {
                            let channelDbService = ALChannelDBService()
                            channelDbService.deleteChannel(conversation.groupId)
                            weakSelf.searchFilteredChat.remove(at: indexPath.row)
                            weakSelf.viewModel.remove(message: conversation)
                            weakSelf.tableView.reloadData()
                        } else {
                            channelService.leaveChannel(conversation.groupId, andUserId: ALUserDefaultsHandler.getUserId(), orClientChannelKey: nil, withCompletion: {
                                error in
                                ALMessageService.deleteMessageThread(nil, orChannelKey: conversation.groupId, withCompletion: {
                                    _,error in
                                    guard error == nil else { return }
                                    weakSelf.tableView.reloadData()
                                    return
                                })
                            })
                        }
                    } else {
                        ALMessageService.deleteMessageThread(conversation.contactIds, orChannelKey: nil, withCompletion: {
                            _,error in
                            guard error == nil else { return }
                            weakSelf.viewModel.remove(message: conversation)
                            weakSelf.tableView.reloadData()
                        })
                    }
                })
                alert.addAction(cancelButton)
                alert.addAction(deleteButton)
                present(alert, animated: true, completion: nil)
            }
            else if let _ = self.viewModel.chatForRow(indexPath: indexPath), let conversation = self.viewModel.getChatList()[indexPath.row] as? ALMessage {
                let(prefixText, buttonTitle) = prefixAndButtonTitleForDeletePopup(conversation: conversation)

                let name = conversation.isGroupChat ? conversation.groupName : conversation.name
                let text = "\(prefixText) \(name)?"
                let alert = UIAlertController(title: nil, message: text, preferredStyle: .alert)
                let cancelButton = UIAlertAction(title: localizedString(forKey: "ButtonCancel", withDefaultValue: SystemMessage.ButtonName.Cancel, fileName: localizedStringFileName), style: .cancel, handler: nil)
                let deleteButton = UIAlertAction(title: buttonTitle, style: .destructive, handler: { [weak self] (alert) in
                    guard let weakSelf = self else { return }
                    if conversation.isGroupChat {
                        let channelService = ALChannelService()
                        if  channelService.isChannelLeft(conversation.groupId) {
                            weakSelf.dbService.deleteAllMessages(byContact: nil, orChannelKey: conversation.groupId)
                            ALChannelService.setUnreadCountZeroForGroupID(conversation.groupId)
                            weakSelf.viewModel.remove(message: conversation)
                            weakSelf.tableView.reloadData()
                        } else if ALChannelService.isChannelDeleted(conversation.groupId) {
                            let channelDbService = ALChannelDBService()
                            channelDbService.deleteChannel(conversation.groupId)
                            weakSelf.viewModel.remove(message: conversation)
                            weakSelf.tableView.reloadData()
                        } else {
                            channelService.leaveChannel(conversation.groupId, andUserId: ALUserDefaultsHandler.getUserId(), orClientChannelKey: nil, withCompletion: {
                                error in
                                ALMessageService.deleteMessageThread(nil, orChannelKey: conversation.groupId, withCompletion: {
                                    _,error in
                                    guard error == nil else { return }
                                    weakSelf.tableView.reloadData()
                                    return
                                })
                            })
                        }
                    } else {
                        ALMessageService.deleteMessageThread(conversation.contactIds, orChannelKey: nil, withCompletion: {
                            _,error in
                            guard error == nil else { return }
                            weakSelf.viewModel.remove(message: conversation)
                            weakSelf.tableView.reloadData()
                        })
                    }
                })
                alert.addAction(cancelButton)
                alert.addAction(deleteButton)
                present(alert, animated: true, completion: nil)

            }
            break

        case .mute:
            guard let indexPath = self.tableView.indexPath(for: cell) else {
                return
            }

            if searchActive {
                guard let conversation = searchFilteredChat[indexPath.row] as? ALMessage else {
                    return
                }
                self.handleMuteActionFor(conversation: conversation, atIndexPath: indexPath)
            }else if let _ = self.viewModel.chatForRow(indexPath: indexPath), let conversation = self.viewModel.getChatList()[indexPath.row] as? ALMessage {
                self.handleMuteActionFor(conversation: conversation, atIndexPath: indexPath)
            }

        case .unmute:
            guard let indexPath = self.tableView.indexPath(for: cell) else {
                return
            }
            if searchActive {
                guard let conversation = searchFilteredChat[indexPath.row] as? ALMessage else {
                    return
                }
                self.handleUnmuteActionFor(conversation: conversation, atIndexPath: indexPath)
            }else if let _ = self.viewModel.chatForRow(indexPath: indexPath), let conversation = self.viewModel.getChatList()[indexPath.row] as? ALMessage {
                self.handleUnmuteActionFor(conversation: conversation, atIndexPath: indexPath)
            }


        default:
            print("not present")
        }
    }
}

extension ALKConversationListViewController: Muteable {
    @objc func mute(conversation: ALMessage, forTime: Int64, atIndexPath: IndexPath) {
        //Start activity indicator
        self.activityIndicator.startAnimating()

        let time = (Int64(Date().timeIntervalSince1970) * 1000) + forTime

        self.viewModel.sendMuteRequestFor(conversation: conversation, tillTime: NSNumber(value: time)) { (success) in

            //Stop activity indicator
            self.activityIndicator.stopAnimating()

            //Update indexPath
            guard success == true else {
                return
            }
            if let cell = self.tableView.cellForRow(at: atIndexPath) as? ALKChatCell{
                guard let chat = self.searchActive ? self.searchFilteredChat[atIndexPath.row] as? ALMessage : self.viewModel.chatForRow(indexPath: atIndexPath) as? ALMessage else {
                    return
                }
                cell.update(viewModel: chat, identity: nil)
            }
        }
    }
}
