//
//  ConversationListTableViewController.swift
//  ApplozicSwift
//
//  Created by Shivam Pokhriyal on 29/11/18.
//

import Foundation
import Applozic

/**
 A delegate used to notify the receiver of the click events in `ConversationListTableViewController`
 */
protocol ConversationListTableViewDelegate {
    
    /// Tells the delegate which chat cell is tapped alongwith the position.
    func tapped(_ chat: ALKChatViewModelProtocol, at index: Int)
    
    /// Tells the delegate empty list cell is tapped.
    func emptyChatCellTapped()
}

/**
 The **ConversationListTableViewController** manages rendering of chat cells using the viewModel supplied to it. It also contains delegate to send callbacks when a cell is tapped.
 
 It uses ALKChatCell and EmptyChatCell as tableview cell and handles the swipe interaction of user with the chat cell.
 */
public class ConversationListTableViewController: UITableViewController, Localizable {
    
    var viewModel: ConversationListViewModelProtocol
    var configuration: ALKConfiguration
    var localizedStringFileName: String
    var tapToDismiss: UITapGestureRecognizer!
    var dbService: ALMessageDBService!
    var delegate: ConversationListTableViewDelegate
    lazy var dataSource = ConversationListTableViewDataSource(viewModel: self.viewModel, cellConfigurator: { (message, tableCell) in
        let cell = tableCell as! ALKChatCell
        cell.update(viewModel: message, identity: nil)
        cell.chatCellDelegate = self
    })
    
    fileprivate let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    fileprivate let searchController = UISearchController(searchResultsController: nil)
    fileprivate var searchActive : Bool = false
    fileprivate var searchFilteredChat:[Any] = []
    fileprivate lazy var searchBar: UISearchBar = {
        var bar = UISearchBar()
        bar.autocapitalizationType = .sentences
        return bar
    }()
    
    /**
     Creates a ConversationListTableViewController object.
     
     - Parameters:
        - viewModel: A view model containing the message list to be rendered. It must conform to `ConversationListViewModelProtocol`
        - dbService: `ALMessageDBService` object. Ensure that this object confirms to `ALMessageDBDelegate`
        - configuration: A configuration to be used by this controller to configure different settings.
        - delegate: A delegate used to receive callbacks when chat cell is tapped.
     */
    init(viewModel: ConversationListViewModelProtocol, dbService: ALMessageDBService, configuration: ALKConfiguration, delegate: ConversationListTableViewDelegate) {
        self.viewModel = viewModel
        self.configuration = configuration
        self.localizedStringFileName = configuration.localizedStringFileName
        self.dbService = dbService
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - VIEW LIFE CYCLE
    override public func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        self.tableView.delegate = self
        self.tableView.dataSource = self
        tableView.register(ALKChatCell.self, forCellReuseIdentifier: "cell")
        
        let nib = UINib(nibName: "EmptyChatCell", bundle: Bundle.applozic)
        tableView.register(nib, forCellReuseIdentifier: "EmptyChatCell")
        tableView.estimatedRowHeight = 0
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        if let text = searchBar.text, !text.isEmpty {
            searchBar.text = ""
        }
        searchBar.endEditing(true)
        searchActive = false
        tableView.reloadData()
    }

    //MARK: - TABLE VIEW DATA SOURCE METHODS
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.numberOfSections(in: tableView)
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchActive {
            return searchFilteredChat.count
        }
        return dataSource.tableView(tableView, numberOfRowsInSection: section)
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if searchActive {
            guard let chat = searchFilteredChat[indexPath.row] as? ALMessage else {
                return UITableViewCell()
            }
            let cell: ALKChatCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ALKChatCell
            cell.update(viewModel: chat, identity: nil)
            cell.chatCellDelegate = self
            return cell
        }
        return dataSource.tableView(tableView, cellForRowAt: indexPath)
    }
    
    public override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //MARK: - TABLE VIEW DELEGATE METHODS
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searchActive {
            guard let message = searchFilteredChat[indexPath.row] as? ALMessage else {
                return
            }
            delegate.tapped(message, at: indexPath.row)
        } else {
            guard let message = viewModel.chatForRow(indexPath: indexPath) else {
                return
            }
            delegate.tapped(message, at: indexPath.row)
        }
    }
    
    public override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return searchBar
    }
    
    public override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    public override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableCell(withIdentifier: "EmptyChatCell")?.contentView
        if let tap = view?.gestureRecognizers?.first {
            view?.removeGestureRecognizer(tap)
        }
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(compose))
        tap.numberOfTapsRequired = 1
        view?.addGestureRecognizer(tap)
        return view
    }
    
    public override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return viewModel.numberOfRowsInSection(section: 0) == 0 ? 325 : 0
    }

    //MARK: - HANDLE KEYBOARD
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

    @objc func compose() {
        delegate.emptyChatCellTapped()
    }
    
    //MARK: - PRIVATE METHODS
    private func setupView() {
        self.tableView.estimatedRowHeight = 75
        self.tableView.rowHeight = 75
        self.tableView.separatorStyle = .none
        self.tableView.backgroundColor = UIColor.white
        self.tableView.keyboardDismissMode = .onDrag
        self.tableView.accessibilityIdentifier = "OuterChatScreenTableView"
    }
    
}

//MARK: - SEARCH BAR DELEGATE
extension ConversationListTableViewController: UISearchResultsUpdating, UISearchBarDelegate {
    
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

//MARK: - ALKChatCell DELEGATE
extension ConversationListTableViewController: ALKChatCellDelegate {
    
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
    
}

// MARK: - MUTE DELEGATE
extension ConversationListTableViewController: Muteable {
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

//MARK: - SCROLL VIEW DELEGATE
extension ConversationListTableViewController {
    override public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let reloadDistance: CGFloat = 40.0 // Added this so that loading starts 40 points before the end
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset - reloadDistance
        if distanceFromBottom < height {
            viewModel.fetchMoreMessages(dbService: dbService)
        }
    }
}
