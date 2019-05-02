
//  ConversationViewController.swift
//
//
//  Created by Mukesh Thawani on 04/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Applozic
import SafariServices

open class ALKConversationViewController: ALKBaseViewController, Localizable {

    var timerTask = Timer();

    public var viewModel: ALKConversationViewModel! {
        willSet(updatedVM) {
            guard viewModel != nil else {return}
            if updatedVM.contactId == viewModel.contactId && updatedVM.channelKey == viewModel.channelKey && updatedVM.conversationProxy == viewModel.conversationProxy{
                self.isFirstTime = false
            } else {
                self.isFirstTime = true
            }
        }
    }

    /// Make this false if you want to use custom list view controller
    public var individualLaunch = true

    public lazy var chatBar = ALKChatBar(frame: CGRect.zero, configuration: self.configuration)

    public let autocompletionView: UITableView = {
        let tableview = UITableView(frame: CGRect.zero, style: .plain)
        tableview.backgroundColor = .white
        tableview.estimatedRowHeight = 50
        tableview.rowHeight = UITableView.automaticDimension
        tableview.separatorStyle = .none
        return tableview
    }()

    var contactService: ALContactService!

    lazy var loadingIndicator = ALKLoadingIndicator(frame: .zero, color: self.configuration.navigationBarTitleColor)

    /// Check if view is loaded from notification
    private var isViewLoadedFromTappingOnNotification: Bool = false

    /// See configuration.
    private var isGroupDetailActionEnabled = true

    /// See configuration.
    private var isProfileTapActionEnabled = true

    private var isFirstTime = true
    private var bottomConstraint: NSLayoutConstraint?
    private var leftMoreBarConstraint: NSLayoutConstraint?
    private var typingNoticeViewHeighConstaint: NSLayoutConstraint?
    var isJustSent: Bool = false

    //MQTT connection retry
    fileprivate var mqttRetryCount = 0
    fileprivate var maxMqttRetryCount = 3

    fileprivate let audioPlayer = ALKAudioPlayer()

