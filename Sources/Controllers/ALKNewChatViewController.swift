//
//  ALKNewChatViewController.swift
//  
//
//  Created by Mukesh Thawani on 04/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import UIKit
import Applozic

final public class ALKNewChatViewController: ALKBaseViewController, Localizable {

    fileprivate var viewModel: ALKNewChatViewModel!
    
    fileprivate let tableView : UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.estimatedRowHeight   = 53
        tv.rowHeight            = 53
        tv.separatorStyle       = .none
        tv.backgroundColor      = UIColor.white
        tv.keyboardDismissMode  = .onDrag
        return tv
    }()
    
    fileprivate lazy var searchBar: UISearchBar = {
        return UISearchBar.createAXSearchBar(placeholder: localizedString(forKey: "SearchPlaceholder", withDefaultValue: SystemMessage.LabelName.SearchPlaceholder, fileName: configuration.localizedStringFileName))
    }()

    fileprivate let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
    
    //MARK: - Life cycle
    
    public convenience init(configuration: ALKConfiguration, viewModel: ALKNewChatViewModel) {
        self.init(configuration: configuration)
        self.viewModel = viewModel
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    required public init(configuration: ALKConfiguration) {
        super.init(configuration: configuration)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        ALUserDefaultsHandler.setContactServerCallIsDone(false)
        if let textField = searchBar.textField {
            guard UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft else { return }
            textField.textAlignment = .right
        }
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.edgesForExtendedLayout = []
        activityIndicator.center = CGPoint(x: view.bounds.size.width/2, y: view.bounds.size.height/2)
        activityIndicator.color = UIColor.gray
        view.addSubview(activityIndicator)
        self.view.bringSubviewToFront(activityIndicator)
        activityIndicator.startAnimating()
        viewModel.getContacts(completion: {
            self.searchBar.text = nil
            self.tableView.reloadData()
            self.activityIndicator.stopAnimating()
        })
    }
    
    //MARK: - Private
    
    private func setupView() {

        title = localizedString(forKey: "NewChatTitle", withDefaultValue: SystemMessage.LabelName.NewChatTitle, fileName: configuration.localizedStringFileName)
        
        view.addViewsForAutolayout(views: [tableView])
        
        setupTableViewConstraint()
        
        // Setup table view datasource/delegate
        tableView.delegate              = self
        tableView.dataSource            = self
        tableView.contentInset          = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        registerCell()
    }
    
    private func setupTableViewConstraint() {
        // Setup table view constraint
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    private func registerCell() {
        tableView.register(ALKFriendNewChatCell.self)
    }
}


//MARK: -  UITableViewDelegate, UITableViewDataSource
extension ALKNewChatViewController: UITableViewDelegate, UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSection()
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section == 0) ? 1 : viewModel.numberOfRowsInSection(section: section)
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let friendViewModel = (indexPath.section == 0) ? viewModel.createGroupCell() : viewModel.friendForRow(indexPath: indexPath)
        let cell: ALKFriendNewChatCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        cell.update(friend: friendViewModel)
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if indexPath.section == 0 {
            
            tableView.deselectRow(at: indexPath, animated: true)
            
            let storyboard = UIStoryboard.name(storyboard: UIStoryboard.Storyboard.createGroupChat, bundle: Bundle.applozic)
            if let vc = storyboard.instantiateViewController(withIdentifier: "ALKCreateGroupViewController") as? ALKCreateGroupViewController {
                vc.setCurrentGroupSelected(groupId: NSNumber(value: 0), groupProfile: nil, delegate: self)
                vc.addContactMode = .newChat
                vc.configuration = configuration
                navigationController?.pushViewController(vc, animated: true)
            }
            return
        }


        let friendViewModel = self.viewModel.friendForRow(indexPath: indexPath)


        tableView.deselectRow(at: indexPath, animated: true)

        tableView.isUserInteractionEnabled = false

        let viewModel = ALKConversationViewModel(contactId: friendViewModel.friendUUID, channelKey: nil, localizedStringFileName: configuration.localizedStringFileName)

        let conversationVC = ALKConversationViewController(configuration: configuration)
        conversationVC.viewModel = viewModel
            
        self.tableView.deselectRow(at: indexPath, animated: true)
        self.navigationController?.pushViewController(conversationVC, animated: true)
        self.tableView.isUserInteractionEnabled = true

    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return (section == 0) ? searchBar : nil
    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return (section == 0) ? 44 : 0
    }

}

extension ALKNewChatViewController: UIScrollViewDelegate {
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // Update only when the search is not active
        guard (searchBar.text?.isEmpty)! else { return }

        if(!ALApplozicSettings.isContactsGroupEnabled()){
            let  height = scrollView.frame.size.height
            let contentYoffset = scrollView.contentOffset.y
            let reloadDistance: CGFloat = 40.0 // Added this so that loading starts 40 points before the end
            let distanceFromBottom = scrollView.contentSize.height - contentYoffset - reloadDistance
            if distanceFromBottom < height {
                activityIndicator.startAnimating()
                viewModel.getContacts(completion: {
                    self.searchBar.text = nil
                    self.tableView.reloadData()
                    ALUserDefaultsHandler.setContactServerCallIsDone(true)
                    self.activityIndicator.stopAnimating()
                })
            }
        }
    }
}



//MARK: - UISearchBarDelegate
extension ALKNewChatViewController: UISearchBarDelegate {
    
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.filter(keyword: searchText)
        tableView.reloadData()
    }
}


//MARK: - CreateGroupChatAddFriendProtocol
extension ALKNewChatViewController: ALKCreateGroupChatAddFriendProtocol {
    
    func createGroupGetFriendInGroupList(friendsSelected: [ALKFriendViewModel], groupName: String, groupImgUrl: String, friendsAdded: [ALKFriendViewModel]) {

        guard ALDataNetworkConnection.checkDataNetworkAvailable() else { return }

        //Server call

        let newChannel = ALChannelService()
        let membersList = NSMutableArray()
        let _ = friendsSelected.map { membersList.add($0.friendUUID as Any) }

        newChannel.createChannel(groupName, orClientChannelKey: nil, andMembersList: membersList, andImageLink: groupImgUrl, withCompletion: {
            channel, error in
            guard let alChannel = channel else {
                print("error creating group", error.debugDescription)
                return
            }
            print("group created")
            let message = ALMessage()
            message.groupId = alChannel.key
            let list = NSMutableArray(object: message)
            NotificationCenter.default.post(name: Notification.Name(rawValue: "reloadTable"), object: list)

            let viewModel = ALKConversationViewModel(contactId: nil, channelKey: alChannel.key, localizedStringFileName: self.configuration.localizedStringFileName)
            let conversationVC = ALKConversationViewController(configuration: self.configuration)
            conversationVC.viewModel = viewModel
            self.navigationController?.pushViewController(conversationVC, animated: true)
            self.tableView.isUserInteractionEnabled = true
        })
    }

}
