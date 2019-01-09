
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

    override open var title: String? {
        didSet {
            titleButton.setTitle(title, for: .normal)
        }
    }

    public lazy var chatBar = ALKChatBar(frame: CGRect.zero, configuration: self.configuration)

    var contactService: ALContactService!

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
    fileprivate let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)

    fileprivate var keyboardSize: CGRect?

    fileprivate var localizedStringFileName: String!

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

      var tableView : UITableView = {
        let tv = UITableView(frame: .zero, style: .grouped)
        tv.separatorStyle   = .none
        tv.allowsSelection  = false
        tv.clipsToBounds    = true
        tv.keyboardDismissMode = UIScrollViewKeyboardDismissMode.onDrag
        tv.accessibilityIdentifier = "InnerChatScreenTableView"
        return tv
    }()

    fileprivate let titleButton : UIButton = {
        let titleButton = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        titleButton.titleLabel?.font  = UIFont.boldSystemFont(ofSize: 17.0)
        return titleButton
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
            NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillShow, object: nil, queue: nil, using: { [weak self]
            notification in
            print("keyboard will show")
            guard let weakSelf = self else {return}

            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {

                weakSelf.keyboardSize = keyboardSize

                let tableView = weakSelf.tableView
                let isAtBotom = tableView.isAtBottom
                let isJustSent = weakSelf.isJustSent

                let view = weakSelf.view
                _ = weakSelf.navigationController


                var h = CGFloat(0)
                h = keyboardSize.height-h

                let newH = -1*h
                if weakSelf.bottomConstraint?.constant == newH {return}

                weakSelf.bottomConstraint?.constant = newH

                let duration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.05

                UIView.animate(withDuration: duration, animations: {
                    view?.layoutIfNeeded()
                }, completion: { (_) in
                    print("animated ")
                    if isAtBotom == true && isJustSent == false {
                        tableView.scrollToBottomByOfset(animated: false)
                    }
                })
            }
        })


        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillHide, object: nil, queue: nil, using: {[weak self]
            (notification) in

            guard let weakSelf = self else {return}
            let view = weakSelf.view

            weakSelf.bottomConstraint?.constant = 0

            let duration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.05

            UIView.animate(withDuration: duration, animations: {
                view?.layoutIfNeeded()
            }, completion: { (_) in
                guard let vm = weakSelf.viewModel else { return }
                vm.sendKeyboardDoneTyping()
            })

        })

        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "newMessageNotification"), object: nil, queue: nil, using: { [weak self]
            notification in
            guard let weakSelf = self else { return }
            let msgArray = notification.object as? [ALMessage]
            print("new notification received: ", msgArray?.first?.message as Any, msgArray?.count ?? "")
            guard let list = notification.object as? [Any], !list.isEmpty, weakSelf.isViewLoaded, weakSelf.viewModel != nil else { return }
            weakSelf.viewModel.addMessagesToList(list)
//            weakSelf.handlePushNotification = false
        })

        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "notificationIndividualChat"), object: nil, queue: nil, using: {[weak self]
            notification in
            print("notification individual chat received")
        })

        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "report_DELIVERED"), object: nil, queue: nil, using: {[weak self]
            notification in
            guard let weakSelf = self, let key = notification.object as? String else { return }
            weakSelf.viewModel.updateDeliveryReport(messageKey: key, status: Int32(DELIVERED.rawValue))
            print("report delievered notification received")
        })

        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "report_DELIVERED_READ"), object: nil, queue: nil, using: {[weak self]
            notification in
            guard let weakSelf = self, let key = notification.object as? String else { return }
            weakSelf.viewModel.updateDeliveryReport(messageKey: key, status: Int32(DELIVERED_AND_READ.rawValue))
            print("report delievered and read notification received")
        })

        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "report_CONVERSATION_DELIVERED_READ"), object: nil, queue: nil, using: {[weak self]
            notification in
            guard let weakSelf = self, let key = notification.object as? String else { return }
            weakSelf.viewModel.updateStatusReportForConversation(contactId: key, status: Int32(DELIVERED_AND_READ.rawValue))
            print("report conversation delievered and read notification received")
        })

        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "UPDATE_MESSAGE_SEND_STATUS"), object: nil, queue: nil, using: {[weak self]
            notification in
            print("Message sent notification received")
            guard let weakSelf = self, let message = notification.object as? ALMessage else { return }
            weakSelf.viewModel.updateSendStatus(message: message)
        })

        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "USER_DETAILS_UPDATE_CALL"), object: nil, queue: nil, using: {[weak self] notification in
            NSLog("update user detail notification received")
            guard let weakSelf = self, let userId = notification.object as? String else { return }
            print("update user detail")
            ALUserService.updateUserDetail(userId, withCompletion: {
                userDetail in
                guard let detail = userDetail else { return }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "USER_DETAIL_OTHER_VC"), object: detail)
                guard !weakSelf.viewModel.isGroup && userId == weakSelf.viewModel.contactId else { return }
                weakSelf.titleButton.setTitle(detail.getDisplayName(), for: .normal)
            })
        })

        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "UPDATE_CHANNEL_NAME"), object: nil, queue: nil, using: {[weak self] notification in
            NSLog("update group name notification received")
            guard let weakSelf = self else { return }
            print("update group detail")
            guard weakSelf.viewModel.isGroup else { return }
            let alChannelService = ALChannelService()
            guard let key = weakSelf.viewModel.channelKey, let channel = alChannelService.getChannelByKey(key), let name = channel.name else { return }
            weakSelf.titleButton.setTitle(name, for: .normal)
            weakSelf.newMessagesAdded()
            })
    }

    override func removeObserver() {

        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "newMessageNotification"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "notificationIndividualChat"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "report_DELIVERED"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "report_DELIVERED_READ"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "report_CONVERSATION_DELIVERED_READ"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "UPDATE_MESSAGE_SEND_STATUS"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "USER_DETAILS_UPDATE_CALL"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "UPDATE_CHANNEL_NAME"), object: nil)
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
            self.setupNavigation()
            setupView()
        } else {
            tableView.reloadData()
        }
        contentOffsetDictionary = Dictionary<NSObject,AnyObject>()
        subscribeChannelToMqtt()
        print("id: ", viewModel.messageModels.first?.contactId as Any)
    }

    override open func viewDidAppear(_ animated: Bool) {
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
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
        if individualLaunch {
            if let _ = alMqttConversationService {
                alMqttConversationService.unsubscribeToConversation()
            }
        }
        unsubscribingChannel()
    }

    override func backTapped() {
        print("back tapped")
        self.viewModel.sendKeyboardDoneTyping()
        _ = navigationController?.popToRootViewController(animated: true)
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
        //Check for group left
        isChannelLeft()

        guard viewModel.isContextBasedChat else {
            toggleVisibilityOfContextTitleView(false)
            return
        }
        prepareContextView()
    }

    func isChannelLeft() {
        guard let channelKey = viewModel.channelKey, let channel = ALChannelService().getChannelByKey(channelKey) else {
            return
        }
        if  channel.type != 6 && !ALChannelService().isLoginUser(inChannel: channelKey) {
            chatBar.disableChat()
            //Disable click on toolbar
            titleButton.isUserInteractionEnabled = false
        } else {
            chatBar.enableChat()
            //Enable Click on toolbar
            titleButton.isUserInteractionEnabled = true
        }
    }

    func prepareContextView(){
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

        var allViews = [backgroundView, contextTitleView, tableView, moreBar, chatBar, typingNoticeView, unreadScrollButton, replyMessageView]
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

        titleButton.setTitle(self.title, for: .normal)
        titleButton.setTitleColor(self.configuration.navigationBarTitleColor, for: .normal)
        titleButton.addTarget(self, action: #selector(showParticipantListChat), for: .touchUpInside)
        titleButton.isEnabled = isGroupDetailActionEnabled
        self.navigationItem.titleView = titleButton
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
            tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentBehavior.never
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
        tableView.register(ALKMyGenericCardCell.self)
        tableView.register(ALKFriendGenericCardCell.self)
        tableView.register(ALKFriendQuickReplyCell.self)
        tableView.register(ALKMyQuickReplyCell.self)
    }


    private func prepareMoreBar() {

        moreBar.bottomAnchor.constraint(equalTo: chatBar.topAnchor).isActive = true
        moreBar.isHidden = true
        moreBar.setHandleAction { [weak self] (actionType) in
            self?.hideMoreBar()
        }
    }

    private func prepareChatBar() {
        // Update ChatBar's top view which contains send button and the text view.
        chatBar.grayView.backgroundColor = configuration.backgroundColor

        // Update background view's color which contains all the attachment options.
        chatBar.bottomGrayView.backgroundColor = configuration.chatBarAttachmentViewBackgroundColor

        if viewModel.isOpenGroup {
            hideMediaOptions()
            chatBar.hideMicButton()
        }else {
            if configuration.hideAllOptionsInChatBar {hideMediaOptions()}
            else {showMediaOptions()}
        }

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

                weakSelf.isJustSent = true

                weakSelf.chatBar.clear()

                NSLog("Sent: ", message)

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
        viewModel.prepareController()
    }

    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        UIMenuController.shared.setMenuVisible(false, animated: true)
        hideMoreBar()
    }

    // Called from the parent VC
    public func showTypingLabel(status: Bool, userId: String) {

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
        conversationVC.title = messageVM.displayName

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

    func postGenericListButtonTapNotification(tag: Int, title: String, template: [ALKGenericListTemplate]) {
        print("\(title, tag) button selected in generic list")
        var infoDict = [String: Any]()
        infoDict["buttonName"] = title
        infoDict["buttonIndex"] = tag
        infoDict["template"] = template
        infoDict["userId"] = self.viewModel.contactId
        NotificationCenter.default.post(name: Notification.Name(rawValue: "GenericRichListButtonSelected"), object: infoDict)
    }

    func quickReplySelected(index: Int, title: String, template: [Dictionary<String, Any>], message: ALKMessageViewModel, metadata: Dictionary<String, Any>?) {
        viewModel.send(message: title, metadata: metadata)
        print("\(title, index) quick reply button selected")
        var infoDict = [String: Any]()
        infoDict["buttonName"] = title
        infoDict["buttonIndex"] = index
        infoDict["template"] = template
        infoDict["message"] = message
        infoDict["userId"] = self.viewModel.contactId
        NotificationCenter.default.post(name: Notification.Name(rawValue: "QuickReplyButtonSelected"), object: infoDict)
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

                strongSelf.view.bringSubview(toFront: strongSelf.moreBar)
                strongSelf.view.sendSubview(toBack: strongSelf.tableView)
        })

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

    private func unsubscribingChannel() {
        if !viewModel.isOpenGroup {
            self.alMqttConversationService.sendTypingStatus(ALUserDefaultsHandler.getApplicationKey(), userID: viewModel.contactId, andChannelKey: viewModel.channelKey, typing: false)
            self.alMqttConversationService.unSubscribe(toChannelConversation: viewModel.channelKey)
        } else {
            self.alMqttConversationService.unSubscribe(toOpenChannel: viewModel.channelKey)
        }
    }

    @objc private func showParticipantListChat() {
        if viewModel.isGroup {
            let storyboard = UIStoryboard.name(storyboard: UIStoryboard.Storyboard.createGroupChat, bundle: Bundle.applozic)
            if let vc = storyboard.instantiateViewController(withIdentifier: "ALKCreateGroupViewController") as? ALKCreateGroupViewController {

                if viewModel.groupProfileImgUrl().isEmpty {
                    vc.setCurrentGroupSelected(groupName: viewModel.groupName(),groupProfileImg:nil, groupSelected: viewModel.friends(), delegate: self)
                } else {
                    vc.setCurrentGroupSelected(groupName: viewModel.groupName(),groupProfileImg:viewModel.groupProfileImgUrl(), groupSelected: viewModel.friends(), delegate: self)
                }
                vc.configuration = configuration
                vc.addContactMode = .existingChat
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }

    private func configurePropertiesWith(configuration: ALKConfiguration) {
        self.isGroupDetailActionEnabled = configuration.isTapOnNavigationBarEnabled
        self.isProfileTapActionEnabled = configuration.isProfileTapActionEnabled
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
            tableView.scrollToRow(at: IndexPath(row: 0, section: offset), at: .none, animated: true)
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
            self.tableView.reloadSections(IndexSet(integer: indexPath.section), with: .none)
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
        tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.bottom, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.bottom, animated: true)
        }
    }

    public func newMessagesAdded() {
        tableView.reloadData()
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
        DispatchQueue.main.async {
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
    }

    public func updateDisplay(name: String) {
        self.title = name
        titleButton.setTitle(name, for: .normal)
    }

    private func addRefreshButton() {
        guard !configuration.hideRightNavBarButtonForConversationView else {
            return
        }
        var button: UIBarButtonItem
        if let image = configuration.rightNavBarImageForConversationView {
            button = UIBarButtonItem(image: image, style: UIBarButtonItemStyle.plain, target: self,
                                         action: #selector(ALKConversationViewController.refreshButtonAction(_:)))
        }else {
            button = UIBarButtonItem(barButtonSystemItem: configuration.rightNavBarSystemIconForConversationView, target: self,
                                     action: #selector(ALKConversationViewController.refreshButtonAction(_:)))
        }
        self.navigationItem.rightBarButtonItem = button
    }

    @objc func refreshButtonAction(_ selector: UIBarButtonItem) {
        viewModel.refresh()
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
            if !groupName.isEmpty {
                self.title = groupName
                titleButton.setTitle(self.title, for: .normal)
            }

            viewModel.updateGroup(groupName: groupName, groupImage: groupImgUrl, friendsAdded: friendsAdded)

            if let titleButton = navigationItem.titleView as? UIButton {
                titleButton.setTitle(title, for: .normal)
            }

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
    }

    public func mqttConnectionClosed() {
        if viewModel.isOpenGroup &&  mqttRetryCount < maxMqttRetryCount {
            subscribeChannelToMqtt()
        }
        NSLog("MQTT connection closed")
    }

    public func reloadData(forUserBlockNotification userId: String!, andBlockFlag flag: Bool) {
        print("reload data")
    }

    public func updateUserDetail(_ userId: String!) {
        guard let userId = userId else { return }
        print("update user detail")

        ALUserService.updateUserDetail(userId, withCompletion: {
            userDetail in
            guard let detail = userDetail else { return }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "USER_DETAIL_OTHER_VC"), object: detail)
            guard !self.viewModel.isGroup && userId == self.viewModel.contactId else { return }
            self.titleButton.setTitle(detail.getDisplayName(), for: .normal)
        })
    }
}

extension ALKConversationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        // Video attachment
        if let mediaType = info[UIImagePickerControllerMediaType] as? String, mediaType == "public.movie" {
            guard let url = info[UIImagePickerControllerMediaURL] as? URL else { return }
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