    fileprivate let moreBar: ALKMoreBar = ALKMoreBar(frame: .zero)
    fileprivate lazy var typingNoticeView = TypingNotice(localizedStringFileName : configuration.localizedStringFileName)
    fileprivate var alMqttConversationService: ALMQTTConversationService!
    fileprivate let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)

    fileprivate lazy var navigationBar = ALKConversationNavBar(configuration: self.configuration, delegate: self)

    fileprivate var keyboardSize: CGRect?

    fileprivate var localizedStringFileName: String!
    fileprivate var profanityFilter: ProfanityFilter?

    fileprivate enum ActionType: String {
        case link = "link"
        case quickReply = "quick_reply"
    }

    fileprivate enum CardTemplateActionType: String {
        case link = "link"
        case submit = "submit"
        case quickReply = "quickReply"
    }

    fileprivate enum ConstraintIdentifier {
        static let contextTitleView = "contextTitleView"
        static let replyMessageViewHeight = "replyMessageViewHeight"
    }

    fileprivate enum Padding {

        enum ContextView {
            static let height: CGFloat = 100.0
        }
        enum ReplyMessageView {
            static let height: CGFloat = 70.0
        }
    }

    let cardTemplateMargin: CGFloat = 150

      var tableView : UITableView = {
        let tv = UITableView(frame: .zero, style: .grouped)
        tv.separatorStyle   = .none
        tv.allowsSelection  = false
        tv.clipsToBounds    = true
        tv.keyboardDismissMode = UIScrollView.KeyboardDismissMode.onDrag
        tv.accessibilityIdentifier = "InnerChatScreenTableView"
        tv.backgroundColor = UIColor.clear
        return tv
    }()

    let unreadScrollButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.lightText
        let image = UIImage(named: "scrollDown", in: Bundle.applozic, compatibleWith: nil)
        button.setImage(image, for: .normal)
        button.layer.cornerRadius = 15
        return button
    }()

    open var backgroundView: UIView = {
        let view = UIView(frame: CGRect.zero)
        view.backgroundColor = UIColor.white
        return view
    }()

    open var contextTitleView: ALKContextTitleView = {
        let contextView = ALKContextTitleView(frame: CGRect.zero)
        contextView.backgroundColor = UIColor.orange
        return contextView
    }()

    open var templateView: ALKTemplateMessagesView?

    lazy open var replyMessageView: ALKReplyMessageView = {
        let view = ALKReplyMessageView(frame: CGRect.zero, configuration: configuration)
        view.backgroundColor = UIColor.gray
        return view
    }()

    var contentOffsetDictionary: Dictionary<AnyHashable,AnyObject>!

    var contentHeights = Dictionary<String,CGFloat>()

    required public init(configuration: ALKConfiguration) {
        super.init(configuration: configuration)
        self.localizedStringFileName = configuration.localizedStringFileName
        self.contactService = ALContactService()
        configurePropertiesWith(configuration: configuration)
        self.chatBar.configuration = configuration
        self.typingNoticeView = TypingNotice(localizedStringFileName: configuration.localizedStringFileName)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public func viewWillLoadFromTappingOnNotification(){
        isViewLoadedFromTappingOnNotification = true
    }

    override func addObserver() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: nil, using: { [weak self]
            notification in
            print("keyboard will show")

            let keyboardFrameValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey]
            guard
                let weakSelf = self,
                weakSelf.chatBar.isTextViewFirstResponder,
                let keyboardSize = (keyboardFrameValue as? NSValue)?.cgRectValue else {
                    return
            }

            weakSelf.keyboardSize = keyboardSize

            let tableView = weakSelf.tableView

            var h = CGFloat(0)
            h = keyboardSize.height-h

            let newH = -1*h
            if weakSelf.bottomConstraint?.constant == newH {return}

            weakSelf.bottomConstraint?.constant = newH

            weakSelf.view?.layoutIfNeeded()

            if tableView.isCellVisible(section: weakSelf.viewModel.messageModels.count-1, row: 0) {
                tableView.scrollToBottomByOfset(animated: false)
            } else if weakSelf.viewModel.messageModels.count > 1 {
                weakSelf.unreadScrollButton.isHidden = false
            }
        })


        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil, using: {[weak self]
            (notification) in

            guard let weakSelf = self else {return}
            let view = weakSelf.view

            weakSelf.bottomConstraint?.constant = 0

            let duration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.05

            UIView.animate(withDuration: duration, animations: {
                view?.layoutIfNeeded()
            }, completion: { (_) in
                guard let vm = weakSelf.viewModel else { return }
                vm.sendKeyboardDoneTyping()
            })

        })

        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "newMessageNotification"), object: nil, queue: nil, using: { [weak self]
            notification in
            guard let weakSelf = self, weakSelf.viewModel != nil else { return }
            let msgArray = notification.object as? [ALMessage]
            print("new notification received: ", msgArray?.first?.message as Any, msgArray?.count ?? "")
            guard let list = notification.object as? [Any], !list.isEmpty, weakSelf.isViewLoaded else { return }
            weakSelf.viewModel.addMessagesToList(list)
//            weakSelf.handlePushNotification = false
        })

        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "notificationIndividualChat"), object: nil, queue: nil, using: {[weak self]
            notification in
            print("notification individual chat received")
        })

        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "report_DELIVERED"), object: nil, queue: nil, using: {[weak self]
            notification in
            guard
                let weakSelf = self,
                weakSelf.viewModel != nil,
                let key = notification.object as? String
                else { return }
            weakSelf.viewModel.updateDeliveryReport(messageKey: key, status: Int32(DELIVERED.rawValue))
            print("report delievered notification received")
        })

        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "report_DELIVERED_READ"), object: nil, queue: nil, using: {[weak self]
            notification in
            guard
                let weakSelf = self,
                weakSelf.viewModel != nil,
                let key = notification.object as? String
                else { return }
            weakSelf.viewModel.updateDeliveryReport(messageKey: key, status: Int32(DELIVERED_AND_READ.rawValue))
            print("report delievered and read notification received")
        })

        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "report_CONVERSATION_DELIVERED_READ"), object: nil, queue: nil, using: {[weak self]
            notification in
            guard
                let weakSelf = self,
                weakSelf.viewModel != nil,
                let key = notification.object as? String
                else { return }
            weakSelf.viewModel.updateStatusReportForConversation(contactId: key, status: Int32(DELIVERED_AND_READ.rawValue))
            print("report conversation delievered and read notification received")
        })

        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "UPDATE_MESSAGE_SEND_STATUS"), object: nil, queue: nil, using: {[weak self]
            notification in
            print("Message sent notification received")
            guard
                let weakSelf = self,
                weakSelf.viewModel != nil,
                let message = notification.object as? ALMessage
                else { return }
            weakSelf.viewModel.updateSendStatus(message: message)
        })

        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "USER_DETAILS_UPDATE_CALL"), object: nil, queue: nil, using: {[weak self] notification in
            NSLog("update user detail notification received")
            guard
                let weakSelf = self,
                weakSelf.viewModel != nil,
                let userId = notification.object as? String
                else { return }
            weakSelf.updateUserDetail(userId)
        })

        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "UPDATE_CHANNEL_NAME"), object: nil, queue: nil, using: {[weak self] notification in
            NSLog("update group name notification received")
            guard let weakSelf = self, weakSelf.viewModel != nil else { return }
            print("update group detail")
            guard weakSelf.viewModel.isGroup else { return }
            let alChannelService = ALChannelService()
            guard let key = weakSelf.viewModel.channelKey, let channel = alChannelService.getChannelByKey(key), let name = channel.name else { return }
            let profile = weakSelf.viewModel.conversationProfileFrom(contact: nil, channel: channel, conversation: nil)
            weakSelf.navigationBar.updateView(profile: profile)
            weakSelf.newMessagesAdded()
        })

        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "APP_ENTER_IN_FOREGROUND"), object: nil, queue: nil) { [weak self] notification in
            guard let weakSelf = self, weakSelf.viewModel != nil else { return }
            let profile = weakSelf.viewModel.currentConversationProfile(completion: { (profile) in
                guard let profile = profile else { return }
                weakSelf.navigationBar.updateView(profile: profile)
            })

        }
    }

    override func removeObserver() {

        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "newMessageNotification"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "notificationIndividualChat"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "report_DELIVERED"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "report_DELIVERED_READ"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "report_CONVERSATION_DELIVERED_READ"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "UPDATE_MESSAGE_SEND_STATUS"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "USER_DETAILS_UPDATE_CALL"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "UPDATE_CHANNEL_NAME"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "APP_ENTER_IN_FOREGROUND"), object: nil)
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft {
            tableView.semanticContentAttribute = UISemanticContentAttribute.forceRightToLeft
        }
        self.edgesForExtendedLayout = []
        activityIndicator.center = CGPoint(x: view.bounds.size.width/2, y: view.bounds.size.height/2)
        activityIndicator.color = UIColor.lightGray
        tableView.addSubview(activityIndicator)
        addRefreshButton()
        if let listVC = self.navigationController?.viewControllers.first as? ALKConversationListViewController, listVC.isViewLoaded, individualLaunch  {
            individualLaunch = false
        }
        alMqttConversationService = ALMQTTConversationService.sharedInstance()
        if individualLaunch {
            alMqttConversationService.mqttConversationDelegate = self
            alMqttConversationService.subscribeToConversation()
        }

        if self.viewModel.isGroup == true {
            let dispName = localizedString(forKey: "Somebody", withDefaultValue: SystemMessage.Chat.somebody, fileName: localizedStringFileName)
            self.setTypingNoticeDisplayName(displayName: dispName)
        } else {
            self.setTypingNoticeDisplayName(displayName: self.title ?? "")
        }

        viewModel.delegate = self
        self.refreshViewController()

        if let templates = viewModel.getMessageTemplates(){
            templateView = ALKTemplateMessagesView(frame: CGRect.zero, viewModel: ALKTemplateMessagesViewModel(messageTemplates: templates))
        }
        templateView?.messageSelected = { [weak self] template in
            self?.viewModel.selected(template: template,metadata: self?.configuration.messageMetadata)
        }
        if self.isFirstTime {
            setupView()
        } else {
            tableView.reloadData()
        }
        contentOffsetDictionary = Dictionary<NSObject,AnyObject>()
        print("id: ", viewModel.messageModels.first?.contactId as Any)
    }

    override open func viewDidAppear(_ animated: Bool) {
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        autocompletionView.contentInset = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
        chatBar.setup(autocompletionView, withPrefex: "/")

        guard !configuration.restrictedWordsFileName.isEmpty else {
            return
        }
        do {
            profanityFilter = try ProfanityFilter(
            fileName: configuration.restrictedWordsFileName)
        } catch {
            print("Error while loading restricted words file:", error)
        }
    }

    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if self.isFirstTime && tableView.isCellVisible(section: 0, row: 0) {
            self.tableView.scrollToBottomByOfset(animated: false)
            isFirstTime = false
        }
    }

    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAudioPlayer()
        chatBar.stopRecording()
        contentHeights = [:]
        if individualLaunch {
            if let _ = alMqttConversationService {
                alMqttConversationService.unsubscribeToConversation()
            }
        }
        unsubscribingChannel()
    }

    override func backTapped() {
        print("back tapped")
        view.endEditing(true)
        self.viewModel.sendKeyboardDoneTyping()
        let popVC = navigationController?.popToRootViewController(animated: true)
        if popVC == nil {
            self.dismiss(animated: true, completion: nil)
        }
    }

    override func showAccountSuspensionView() {
        let accountVC = ALKAccountSuspensionController()
        self.present(accountVC, animated: false, completion: nil)
        accountVC.closePressed = {[weak self] in
            _ = self?.navigationController?.popToRootViewController(animated: true)
        }
    }

    func setupView() {

        unreadScrollButton.isHidden = true
        unreadScrollButton.addTarget(self, action: #selector(unreadScrollDownAction(_:)), for: .touchUpInside)

        backgroundView.backgroundColor = configuration.backgroundColor
        prepareTable()
        prepareMoreBar()
        prepareChatBar()
        replyMessageView.closeButtonTapped = {[weak self] _ in
            self?.hideReplyMessageView()
        }
    }

    func checkUserBlock() {
        guard !viewModel.isGroup, let contactId = viewModel.contactId else { return }
        ALUserService().getUserDetail(contactId) { (contact) in
            guard let contact = contact, contact.block else {
                self.chatBar.enableChat()
                return
            }
            self.chatBar.disableChat(message: self.localizedString(forKey: "UnblockToEnableChat", withDefaultValue: SystemMessage.Information.UnblockToEnableChat, fileName: self.configuration.localizedStringFileName))
        }
    }

    func isChannelLeft() {
        guard let channelKey = viewModel.channelKey, let channel = ALChannelService().getChannelByKey(channelKey) else {
            return
        }
        //TODO: This returns nil sometimes. Find a better way.
        guard let members = ALChannelService().getListOfAllUsers(inChannel: channelKey) as? [String] else {
            return
        }
        if  channel.type != 6 && channel.type != 10 && !members.contains(ALUserDefaultsHandler.getUserId()) {
            chatBar.disableChat(message: localizedString(forKey: "NotPartOfGroup", withDefaultValue: SystemMessage.Information.NotPartOfGroup, fileName: configuration.localizedStringFileName))
            //Disable click on toolbar
            navigationBar.disableTitleAction = true
        } else {
            chatBar.enableChat()
            //Enable Click on toolbar
            navigationBar.disableTitleAction = false
        }
    }

    func prepareContextView(){
        guard viewModel.isContextBasedChat else {
            toggleVisibilityOfContextTitleView(false)
            return
        }
        guard let topicDetail = viewModel.getContextTitleData() else {return }
        contextTitleView.configureWith(value: topicDetail)
        toggleVisibilityOfContextTitleView(true)
    }

    private func toggleVisibilityOfContextTitleView(_ show: Bool) {
        let height: CGFloat = show ? Padding.ContextView.height : 0
        contextTitleView.constraint(
            withIdentifier: ConstraintIdentifier.contextTitleView)?
            .constant = height
    }

    private func setupConstraints() {

        var allViews = [backgroundView, contextTitleView, tableView, autocompletionView, moreBar, chatBar, typingNoticeView, unreadScrollButton, replyMessageView]
        if let templateView = templateView {
            allViews.append(templateView)
        }
        view.addViewsForAutolayout(views: allViews)

        backgroundView.topAnchor.constraint(equalTo: contextTitleView.bottomAnchor).isActive = true
        backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        backgroundView.bottomAnchor.constraint(equalTo: chatBar.topAnchor).isActive = true

        contextTitleView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        contextTitleView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        contextTitleView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        contextTitleView.heightAnchor.constraintEqualToAnchor(constant: 0, identifier: ConstraintIdentifier.contextTitleView).isActive = true

        templateView?.bottomAnchor.constraint(equalTo: typingNoticeView.topAnchor, constant: -5.0).isActive = true
        templateView?.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5.0).isActive = true
        templateView?.widthAnchor.constraint(equalTo: self.view.widthAnchor, constant: -10.0).isActive = true
        templateView?.heightAnchor.constraint(equalToConstant: 45).isActive = true

        tableView.topAnchor.constraint(equalTo: contextTitleView.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: (templateView != nil) ? templateView!.topAnchor:typingNoticeView.topAnchor).isActive = true

        autocompletionView.bottomAnchor
            .constraint(equalTo: typingNoticeView.topAnchor).isActive = true
        autocompletionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        autocompletionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true

        typingNoticeViewHeighConstaint = typingNoticeView.heightAnchor.constraint(equalToConstant: 0)
        typingNoticeViewHeighConstaint?.isActive = true

        typingNoticeView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8).isActive = true
        typingNoticeView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12).isActive = true
        typingNoticeView.bottomAnchor.constraint(equalTo: replyMessageView.topAnchor).isActive = true

        chatBar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        chatBar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        bottomConstraint = chatBar.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        bottomConstraint?.isActive = true

        replyMessageView.leadingAnchor.constraint(
            equalTo: view.leadingAnchor).isActive = true
        replyMessageView.trailingAnchor.constraint(
            equalTo: view.trailingAnchor).isActive = true
        replyMessageView.heightAnchor.constraintEqualToAnchor(
            constant: 0,
            identifier: ConstraintIdentifier.replyMessageViewHeight)
            .isActive = true
        replyMessageView.bottomAnchor.constraint(
            equalTo: chatBar.topAnchor,
            constant: 0).isActive = true

        unreadScrollButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        unreadScrollButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        unreadScrollButton.trailingAnchor.constraint(equalTo: tableView.trailingAnchor, constant: -10).isActive = true
        unreadScrollButton.bottomAnchor.constraint(equalTo: replyMessageView.topAnchor, constant: -10).isActive = true

        leftMoreBarConstraint = moreBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 56)
        leftMoreBarConstraint?.isActive = true
    }

    private func setupNavigation() {
        self.navigationItem.titleView = loadingIndicator
        loadingIndicator.startLoading(localizationFileName: configuration.localizedStringFileName)

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: navigationBar)
        viewModel.currentConversationProfile { (profile) in
            guard let profile = profile else { return }
            self.loadingIndicator.stopLoading()
            self.navigationBar.updateView(profile: profile)
        }
    }

    private func prepareTable() {

        let gesture = UITapGestureRecognizer(target: self, action: #selector(tableTapped(gesture:)))
        gesture.numberOfTapsRequired = 1
        tableView.addGestureRecognizer(gesture)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

        tableView.sectionHeaderHeight = 0.0
        tableView.sectionFooterHeight = 0.0
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.bounds.size.width, height: 0.1))
        tableView.tableFooterView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.bounds.size.width, height: 8))

        self.automaticallyAdjustsScrollViewInsets = false

        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = UIScrollView.ContentInsetAdjustmentBehavior.never
        }
        tableView.estimatedRowHeight = 0

        tableView.register(ALKMyMessageCell.self)
        tableView.register(ALKFriendMessageCell.self)
        tableView.register(ALKMyPhotoPortalCell.self)
        tableView.register(ALKMyPhotoLandscapeCell.self)

        tableView.register(ALKFriendPhotoPortalCell.self)
        tableView.register(ALKFriendPhotoLandscapeCell.self)

        tableView.register(ALKMyVoiceCell.self)
        tableView.register(ALKFriendVoiceCell.self)
        tableView.register(ALKInformationCell.self)
        tableView.register(ALKMyLocationCell.self)
        tableView.register(ALKFriendLocationCell.self)
        tableView.register(ALKMyVideoCell.self)
        tableView.register(ALKFriendVideoCell.self)
        tableView.register(ALKMyGenericListCell.self)
        tableView.register(ALKFriendGenericListCell.self)
        tableView.register(ALKFriendEmailCell.self)
        tableView.register(ALKMyEmailCell.self)
        tableView.register(ALKMyGenericCardCell.self)
        tableView.register(ALKFriendGenericCardCell.self)
        tableView.register(ALKFriendQuickReplyCell.self)
        tableView.register(ALKMyQuickReplyCell.self)
        tableView.register(ALKMyMessageButtonCell.self)
        tableView.register(ALKFriendMessageButtonCell.self)
        tableView.register(ALKMyListTemplateCell.self)
        tableView.register(ALKFriendListTemplateCell.self)
        tableView.register(ALKMyDocumentCell.self)
        tableView.register(ALKFriendDocumentCell.self)
        tableView.register(ALKMyDocumentCell.self)
        tableView.register(ALKMyContactMessageCell.self)
        tableView.register(ALKFriendContactMessageCell.self)
    }


    private func prepareMoreBar() {

        moreBar.bottomAnchor.constraint(equalTo: chatBar.topAnchor).isActive = true
        moreBar.isHidden = true
        moreBar.setHandleAction { [weak self] (actionType) in
            self?.hideMoreBar()
        }
    }

    private func configureChatBar() {
        if viewModel.isOpenGroup {
            hideMediaOptions()
            chatBar.hideMicButton()
        }else {
            if configuration.hideAllOptionsInChatBar {hideMediaOptions()}
            else {showMediaOptions()}
        }
    }

    private func prepareChatBar() {
        // Update ChatBar's top view which contains send button and the text view.
        chatBar.grayView.backgroundColor = configuration.backgroundColor

        // Update background view's color which contains all the attachment options.
        chatBar.bottomGrayView.backgroundColor = configuration.chatBarAttachmentViewBackgroundColor

        chatBar.poweredByMessageLabel.attributedText =
            NSAttributedString(string: "Powered by Applozic")
        chatBar.poweredByMessageLabel.setLinkForSubstring("Applozic", withLinkHandler: {
            [weak self] label, substring in
            guard let _ = substring else {return}
            let svc = SFSafariViewController(url: URL(string:"https://Applozic.com")!)
            self?.present(svc, animated: true, completion: nil)
        })
        if viewModel.showPoweredByMessage() {chatBar.showPoweredByMessage()}
        chatBar.accessibilityIdentifier = "chatBar"
        chatBar.setComingSoonDelegate(delegate: self.view)
        chatBar.action = { [weak self] (action) in

            guard let weakSelf = self else {
                return
            }

            if case .more(_) = action {

                if weakSelf.moreBar.isHidden == true {
                    weakSelf.showMoreBar()
                } else {
                    weakSelf.hideMoreBar()
                }

                return
            }

            weakSelf.hideMoreBar()

            switch action {

            case .sendText(let button, let message):

                if message.count < 1 {
                    return
                }

                button.isUserInteractionEnabled = false
                weakSelf.viewModel.sendKeyboardDoneTyping()

                weakSelf.chatBar.clear()

                if let profanityFilter = weakSelf.profanityFilter, profanityFilter.containsRestrictedWords(text: message) {
                    let profanityTitle = weakSelf.localizedString(
                        forKey: "profaneWordsTitle",
                        withDefaultValue: SystemMessage.Warning.profaneWordsTitle,
                        fileName: weakSelf.localizedStringFileName)
                    let profanityMessage = weakSelf.localizedString(
                        forKey: "profaneWordsMessage",
                        withDefaultValue: SystemMessage.Warning.profaneWordsMessage,
                        fileName: weakSelf.localizedStringFileName)
                    let okButtonTitle = weakSelf.localizedString(
                        forKey: "OkMessage",
                        withDefaultValue: SystemMessage.ButtonName.ok,
                        fileName: weakSelf.localizedStringFileName)
                    let alert = UIAlertController(
                        title: profanityTitle,
                        message: profanityMessage,
                        preferredStyle: .alert)
                    alert.addAction(UIAlertAction(
                        title: okButtonTitle,
                        style: .cancel,
                        handler: nil))
                    weakSelf.present(alert, animated: false, completion: nil)
                    button.isUserInteractionEnabled = true
                    return
                }
                weakSelf.isJustSent = true
                print("About to send this message: ", message)
                weakSelf.viewModel.send(message: message, isOpenGroup: weakSelf.viewModel.isOpenGroup, metadata:self?.configuration.messageMetadata)
                button.isUserInteractionEnabled = true
            case .chatBarTextChange(_):

                weakSelf.viewModel.sendKeyboardBeginTyping()

                UIView.animate(withDuration: 0.05, animations: { () in
                    weakSelf.view.layoutIfNeeded()
                }, completion: { [weak self] (_) in

                    guard let weakSelf = self else {
                        return
                    }

                    if weakSelf.tableView.isAtBottom == true && weakSelf.isJustSent == false {
                        weakSelf.tableView.scrollToBottomByOfset(animated: false)
                    }
                })
            case .sendVoice(let voice):
                weakSelf.viewModel.send(voiceMessage: voice as Data, metadata:self?.configuration.messageMetadata)
                break;

            case .startVideoRecord():
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: {
                        granted in
                        DispatchQueue.main.async {
                            if granted {
                                let imagePicker = UIImagePickerController()
                                imagePicker.delegate = self
                                imagePicker.allowsEditing = true;
                                imagePicker.sourceType = .camera
                                imagePicker.mediaTypes = [kUTTypeMovie as String]
                                UIViewController.topViewController()?.present(imagePicker, animated: false, completion: nil)
                            } else {
                                let msg = weakSelf.localizedString(forKey: "EnableCameraPermissionMessage", withDefaultValue: SystemMessage.Camera.cameraPermission, fileName: weakSelf.localizedStringFileName)
                                ALUtilityClass.permissionPopUp(withMessage: msg, andViewController: self)
                            }
                        }
                    })
                } else {
                    let msg = weakSelf.localizedString(forKey: "CameraNotAvailableMessage", withDefaultValue: SystemMessage.Camera.CamNotAvailable, fileName: weakSelf.localizedStringFileName)
                    let title = weakSelf.localizedString(forKey: "CameraNotAvailableTitle", withDefaultValue: SystemMessage.Camera.camNotAvailableTitle, fileName: weakSelf.localizedStringFileName)
                    ALUtilityClass.showAlertMessage(msg, andTitle: title)
                }
            case .showImagePicker():
                guard let vc = ALKCustomPickerViewController.makeInstanceWith(delegate: weakSelf, and: weakSelf.configuration)
                    else {
                        return
                }
                weakSelf.present(vc, animated: false, completion: nil)
            case .showLocation():
                let storyboard = UIStoryboard.name(storyboard: UIStoryboard.Storyboard.MapView, bundle: Bundle.applozic)

                guard let nav = storyboard.instantiateInitialViewController() as? UINavigationController else { return }
                guard let mapViewVC = nav.viewControllers.first as? ALKMapViewController else { return }
                mapViewVC.delegate = self
                mapViewVC.setConfiguration(weakSelf.configuration)
                self?.present(nav, animated: true, completion: {})
            case .cameraButtonClicked(let button):
                guard let vc = ALKCustomCameraViewController.makeInstanceWith(delegate: weakSelf, and: weakSelf.configuration)
                else {
                    button.isUserInteractionEnabled = true
                    return
                }
                weakSelf.present(vc, animated: false, completion: nil)
                button.isUserInteractionEnabled = true

            case .shareContact():
                weakSelf.shareContact()
            default:
                print("Not available")
            }
        }
    }

    //MARK: public Control Typing notification
    func setTypingNoticeDisplayName(displayName:String)
    {
        typingNoticeView.setDisplayName(displayName: displayName)
    }

    @objc func tableTapped(gesture: UITapGestureRecognizer) {
        hideMoreBar()
        view.endEditing(true)
    }

    /// Call this method after proper viewModel initialization
    public func refreshViewController() {
        viewModel.clearViewModel()
        tableView.reloadData()

        setupNavigation()
        prepareContextView()
        configureChatBar()
        //Check for group left
        isChannelLeft()
        checkUserBlock()
        subscribeChannelToMqtt()

        viewModel.prepareController()
    }

    /// Call this before changing viewModel contents
    public func unsubscribingChannel() {
        guard viewModel != nil else { return }
        if !viewModel.isOpenGroup {
            self.alMqttConversationService.sendTypingStatus(
                ALUserDefaultsHandler.getApplicationKey(),
                userID: viewModel.contactId,
                andChannelKey: viewModel.channelKey,
                typing: false)
            self.alMqttConversationService.unSubscribe(toChannelConversation: viewModel.channelKey)
        } else {
            self.alMqttConversationService.unSubscribe(toOpenChannel: viewModel.channelKey)
        }
    }

    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        UIMenuController.shared.setMenuVisible(false, animated: true)
        hideMoreBar()
    }

    // Called from the parent VC
    public func showTypingLabel(status: Bool, userId: String) {
        /// Don't show typing status when contact is blocked
        guard
            let contact = ALContactService().loadContact(byKey: "userId", value: userId),
            !contact.block,
            !contact.blockBy
            else {
            return
        }

        if(status){
            timerTask = Timer.scheduledTimer(timeInterval: 30.0, target: self, selector: #selector(self.invalidateTimerAndUpdateHeightConstraint(_:)), userInfo: nil, repeats: false)
        }else{
            timerTask.invalidate()
        }

        typingNoticeViewHeighConstaint?.constant = status ? 30:0
        view.layoutIfNeeded()
        if tableView.isAtBottom {
            tableView.scrollToBottomByOfset(animated: false)
        }

        if configuration.showNameWhenUserTypesInGroup {
            guard let name = nameForTypingStatusUsing(userId: userId) else {
                return
            }
            setTypingNoticeDisplayName(displayName: name)
        } else {
            let name = defaultNameForTypingStatus()
            setTypingNoticeDisplayName(displayName: name)
        }
    }

    @objc public func invalidateTimerAndUpdateHeightConstraint(_ timer: Timer?)  {
        timerTask.invalidate()
        typingNoticeViewHeighConstaint?.constant = 0
    }

    public func sync(message: ALMessage) {
        viewModel.sync(message: message)
    }

    public func updateDeliveryReport(messageKey: String?, contactId: String?, status: Int32?) {
        guard let key = messageKey, let status = status else {
            return
        }
        viewModel.updateDeliveryReport(messageKey: key, status: status)
    }

    public func updateStatusReport(contactId: String?, status: Int32?) {
        guard let id = contactId, let status = status else {
            return
        }
        viewModel.updateStatusReportForConversation(contactId: id, status: status)
    }

    private func defaultNameForTypingStatus() -> String{
        if self.viewModel.isGroup == true {
            return "Somebody"
        } else {
            return self.title ?? ""
        }
    }

    private func nameForTypingStatusUsing(userId: String) -> String?{
        guard let contact = contactService.loadContact(byKey: "userId", value: userId) else {
            return nil
        }
        if contact.block || contact.blockBy {
            return nil
        }
        return contact.getDisplayName()
    }

    fileprivate func subscribeChannelToMqtt() {
        let channelService = ALChannelService()
        if viewModel.isGroup, let groupId = viewModel.channelKey, !channelService.isChannelLeft(groupId) && !ALChannelService.isChannelDeleted(groupId) {
            if !viewModel.isOpenGroup {
                self.alMqttConversationService.subscribe(toChannelConversation: groupId)
            } else {
                self.alMqttConversationService.subscribe(toOpenChannel: groupId)
            }
        } else if !viewModel.isGroup {
            self.alMqttConversationService.subscribe(toChannelConversation: nil)
        }
        if viewModel.isGroup, ALUserDefaultsHandler.isUserLoggedInUserSubscribedMQTT(){
            self.alMqttConversationService.unSubscribe(toChannelConversation: nil)
        }

    }


    @objc func unreadScrollDownAction(_ sender: UIButton) {
        tableView.scrollToBottom()
        unreadScrollButton.isHidden = true
    }

    func attachmentViewDidTapDownload(view: UIView, indexPath: IndexPath) {
        guard let message = viewModel.messageForRow(indexPath: indexPath) else { return }
        viewModel.downloadAttachment(message: message, view: view)
    }

    func attachmentViewDidTapUpload(view: UIView, indexPath: IndexPath) {
        guard ALDataNetworkConnection.checkDataNetworkAvailable() else {
            let notificationView = ALNotificationView()
            notificationView.noDataConnectionNotificationView()
            return
        }
        viewModel.uploadImage(view: view, indexPath: indexPath)
    }

    func attachmentUploadDidCompleteWith(response: Any?, indexPath: IndexPath) {
        viewModel.uploadAttachmentCompleted(responseDict: response, indexPath: indexPath)
    }

    func messageAvatarViewDidTap(messageVM: ALKMessageViewModel, indexPath: IndexPath) {
        // Open chat thread
        guard viewModel.isGroup && isProfileTapActionEnabled else {return}

        // Get the user id of that user
        guard let receiverId = messageVM.receiverId else {return}

        let vm = ALKConversationViewModel(contactId: receiverId, channelKey: nil, localizedStringFileName: configuration.localizedStringFileName)
        let conversationVC = ALKConversationViewController(configuration: configuration)
        conversationVC.viewModel = vm
        navigationController?.pushViewController(conversationVC, animated: true)
    }

    func menuItemSelected(action: ALKChatBaseCell<ALKMessageViewModel>.MenuActionType,
                          message: ALKMessageViewModel) {
        switch action {
        case .reply:
            print("Reply selected")
            viewModel.setSelectedMessageToReply(message)
            replyMessageView.update(message: message)
            showReplyMessageView()
        }
    }

    func showReplyMessageView() {
        replyMessageView.constraint(
            withIdentifier: ConstraintIdentifier.replyMessageViewHeight)?
            .constant = Padding.ReplyMessageView.height
    }

    func hideReplyMessageView() {
        replyMessageView.constraint(
            withIdentifier: ConstraintIdentifier.replyMessageViewHeight)?
            .constant = 0
    }

    func scrollTo(message: ALKMessageViewModel) {
        let messageService = ALMessageService()
        guard
            let metadata = message.metadata,
            let replyId = metadata[AL_MESSAGE_REPLY_KEY] as? String
            else {return}
        let actualMessage = messageService.getALMessage(byKey: replyId).messageModel
        guard let indexPath = viewModel.getIndexpathFor(message: actualMessage)
            else {return}
        tableView.scrollToRow(at: indexPath, at: .top, animated: true)

    }

    func postGenericListButtonTapNotification(tag: Int, title: String, template: [ALKGenericListTemplate], key: String) {
        print("\(title, tag) button selected in generic list")
        var infoDict = [String: Any]()
        infoDict["buttonName"] = title
        infoDict["buttonIndex"] = tag
        infoDict["template"] = template
        infoDict["messageKey"] = key
        infoDict["userId"] = self.viewModel.contactId
        NotificationCenter.default.post(name: Notification.Name(rawValue: "GenericRichListButtonSelected"), object: infoDict)
    }

    func quickReplySelected(
        index: Int,
        title: String,
        template: [Dictionary<String, Any>],
        message: ALKMessageViewModel,
        metadata: Dictionary<String, Any>?,
        isButtonClickDisabled: Bool) {
        print("\(title, index) quick reply button selected")
        sendNotification(withName: "QuickReplyButtonSelected", buttonName: title, buttonIndex: index, template: template, messageKey: message.identifier)

        guard !isButtonClickDisabled else { return }

        /// Get message to send
        guard index <= template.count && index > 0 else { return }
        let dict = template[index - 1]
        let msg = dict["message"] as? String ?? title

        /// Use metadata
        sendQuickReply(msg, metadata: metadata)
    }

    func messageButtonSelected(
        index: Int,
        title: String,
        message: ALKMessageViewModel,
        isButtonClickDisabled: Bool) {
        guard !isButtonClickDisabled,
            let selectedButton = message.payloadFromMetadata()?[index],
            let buttonTitle = selectedButton["name"] as? String,
            buttonTitle == title
            else {
            return
        }

        guard
            let type = selectedButton["type"] as? String,
            type == "link"
            else {
                /// Submit Button
                let text = selectedButton["replyText"] as? String ?? selectedButton["name"] as! String
                submitButtonSelected(metadata: message.metadata!, text: text)
                return
        }
        linkButtonSelected(selectedButton)
    }

    func listTemplateSelected(defaultText: String?, action: ListTemplate.Action) {
        guard !configuration.disableRichMessageButtonAction else { return }
        guard let type = action.type else {
            print("Type not defined for action")
            return
        }

        switch type {
            case ActionType.link.rawValue:
                guard let urlString = action.url, let url = URL(string: urlString) else { return }
                openLink(url)

            case ActionType.quickReply.rawValue:
                let text = action.text ?? defaultText
                guard let msg = text else { return }
                sendQuickReply(msg, metadata: nil)

            default:
                print("Action type is neither \"link\" nor \"quick_reply\"")
                var infoDict = [String: Any]()
                infoDict["action"] = action
                infoDict["userId"] = self.viewModel.contactId
                NotificationCenter.default.post(name: Notification.Name(rawValue: "ListTemplateSelected"), object: infoDict)
        }
    }

    func cardTemplateSelected(tag: Int, title: String, template: CardTemplate, message: ALKMessageViewModel) {
        guard
            message.isMyMessage == false,
            configuration.disableRichMessageButtonAction == false
        else {
                return
        }

        guard
            let buttons = template.buttons, tag < buttons.count,
            let action = buttons[tag].action,
            let payload = action.payload
        else {
            print("\(tag) Button for this card is nil unexpectedly :: \(template)")
            return
        }

        switch action.type {
        case CardTemplateActionType.link.rawValue:
            guard let urlString = payload.url, let url = URL(string: urlString) else { return }
            openLink(url)
        case CardTemplateActionType.submit.rawValue:
            var dict = [String: Any]()
            dict["formData"] = payload.formData
            dict["formAction"] = payload.formAction
            dict["requestType"] = payload.requestType
            submitButtonSelected(metadata: dict, text: payload.text ?? "")
        case CardTemplateActionType.quickReply.rawValue:
            let text = payload.title ?? buttons[tag].name
            sendQuickReply(text, metadata: nil)
        default:
            /// Action not defined. Post notification outside.
            sendNotification(withName: "GenericRichCardButtonSelected", buttonName: title, buttonIndex: tag, template: message.payloadFromMetadata() ?? [], messageKey: message.identifier)
        }
    }

    @objc func dismissContact() {
        ALPushAssist().topViewController.dismiss(animated: true, completion: nil)
    }

    func openContact(_ contact: CNContact) {
        CNContactStore().requestAccess(for: .contacts) { (granted, error) in
            if granted {
                let vc = CNContactViewController(forUnknownContact: contact)
                vc.contactStore = CNContactStore()
                let nav = UINavigationController(rootViewController: vc)
                vc.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.dismissContact))
                self.present(nav, animated: true, completion: nil)
            } else {
                ALUtilityClass.permissionPopUp(withMessage: "Enable Contact permission", andViewController: self)
            }
        }
    }

    func collectionViewOffsetFromIndex(_ index: Int) -> CGFloat {

        let value = contentOffsetDictionary[index]
        let horizontalOffset = CGFloat(value != nil ? value!.floatValue : 0)
        return horizontalOffset
    }

    fileprivate func hideMediaOptions() {
        chatBar.hideMediaView()
    }

    fileprivate func showMediaOptions() {
        chatBar.showMediaView()
    }

    private func showMoreBar() {

        self.moreBar.isHidden = false
        self.leftMoreBarConstraint?.constant = 0

        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut, animations: { [weak self] () in
            self?.view.layoutIfNeeded()
            }, completion: { [weak self] (finished) in

                guard let strongSelf = self else {return}

                strongSelf.view.bringSubviewToFront(strongSelf.moreBar)
                strongSelf.view.sendSubviewToBack(strongSelf.tableView)
        })

    }

    private func sendNotification(withName: String, buttonName: String, buttonIndex: Int, template: [Dictionary<String, Any>], messageKey: String) {
        var infoDict = [String: Any]()
        infoDict["buttonName"] = title
        infoDict["buttonIndex"] = index
        infoDict["template"] = template
        infoDict["messageKey"] = messageKey
        infoDict["userId"] = self.viewModel.contactId
        NotificationCenter.default.post(name: Notification.Name(rawValue: withName), object: infoDict)
    }

    private func hideMoreBar() {

        if self.leftMoreBarConstraint?.constant == 0 {

            self.leftMoreBarConstraint?.constant = 56

            UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut, animations: { [weak self] () in
                self?.view.layoutIfNeeded()
                }, completion: { [weak self] (finished) in
                    self?.moreBar.isHidden = true
            })

        }

    }

    @objc private func showParticipantListChat() {
        guard let channelKey = viewModel.channelKey else { return }
        let storyboard = UIStoryboard.name(storyboard: UIStoryboard.Storyboard.createGroupChat, bundle: Bundle.applozic)
        if let vc = storyboard.instantiateViewController(withIdentifier: "ALKCreateGroupViewController") as? ALKCreateGroupViewController {
            vc.configuration = configuration
            vc.setCurrentGroupSelected(
                groupId: channelKey,
                groupProfile: self.viewModel.groupProfileImgUrl(),
                delegate: self)
            vc.addContactMode = .existingChat
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    private func configurePropertiesWith(configuration: ALKConfiguration) {
        self.isGroupDetailActionEnabled = configuration.isTapOnNavigationBarEnabled
        self.isProfileTapActionEnabled = configuration.isProfileTapActionEnabled
    }

    private func sendQuickReply(_ text: String, metadata: Dictionary<String, Any>?) {
        var customMetadata = metadata ?? [String: Any]()
        guard let messageMetadata = configuration.messageMetadata as? [String: Any] else {
            viewModel.send(message: text, metadata: customMetadata)
            return
        }
        customMetadata.merge(messageMetadata) { $1 }
        viewModel.send(message: text, metadata: customMetadata)
    }

    private func postRequestUsing(url: URL, param: String) -> URLRequest? {
        var request = URLRequest(url: url)
        request.timeoutInterval = 600
        request.httpMethod = "POST"
        guard let data = param.data(using: .utf8) else { return nil }
        request.httpBody = data
        let contentLength = String(format: "%lu", UInt(data.count))
        request.setValue(contentLength, forHTTPHeaderField: "Content-Length")
        return request
    }

    private func requestHandler(_ request: URLRequest, _ completion: @escaping (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            print("Response is \(String(describing: response)) and error is \(String(describing: error))")
            completion(data, response, error)
        }
        task.resume()
    }

    private func openLink(_ url: URL) {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }

    private func linkButtonSelected(_ selectedButton: Dictionary<String, Any>) {
        guard
            let urlString = selectedButton["url"] as? String,
            let url = URL(string: urlString)
        else {
            return
        }
        openLink(url)
    }

    private func submitButtonResponse(request: URLRequest) {
        activityIndicator.startAnimating()
        let group = DispatchGroup()
        group.enter()
        var responseData: String?
        var responseUrl: URL?
        requestHandler(request) { dat, response, error in
            guard error == nil, let data = dat, let url = response?.url else {
                print("Error while making submit button request: \(error), \(dat), \(response)")
                group.leave()
                return
            }
            responseData = String(data: data, encoding: .utf8)
            responseUrl = url
            group.leave()
        }
        group.notify(queue: .main) {
            self.activityIndicator.stopAnimating()
            guard let data = responseData, let url = responseUrl else {
                return
            }
            let vc = WebViewController(htmlString: data, url: url)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    private func submitButtonSelected(metadata: Dictionary<String, Any>, text: String) {
        guard
            let formData = metadata["formData"] as? String,
            let urlString = metadata["formAction"] as? String,
            let url = URL(string: urlString),
            var request = postRequestUsing(url: url, param: formData)
            else {
                return
        }
        self.viewModel.send(message: text, metadata: nil)
        if let type = metadata["requestType"] as? String, type == "json" {
            let contentType = "application/json"
            request.addValue(contentType, forHTTPHeaderField: "Content-Type")
            requestHandler(request) { _, _, _ in }
        } else {
            let contentType = "application/x-www-form-urlencoded"
            request.addValue(contentType, forHTTPHeaderField: "Content-Type")
            submitButtonResponse(request: request)
        }
    }

    private func shareContact() {
        CNContactStore().requestAccess(for: .contacts) { (granted, error) in
            if granted {
                let vc = CNContactPickerViewController()
                vc.delegate = self
                self.present(vc, animated: true, completion: nil)
            } else {
                ALUtilityClass.permissionPopUp(withMessage: "Enable Contact permission", andViewController: self)
            }
        }
    }
}

extension ALKConversationViewController: CNContactPickerDelegate {
    public func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        viewModel.send(contact: contact, metadata: configuration.messageMetadata)
        /// Send contact using path viewModelsend(photo:
    }
}

extension ALKConversationViewController: ALKConversationViewModelDelegate {


    public func loadingStarted() {
        activityIndicator.startAnimating()
    }

    public func loadingFinished(error: Error?) {
        activityIndicator.stopAnimating()
        let oldSectionCount = tableView.numberOfSections
        tableView.reloadData()
        let newSectionCount = tableView.numberOfSections
        if newSectionCount > oldSectionCount {
            let offset = newSectionCount - oldSectionCount - 1
            tableView.scrollToRow(at: IndexPath(row: 0, section: offset), at: .none, animated: false)
        }
        print("loading finished")
        DispatchQueue.main.async {
            if self.viewModel.isFirstTime {
                self.tableView.scrollToBottom(animated: false)
                self.viewModel.isFirstTime = false
            }
        }
        guard !viewModel.isOpenGroup else {return}
        viewModel.markConversationRead()
    }

    public func messageUpdated() {
        if activityIndicator.isAnimating {
            activityIndicator.stopAnimating()
        }
        tableView.reloadData()
    }

    public func updateMessageAt(indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            self.tableView.reloadSections(IndexSet(integer: indexPath.section), with: .none)
            self.tableView.endUpdates()
        }
    }

    //This is a temporary workaround for the issue that messages are not scrolling to bottom when opened from notification
    //This issue is happening because table view has different cells of different heights so it cannot go to the bottom of cell when using function scrollToBottom
    //And thats why when we check whether last cell is visible or not, it gives false result since the last cell is sometimes not fully visible.
    //This is a known apple bug and has a thread in stackoverflow: https://stackoverflow.com/questions/25686490/ios-8-auto-cell-height-cant-scroll-to-last-row
    private func moveTableViewToBottom(indexPath: IndexPath){
        guard indexPath.section >= 0 else {
            return
        }
        tableView.scrollToRow(at: indexPath, at: UITableView.ScrollPosition.bottom, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let sectionCount = self.tableView.numberOfSections
            if indexPath.section <= sectionCount {
                self.tableView.scrollToRow(at: indexPath, at: UITableView.ScrollPosition.bottom, animated: true)
            }
        }
    }

    func updateTableView() {
        let oldCount = tableView.numberOfSections
        let newCount = viewModel.numberOfSections()
        let indexSet = IndexSet(integersIn: oldCount..<newCount)

        tableView.beginUpdates()
        tableView.insertSections(indexSet, with: .automatic)
        tableView.endUpdates()
    }

    @objc open func newMessagesAdded() {
        updateTableView()
        //Check if current user is removed from the group
        isChannelLeft()

        if isViewLoadedFromTappingOnNotification {
            let indexPath: IndexPath = IndexPath(row: 0, section: viewModel.messageModels.count - 1)
            moveTableViewToBottom(indexPath: indexPath)
            isViewLoadedFromTappingOnNotification = false
        }else{
            if tableView.isCellVisible(section: viewModel.messageModels.count-2, row: 0) { //1 for recent added msg and 1 because it starts with 0
                let indexPath: IndexPath = IndexPath(row: 0, section: viewModel.messageModels.count - 1)
                moveTableViewToBottom(indexPath: indexPath)
            } else if viewModel.messageModels.count > 1 { // Check if the function is called before message is added. It happens when user is added in the group.
                unreadScrollButton.isHidden = false
            }
        }
        guard self.isViewLoaded && self.view.window != nil && !viewModel.isOpenGroup else {
            return
        }
        viewModel.markConversationRead()
    }

    public func messageSent(at indexPath: IndexPath) {
            NSLog("current indexpath: %i and tableview section %i", indexPath.section, self.tableView.numberOfSections)
            guard indexPath.section >= self.tableView.numberOfSections else {
                NSLog("rejected indexpath: %i and tableview and section %i", indexPath.section, self.tableView.numberOfSections)
                return
            }
            self.tableView.beginUpdates()
            self.tableView.insertSections(IndexSet(integer: indexPath.section), with: .automatic)
            self.tableView.endUpdates()
            self.tableView.scrollToBottom(animated: false)
    }

    public func updateDisplay(contact: ALContact?, channel: ALChannel?) {
        let profile = viewModel.conversationProfileFrom(contact: contact, channel: channel, conversation: nil)
        navigationBar.updateView(profile: profile)
    }

    func rightNavbarButton() -> UIBarButtonItem? {
        guard !configuration.hideRightNavBarButtonForConversationView else {
            return nil
        }
        var button: UIBarButtonItem

        let notificationSelector = #selector(ALKConversationViewController.sendRightNavBarButtonSelectionNotification(_:))

        if let image = configuration.rightNavBarImageForConversationView {
            button = UIBarButtonItem(
                image: image,
                style: UIBarButtonItem.Style.plain,
                target: self,
                action: notificationSelector)
        }else {
            var selector = notificationSelector
            if configuration.rightNavBarSystemIconForConversationView == .refresh {
                selector = #selector(ALKConversationViewController.refreshButtonAction(_:))
            }

            button = UIBarButtonItem(
                barButtonSystemItem: configuration.rightNavBarSystemIconForConversationView,
                target: self,
                action: selector)
        }
        return button
    }

    func addRefreshButton() {
        self.navigationItem.rightBarButtonItem = rightNavbarButton()
    }

    @objc func refreshButtonAction(_ selector: UIBarButtonItem) {
        viewModel.refresh()
    }

    @objc func sendRightNavBarButtonSelectionNotification(_ selector: UIBarButtonItem) {
        let channelId = (viewModel.channelKey != nil) ? String(describing: viewModel.channelKey!) : ""
        let contactId = viewModel.contactId ?? ""
        let info: [String: Any] = ["ChannelId": channelId, "ContactId": contactId, "ConversationVC": self]

        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RightNavBarConversationViewAction"), object: info)
    }

    public func willSendMessage() {
        // Clear reply message and the view
        viewModel.clearSelectedMessageToReply()
        hideReplyMessageView()
    }

    public func updateTyingStatus(status: Bool, userId: String) {
        self.showTypingLabel(status: status, userId: userId)
    }

}

extension ALKConversationViewController: ALKCreateGroupChatAddFriendProtocol {

    func createGroupGetFriendInGroupList(friendsSelected: [ALKFriendViewModel], groupName: String, groupImgUrl: String, friendsAdded: [ALKFriendViewModel]) {
        if viewModel.isGroup {
            viewModel.updateGroup(groupName: groupName, groupImage: groupImgUrl, friendsAdded: friendsAdded)
            let _ = navigationController?.popToViewController(self, animated: true)
        }
    }
}

extension ALKConversationViewController: ALKShareLocationViewControllerDelegate {
    func locationDidSelected(geocode: Geocode, image: UIImage) {
        let (message, indexPath) = viewModel.add(geocode: geocode,metadata: self.configuration.messageMetadata)
        guard let newMessage = message, let newIndexPath = indexPath else {
            return
        }
        self.tableView.beginUpdates()
        self.tableView.insertSections(IndexSet(integer: (newIndexPath.section)), with: .automatic)
        self.tableView.endUpdates()

        // Not scrolling down without the delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.tableView.scrollToBottom(animated: false)
        }
        viewModel.sendGeocode(message: newMessage, indexPath: newIndexPath)
    }
}


extension ALKConversationViewController: ALKLocationCellDelegate {
    func displayLocation(location: ALKLocationPreviewViewModel) {
        let latLonString = String(format: "%f,%f", location.coordinate.latitude, location.coordinate.longitude)
        let locationString = String(format: "https://maps.google.com/maps?q=loc:%@", latLonString)
        guard let locationUrl = URL(string: locationString) else { return }
        UIApplication.shared.openURL(locationUrl)

    }
}

extension ALKConversationViewController: ALKAudioPlayerProtocol, ALKVoiceCellProtocol {

    func reloadVoiceCell() {
        for cell in tableView.visibleCells {
            guard let indexPath = tableView.indexPath(for: cell) else {return}
            if let message = viewModel.messageForRow(indexPath: indexPath) {
                if message.messageType == .voice && message.identifier == audioPlayer.getCurrentAudioTrack(){
                    print("voice cell reloaded with row: ", indexPath.row, indexPath.section)
                    tableView.reloadSections([indexPath.section], with: .none)
                    break
                }
            }
        }
    }

    //MAKR: Voice and Audio Delegate
    func playAudioPress(identifier: String) {
        DispatchQueue.main.async { [weak self] in
            NSLog("play audio pressed")
            guard let weakSelf = self else { return }

            //if we have previously play audio, stop it first
            if !weakSelf.audioPlayer.getCurrentAudioTrack().isEmpty && weakSelf.audioPlayer.getCurrentAudioTrack() != identifier {
                //pause
                NSLog("already playing, change it to pause")
                guard var lastMessage =  weakSelf.viewModel.messageForRow(identifier: weakSelf.audioPlayer.getCurrentAudioTrack()) else {return}

                if Int(lastMessage.voiceCurrentDuration) > 0 {
                    lastMessage.voiceCurrentState = .pause
                    lastMessage.voiceCurrentDuration = weakSelf.audioPlayer.secLeft
                } else {
                    let lastMessageCopy = lastMessage
                    lastMessage.voiceCurrentDuration = lastMessageCopy.voiceTotalDuration
                    lastMessage.voiceCurrentState = .stop
                }
                weakSelf.audioPlayer.pauseAudio()
            }
            NSLog("now it will be played")
            //now play
            guard var currentVoice =  weakSelf.viewModel.messageForRow(identifier: identifier) else {return}
            if currentVoice.voiceCurrentState == .playing {
                currentVoice.voiceCurrentState = .pause
                currentVoice.voiceCurrentDuration = weakSelf.audioPlayer.secLeft
                weakSelf.audioPlayer.pauseAudio()
                weakSelf.tableView.reloadData()
            }
            else {
                NSLog("reset time to total duration")
                //reset time to total duration
                if currentVoice.voiceCurrentState  == .stop || currentVoice.voiceCurrentDuration < 1 {
                    let currentVoiceCopy = currentVoice
                    currentVoice.voiceCurrentDuration = currentVoiceCopy.voiceTotalDuration
                }

                if let data = currentVoice.voiceData {
                    let voice = data as NSData
                    //start playing
                    NSLog("Start playing")
                    weakSelf.audioPlayer.setAudioFile(data: voice, delegate: weakSelf, playFrom: currentVoice.voiceCurrentDuration,lastPlayTrack:currentVoice.identifier)
                    currentVoice.voiceCurrentState = .playing
                    weakSelf.tableView.reloadData()
                }
            }
        }

    }

    func audioPlaying(maxDuratation: CGFloat, atSec: CGFloat,lastPlayTrack:String) {

        DispatchQueue.main.async { [weak self] in
            guard let weakSelf = self else { return }
            guard var currentVoice =  weakSelf.viewModel.messageForRow(identifier: lastPlayTrack) else {return}
            if currentVoice.messageType == .voice {

                if currentVoice.identifier == lastPlayTrack {
                    if atSec <= 0 {
                        currentVoice.voiceCurrentState = .stop
                        currentVoice.voiceCurrentDuration = 0
                    } else {
                        currentVoice.voiceCurrentState = .playing
                        currentVoice.voiceCurrentDuration = atSec
                    }
                }
                print("audio playing id: ", currentVoice.identifier)
                weakSelf.reloadVoiceCell()
            }
        }
    }

    func audioStop(maxDuratation: CGFloat,lastPlayTrack:String) {

        DispatchQueue.main.async { [weak self] in
            guard let weakSelf = self else { return }

            guard var currentVoice =  weakSelf.viewModel.messageForRow(identifier: lastPlayTrack) else {return}
            if currentVoice.messageType == .voice {
                if currentVoice.identifier == lastPlayTrack {
                    currentVoice.voiceCurrentState = .stop
                    currentVoice.voiceCurrentDuration = 0.0
                }
            }
            weakSelf.reloadVoiceCell()
        }
    }

    func stopAudioPlayer(){
        DispatchQueue.main.async { [weak self] in
            guard let weakSelf = self else { return }
            if var lastMessage = weakSelf.viewModel.messageForRow(identifier: weakSelf.audioPlayer.getCurrentAudioTrack()) {

                if lastMessage.voiceCurrentState == .playing {
                    weakSelf.audioPlayer.pauseAudio()
                    lastMessage.voiceCurrentState = .pause
                    weakSelf.reloadVoiceCell()
                }
            }
        }
    }
}

extension ALKConversationViewController: ALMQTTConversationDelegate {

    public func mqttDidConnected() {
        if individualLaunch {
            subscribeChannelToMqtt()
        }
    }

    public func syncCall(_ alMessage: ALMessage!, andMessageList messageArray: NSMutableArray!) {
        print("sync call1 ", messageArray)
        guard let message = alMessage else { return }
        sync(message: message)
    }

    public func delivered(_ messageKey: String!, contactId: String!, withStatus status: Int32) {
        updateDeliveryReport(messageKey: messageKey, contactId: contactId, status: status)
    }

    public func updateStatus(forContact contactId: String!, withStatus status: Int32) {
        updateStatusReport(contactId: contactId, status: status)
    }

    public func updateTypingStatus(_ applicationKey: String!, userId: String!, status: Bool) {
        print("Typing status is", status)
        guard viewModel.contactId == userId || viewModel.channelKey != nil else {
            return
        }
        print("Contact id matched")
        showTypingLabel(status: status, userId: userId)

    }

    public func updateLastSeen(atStatus alUserDetail: ALUserDetail!) {
        print("Last seen updated")
        guard let contact = contactService.loadContact(byKey: "userId", value: alUserDetail.userId) else {
            return
        }
        guard contact.userId == viewModel.contactId, !viewModel.isGroup else { return }
        navigationBar.updateStatus(isOnline: contact.connected, lastSeenAt: contact.lastSeenAt)
    }

    public func mqttConnectionClosed() {
        if viewModel.isOpenGroup &&  mqttRetryCount < maxMqttRetryCount {
            subscribeChannelToMqtt()
        }
        NSLog("MQTT connection closed")
    }

    public func reloadData(forUserBlockNotification userId: String!, andBlockFlag flag: Bool) {
        print("reload data")
        checkUserBlock()
    }

    public func updateUserDetail(_ userId: String!) {
        guard let userId = userId else { return }
        print("update user detail")
        viewModel.updateUserDetail(userId)
    }
}

extension ALKConversationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        // Video attachment
        if let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String, mediaType == "public.movie" {
            guard let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL else { return }
            print("video path is: ", url.path)
            viewModel.encodeVideo(videoURL: url, completion: {
                path in
                guard let newPath = path else { return }
                var indexPath: IndexPath? = nil
                DispatchQueue.main.async {
                    (_, indexPath) = self.viewModel.sendVideo(atPath: newPath, sourceType: picker.sourceType,metadata: self.configuration.messageMetadata)
                    self.tableView.beginUpdates()
                    self.tableView.insertSections(IndexSet(integer: (indexPath?.section)!), with: .automatic)
                    self.tableView.endUpdates()
                    self.tableView.scrollToBottom(animated: false)
                    guard let newIndexPath = indexPath, let cell = self.tableView.cellForRow(at: newIndexPath) as? ALKMyVideoCell else { return }
                    guard ALDataNetworkConnection.checkDataNetworkAvailable() else {
                        let notificationView = ALNotificationView()
                        notificationView.noDataConnectionNotificationView()
                        return
                    }
                    self.viewModel.uploadVideo(view: cell, indexPath: newIndexPath)
                }
            })
        }

        picker.dismiss(animated: true, completion: nil)
    }
}

extension ALKConversationViewController: ALKCustomPickerDelegate {
    func filesSelected(images: [UIImage], videos: [String]) {
        let count = images.count + videos.count
        for i in 0..<count {
            if i < images.count {
                let image = images[i]
                let (message, indexPath) =  self.viewModel.send(photo: image, metadata : self.configuration.messageMetadata)
                guard let _ = message, let newIndexPath = indexPath else { return }
                //            DispatchQueue.main.async {
                self.tableView.beginUpdates()
                self.tableView.insertSections(IndexSet(integer: newIndexPath.section), with: .automatic)
                self.tableView.endUpdates()
                self.tableView.scrollToBottom(animated: false)
                //            }
                guard let cell = tableView.cellForRow(at: newIndexPath) as? ALKMyPhotoPortalCell else { return }
                guard ALDataNetworkConnection.checkDataNetworkAvailable() else {
                    let notificationView = ALNotificationView()
                    notificationView.noDataConnectionNotificationView()
                    return
                }
                viewModel.uploadImage(view: cell, indexPath: newIndexPath)
            } else {
                let path = videos[i - images.count]
                let (_, indexPath) = viewModel.sendVideo(atPath: path, sourceType: .photoLibrary, metadata : self.configuration.messageMetadata)
                self.tableView.beginUpdates()
                self.tableView.insertSections(IndexSet(integer: (indexPath?.section)!), with: .automatic)
                self.tableView.endUpdates()
                self.tableView.scrollToBottom(animated: false)
                guard let newIndexPath = indexPath, let cell = tableView.cellForRow(at: newIndexPath) as? ALKMyVideoCell else { return }
                guard ALDataNetworkConnection.checkDataNetworkAvailable() else {
                    let notificationView = ALNotificationView()
                    notificationView.noDataConnectionNotificationView()
                    return
                }
                self.viewModel.uploadVideo(view: cell, indexPath: newIndexPath)
            }

        }
    }
}

extension ALKConversationViewController: NavigationBarCallbacks {
    func backButtonTapped() {
        backTapped()
    }

    func titleTapped() {
        if let contact = contactDetails(), let contactId = contact.userId {
            let info: [String: Any] =
                ["Id": contactId,
                 "Name": contact.getDisplayName() ?? "",
                 "Controller": self]

            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UserProfileSelected"), object: info)
        }
        guard isGroupDetailActionEnabled else { return }
        showParticipantListChat()
    }

    private func contactDetails() -> ALContact? {
        guard viewModel != nil else { return nil }
        guard
            viewModel.channelKey == nil,
            viewModel.conversationProxy == nil,
            let contactId = viewModel.contactId else {
                return nil
        }
        return ALContactService().loadContact(byKey: "userId", value: contactId)
    }

}
