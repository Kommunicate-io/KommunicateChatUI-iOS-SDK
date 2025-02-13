//
//  ALKConversationViewModel.swift
//
//
//  Created by Mukesh Thawani on 04/05/17.
//

import AVFoundation
import Foundation
import KommunicateCore_iOS_SDK
import MobileCoreServices
#if canImport(RichMessageKit)
    import RichMessageKit
#endif
public protocol ALKConversationViewModelDelegate: AnyObject {
    func loadingStarted()
    func loadingFinished(error: Error?)
    func messageUpdated()
    func updateMessageAt(indexPath: IndexPath)
    func newMessagesAdded()
    func messageSent(at: IndexPath)
    func updateDisplay(contact: ALContact?, channel: ALChannel?)
    func willSendMessage()
    func updateTyingStatus(status: Bool, userId: String)
    func showInvalidReplyAlert(kmField : KMField)
    func isEmailSentForUpdatingUser(status: Bool)
    func emailUpdatedForUser()
}

// swiftlint:disable:next type_body_length
open class ALKConversationViewModel: NSObject, Localizable {
    fileprivate var localizedStringFileName: String!

    // MARK: - Inputs

    open var contactId: String? {
        didSet {
            if contactId != nil {
                chatId = contactId
            }
        }
    }

    open var channelKey: NSNumber? {
        didSet {
            if channelKey != nil {
                chatId = channelKey?.stringValue
            }
        }
    }

    open var isSearch: Bool = false
    open var lastMessage : ALMessage?
    internal static var lastSentMessage : ALMessage?

    // For topic based chat
    open var conversationProxy: ALConversationProxy? {
        didSet {
            if conversationProxy != nil {
                chatId = conversationProxy?.id?.stringValue
            }
        }
    }

    public weak var delegate: ALKConversationViewModelDelegate?

    // MARK: - Outputs

    open var isFirstTime = true
    var timer = Timer()
    var welcomeMessagePosition = 0
    open var emailCollectionAwayModeEnabled: Bool = false
    var modelsToBeAddedAfterDelay : [ALKMessageModel] = []

    open var isGroup: Bool {
        guard channelKey != nil else {
            return false
        }
        return true
    }

    // Prefilled message for chatbox.
    open var prefilledMessage: String?

    open var isContextBasedChat: Bool {
        guard conversationProxy == nil else { return true }
        guard
            let channelKey = channelKey,
            let alChannel = ALChannelService().getChannelByKey(channelKey),
            let metadata = alChannel.metadata,
            let contextBased = metadata["AL_CONTEXT_BASED_CHAT"] as? String
        else {
            return false
        }
        return contextBased.lowercased() == "true"
    }

    open var messageModels: [ALKMessageModel] = []
    
    open var conversationEndUserID: String {
        if _conversationEndUserID.isEmpty {
            getConversationEndUserID()
        }
        return _conversationEndUserID
    }

    private var _conversationEndUserID: String = ""

    open var richMessages: [String: Any] = [:]

    open var isOpenGroup: Bool {
        let alChannelService = ALChannelService()
        guard let channelKey = channelKey,
              let alchannel = alChannelService.getChannelByKey(channelKey)
        else {
            return false
        }
        return alchannel.type == 6
    }
    
    open var isWaitingQueueConversation: Bool {
        let alChannelService = ALChannelService()
        guard let channelKey = channelKey,
              let alchannel = alChannelService.getChannelByKey(channelKey),
              let conversationStatus = alchannel.metadata[AL_CHANNEL_CONVERSATION_STATUS] as? String
        else {
            return false
        }
        return conversationStatus == KMConversationStatus.waiting.rawValue
    }
    
    open var assignedTeamId: String? {
        let alChannelService = ALChannelService()
        guard let channelKey = channelKey,
              let alchannel = alChannelService.getChannelByKey(channelKey),
              let teamID = alchannel.metadata["KM_TEAM_ID"] as? String
        else {
            return nil
        }
        return teamID
    }
    
    // To get Conversation created time based on its first message.
    open var conversationCreatedTime: NSNumber? {
        if alMessages.isEmpty {
            return nil
        }
        return alMessages[0].createdAtTime
    }
    
    private var conversationId: NSNumber? {
        return conversationProxy?.id
    }

    private lazy var chatId: String? = conversationId?.stringValue ?? channelKey?.stringValue ?? contactId

    private let maxWidth = UIScreen.main.bounds.width
    private var alMessageWrapper = ALMessageArrayWrapper()

    open var alMessages: [ALMessage] = []

    private let mqttObject = ALMQTTConversationService.sharedInstance()

    /// Message on which reply was tapped.
    private var selectedMessageForReply: ALKMessageViewModel?

    private var shouldSendTyping: Bool = true

    private var typingTimerTask = Timer()
    private var groupMembers: Set<ALContact>?
    private var awsEncryptionPrefix = "AWS-ENCRYPTED"
    private var botDelayTime = 0

    // MARK: - Initializer
    public required init(
        contactId: String?,
        channelKey: NSNumber?,
        conversationProxy: ALConversationProxy? = nil,
        localizedStringFileName: String!,
        prefilledMessage: String? = nil
    ) {
        self.contactId = contactId
        self.channelKey = channelKey
        self.conversationProxy = conversationProxy
        self.localizedStringFileName = localizedStringFileName
        self.prefilledMessage = prefilledMessage
        ALKConversationViewModel.lastSentMessage = nil
    }

    // MARK: - Public methods

    public func prepareController() {
        let userDefaults = UserDefaults(suiteName: "group.kommunicate.sdk") ?? .standard
        botDelayTime = userDefaults.integer(forKey: "BOT_MESSAGE_DELAY_INTERVAL") / 1000
        
        if isSearch {
            delegate?.loadingStarted()
            loadSearchMessages()
            return
        }
        // Load messages from server in case of open group
        guard !isOpenGroup else {
            delegate?.loadingStarted()
            loadOpenGroupMessages()
            return
        }

        if ALUserDefaultsHandler.isServerCallDone(forMSGList: chatId) {
            delegate?.loadingStarted()
            loadMessagesFromDB()
        } else {
            delegate?.loadingStarted()
            loadMessages()
        }
    }

    public func addToWrapper(message: ALMessage) {
        guard !alMessageWrapper.contains(message: message) else { return }
        if messageModels.last?.contentType == .typingIndicator {
            removeTypingIndicatorMessage()
        }
        alMessageWrapper.addALMessage(toMessageArray: message)
        alMessages.append(message)
        messageModels.append(message.messageModel)
        if(message.isMyMessage){
            ALKConversationViewModel.lastSentMessage = message
        }
    }

    func clearViewModel() {
        isFirstTime = true
        emailCollectionAwayModeEnabled = false
        messageModels.removeAll()
        alMessages.removeAll()
        richMessages.removeAll()
        alMessageWrapper = ALMessageArrayWrapper()
        groupMembers = nil
        welcomeMessagePosition = 0
    }
    
    /// This method used to check a message is present in the viewmodel.
    /// - Parameters:
    ///   - message: Pass ALMessage object.
    public func containsMessage(_ message:ALMessage) -> Bool {
        guard !alMessages.isEmpty else{
            return false
        }
        return alMessages.contains(message)
    }

    open func groupProfileImgUrl() -> String {
        guard let message = alMessages.last, let imageUrl = message.avatarGroupImageUrl else {
            return ""
        }
        return imageUrl
    }

    open func groupName() -> String {
        guard let message = alMessages.last else {
            return ""
        }
        _ = alMessages.first?.createdAt
        return message.groupName
    }

    open func groupKey() -> NSNumber? {
        guard let message = alMessages.last else {
            return nil
        }
        return message.groupId
    }

    open func friends() -> [ALKFriendViewModel] {
        let alChannelService = ALChannelService()

        // TODO: This is a workaround as other method uses closure.
        // Later replace this with:
        // alChannelService.getChannelInformation(, orClientChannelKey: , withCompletion: )
        guard let message = alMessages.last, let alChannel = alChannelService.getChannelByKey(message.groupId) else {
            return []
        }

        guard let members = alChannel.membersId else { return [] }
        let membersId = members.map { $0 as? String }
        let alContactDbService = ALContactDBService()
        let alContacts = membersId.map { alContactDbService.loadContact(byKey: "userId", value: $0) }
        let models = alContacts.filter { $0?.userId != ALUserDefaultsHandler.getUserId() }.map { ALKFriendViewModel(identity: $0!) }
        print("all models: ", models.count)
        return models
    }

    open func numberOfSections() -> Int {
        return messageModels.count
    }

    open func numberOfRows(section _: Int) -> Int {
        return 1
    }

    open func messageForRow(indexPath: IndexPath) -> ALKMessageViewModel? {
        guard indexPath.section < messageModels.count, indexPath.section >= 0 else { return nil }
        return messageModels[indexPath.section]
    }

    open func quickReplyDictionary(message: ALKMessageViewModel?, indexRow row: Int) -> [String: Any]? {
        guard let metadata = message?.metadata else {
            return [String: Any]()
        }

        let payload = metadata["payload"] as? String

        let data = payload?.data
        var jsonArray: [[String: Any]]?

        do {
            jsonArray = (try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [[String: Any]])
            return jsonArray?[row]
        } catch let error as NSError {
            print(error)
        }
        return [String: Any]()
    }

    open func getSizeForItemAt(row _: Int, withData: [String: Any]) -> CGSize {
        let size = (withData["title"] as? String)?.size(withAttributes: [NSAttributedString.Key.font: Font.normal(size: 14.0).font()])
        let newSize = CGSize(width: (size?.width)! + 46.0, height: 50.0)
        return newSize
    }

    open func messageForRow(identifier: String) -> ALKMessageViewModel? {
        guard let messageModel = messageModels.filter({ $0.identifier == identifier }).first else { return nil }
        return messageModel
    }

    func sectionFor(identifier: String) -> Int? {
        return messageModels.firstIndex { $0.identifier == identifier }
    }

    open func heightForRow(indexPath: IndexPath, cellFrame _: CGRect, configuration: ALKConfiguration) -> CGFloat {
        let messageModel = messageModels[indexPath.section]
        var cacheIdentifier = (messageModel.isMyMessage ? "s-" : "r-") + messageModel.identifier
        let isActionButtonHidden = messageModel.isActionButtonHidden()
        if isActionButtonHidden {
            cacheIdentifier += "-h"
        }
        if let height = HeightCache.shared.getHeight(for: cacheIdentifier) {
            return height
        }
        switch messageModel.messageType {
        case .text, .html, .email:
            guard !configuration.isLinkPreviewDisabled, messageModel.messageType == .text, ALKLinkPreviewManager.extractURLAndAddInCache(from: messageModel.message, identifier: messageModel.identifier) != nil else {
                if let messageMetadata = messageModel.metadata, let metadataValue = messageMetadata[KMSourceURLIdentifier.sourceURLIdentifier], !messageModel.isMyMessage {
                    let height = KMFriendSourceURLViewCell.rowHeigh(viewModel: messageModel, width: maxWidth, displayNames: { userIds in
                        self.displayNames(ofUserIds: userIds)
                    })
                    return height.cached(with: cacheIdentifier)
                }
                if messageModel.isMyMessage {
                    let height = ALKMyMessageCell.rowHeigh(viewModel: messageModel, width: maxWidth, displayNames: { userIds in
                        self.displayNames(ofUserIds: userIds)
                    })
                    return height.cached(with: cacheIdentifier)
                } else {
                    let height = ALKFriendMessageCell.rowHeigh(viewModel: messageModel, width: maxWidth, displayNames: { userIds in
                        self.displayNames(ofUserIds: userIds)
                    })
                    return height.cached(with: cacheIdentifier)
                }
            }
            if messageModel.isMyMessage {
                let height = ALKMyLinkPreviewCell.rowHeigh(viewModel: messageModel, width: maxWidth, displayNames: { userIds in
                    self.displayNames(ofUserIds: userIds)
                })
                return height.cached(with: cacheIdentifier)
            } else {
                let height = ALKFriendLinkPreviewCell.rowHeigh(viewModel: messageModel, width: maxWidth, displayNames: { userIds in
                    self.displayNames(ofUserIds: userIds)
                })
                return height.cached(with: cacheIdentifier)
            }

        case .photo:
            if messageModel.isMyMessage {
                if messageModel.ratio < 1 {
                    let heigh = ALKMyPhotoPortalCell.rowHeigh(viewModel: messageModel, width: maxWidth)
                    return heigh.cached(with: cacheIdentifier)
                } else {
                    let heigh = ALKMyPhotoLandscapeCell.rowHeigh(viewModel: messageModel, width: maxWidth)
                    return heigh.cached(with: cacheIdentifier)
                }
            } else {
                if messageModel.ratio < 1 {
                    let heigh = ALKFriendPhotoPortalCell.rowHeigh(viewModel: messageModel, width: maxWidth)
                    return heigh.cached(with: cacheIdentifier)
                } else {
                    let heigh = ALKFriendPhotoLandscapeCell.rowHeigh(viewModel: messageModel, width: maxWidth)
                    return heigh.cached(with: cacheIdentifier)
                }
            }
        case .voice:
            var height: CGFloat = 0
            if messageModel.isMyMessage {
                height = ALKVoiceCell.rowHeigh(viewModel: messageModel, width: maxWidth)
            } else {
                height = ALKFriendVoiceCell.rowHeigh(viewModel: messageModel, width: maxWidth)
            }
            return height.cached(with: cacheIdentifier)
        case .information:
            let height = ALKInformationCell.rowHeigh(viewModel: messageModel, width: maxWidth)
            return height.cached(with: cacheIdentifier)
        case .location:
            return (messageModel.isMyMessage ? ALKMyLocationCell.rowHeigh(viewModel: messageModel, width: maxWidth).cached(with: cacheIdentifier) : ALKFriendLocationCell.rowHeigh(viewModel: messageModel, width: maxWidth)).cached(with: cacheIdentifier)
        case .video:
            var height: CGFloat = 0
            if messageModel.isMyMessage {
                height = ALKMyVideoCell.rowHeigh(viewModel: messageModel, width: maxWidth)
            } else {
                height = ALKFriendVideoCell.rowHeigh(viewModel: messageModel, width: maxWidth)
            }
            return height.cached(with: cacheIdentifier)
        case .cardTemplate:
            if messageModel.isMyMessage {
                return
                    ALKMyGenericCardMessageCell
                        .rowHeigh(viewModel: messageModel, width: maxWidth)
                        .cached(with: cacheIdentifier)
            } else {
                return
                    ALKFriendGenericCardMessageCell
                        .rowHeigh(viewModel: messageModel, width: maxWidth)
                        .cached(with: cacheIdentifier)
            }
        case .faqTemplate:
            guard let faqMessage = messageModel.faqMessage() else { return 0 }
            if messageModel.isMyMessage {
                return SentFAQMessageCell.rowHeight(model: faqMessage).cached(with: cacheIdentifier)
            } else {
                return ReceivedFAQMessageCell.rowHeight(model: faqMessage).cached(with: cacheIdentifier)
            }

        case .quickReply:
            if messageModel.isMyMessage {
                return
                    ALKMyMessageQuickReplyCell
                        .rowHeight(viewModel: messageModel, maxWidth: UIScreen.main.bounds.width)
                        .cached(with: cacheIdentifier)
            } else {
                return
                    ALKFriendMessageQuickReplyCell
                        .rowHeight(viewModel: messageModel, maxWidth: UIScreen.main.bounds.width)
            }
        case .button:
            if messageModel.isMyMessage {
                return
                    ALKMyMessageButtonCell
                        .rowHeigh(viewModel: messageModel, width: UIScreen.main.bounds.width)
                        .cached(with: cacheIdentifier)
            } else {
                return
                    ALKFriendMessageButtonCell
                        .rowHeigh(viewModel: messageModel, width: UIScreen.main.bounds.width)
                        .cached(with: cacheIdentifier)
            }
        case .listTemplate:
            if messageModel.isMyMessage {
                return
                    ALKMyMessageListTemplateCell
                        .rowHeight(viewModel: messageModel, maxWidth: UIScreen.main.bounds.width)
                        .cached(with: cacheIdentifier)
            } else {
                return
                    ALKFriendMessageListTemplateCell
                        .rowHeight(viewModel: messageModel, maxWidth: UIScreen.main.bounds.width)
                        .cached(with: cacheIdentifier)
            }
        case .document:
            if messageModel.isMyMessage {
                return
                    ALKMyDocumentCell
                        .rowHeigh(viewModel: messageModel, width: maxWidth)
                        .cached(with: cacheIdentifier)
            } else {
                return
                    ALKFriendDocumentCell
                        .rowHeigh(viewModel: messageModel, width: maxWidth)
                        .cached(with: cacheIdentifier)
            }
        case .imageMessage:
            guard let imageMessage = messageModel.imageMessage() else { return 0 }
            if messageModel.isMyMessage {
                return
                    SentImageMessageCell
                        .rowHeight(model: imageMessage)
                        .cached(with: cacheIdentifier)
            } else {
                return
                    ReceivedImageMessageCell
                        .rowHeight(model: imageMessage)
                        .cached(with: cacheIdentifier)
            }
        case .allButtons:
            guard let model = messageModel.allButtons() else { return 0 }
            if messageModel.isMyMessage {
                return
                    SentButtonsCell
                        .rowHeight(model: model)
                        .cached(with: cacheIdentifier)
            } else {
                return
                    ReceivedButtonsCell
                        .rowHeight(model: model)
                        .cached(with: cacheIdentifier)
            }
        case .form:
            return 0
        case .staticTopMessage:
            return KMStaticTopMessageCell.rowHeight(model: messageModel, width: maxWidth)
        case .videoTemplate:
            return KMVideoTemplateCell.rowHeigh(viewModel: messageModel, width: maxWidth)
        case .typingIndicator:
            return 60.0
        }
    }

    open func nextPage() {
        if isSearch {
            loadSearchMessages()
            return
        }
        guard !isOpenGroup else {
            loadOpenGroupMessages()
            return
        }
        self.delegate?.loadingStarted()
        loadMessagesFromDB()
    }

    open func getContextTitleData() -> ALKContextTitleDataType? {
        guard isContextBasedChat else { return nil }
        if let proxy = conversationProxy, let topicDetail = proxy.getTopicDetail() {
            return topicDetail
        } else {
            guard let metadata = ALChannelService().getChannelByKey(channelKey)?.metadata else { return nil }
            let topicDetail = ALTopicDetail()
            topicDetail.title = metadata["title"] as? String
            topicDetail.subtitle = metadata["price"] as? String
            topicDetail.link = metadata["link"] as? String
            return topicDetail
        }
    }

    open func getMessageTemplates() -> [ALKTemplateMessageModel]? {
        // Get the json from the root folder, parse it and map it.
        let bundle = Bundle.main
        guard let jsonPath = bundle.path(forResource: "message_template", ofType: "json")
        else {
            return nil
        }
        do {
            let fileUrl = URL(fileURLWithPath: jsonPath)
            let data = try Data(contentsOf: fileUrl, options: .mappedIfSafe)
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
            if let json = jsonResult as? [String: Any],
               let templates = json["templates"] as? [Any]
            {
                NSLog("Template json: ", json.description)
                var templateModels: [ALKTemplateMessageModel] = []
                for element in templates {
                    if let template = element as? [String: Any],
                       let model = ALKTemplateMessageModel(json: template)
                    {
                        templateModels.append(model)
                    }
                }
                return templateModels
            }
        } catch {
            NSLog("Error while fetching template json: \(error.localizedDescription)")
            return nil
        }
        return nil
    }

    open func downloadAttachment(message: ALKMessageViewModel, view: UIView) {
        guard ALDataNetworkConnection.checkDataNetworkAvailable() else {
            let notificationView = ALNotificationView()
            notificationView.noDataConnectionNotificationView()
            return
        }
        // if ALApplozicSettings.isS3StorageServiceEnabled or ALApplozicSettings.isGoogleCloudServiceEnabled is true its private url we wont be able to download it directly.
        let serviceEnabled = ALApplozicSettings.isS3StorageServiceEnabled() || ALApplozicSettings.isGoogleCloudServiceEnabled()

        if message.fileMetaInfo!.name.hasPrefix(awsEncryptionPrefix) {
          ALMessageClientService().downloadImageUrlV2(message.fileMetaInfo?.blobKey,isS3URL: true) { fileUrl, error in
               guard error == nil, let fileUrl = fileUrl else {
                   print("Error downloading attachment :: \(String(describing: error))")
                   return
               }
               let httpManager = ALKHTTPManager()
               httpManager.downloadDelegate = view as? ALKHTTPManagerDownloadDelegate
               let task = ALKDownloadTask(downloadUrl: fileUrl, fileName: message.fileMetaInfo?.name)
               task.identifier = message.identifier
               task.totalBytesExpectedToDownload = message.size
               httpManager.downloadCompleted = { [weak self] task in
                   guard let weakSelf = self, let identifier = task.identifier else { return }
                   var msg = weakSelf.messageForRow(identifier: identifier)
                   if ThumbnailIdentifier.hasPrefix(in: identifier) {
                       msg?.fileMetaInfo?.thumbnailFilePath = task.filePath
                   } else {
                       msg?.filePath = task.filePath
                   }
               }
               httpManager.downloadAttachment(task: task)
           }
           return
       }
        
        if let url = message.fileMetaInfo?.url,
           !serviceEnabled
        {
            let httpManager = ALKHTTPManager()
            httpManager.downloadDelegate = view as? ALKHTTPManagerDownloadDelegate
            let task = ALKDownloadTask(downloadUrl: url, fileName: message.fileMetaInfo?.name)
            task.identifier = message.identifier
            task.totalBytesExpectedToDownload = message.size
            httpManager.downloadImage(task: task)
            httpManager.downloadCompleted = { [weak self] task in
                guard let weakSelf = self, let identifier = task.identifier else { return }
                var msg = weakSelf.messageForRow(identifier: identifier)
                if ThumbnailIdentifier.hasPrefix(in: identifier) {
                    msg?.fileMetaInfo?.thumbnailFilePath = task.filePath
                } else {
                    msg?.filePath = task.filePath
                }
            }
            return
        }
        
        ALMessageClientService().downloadImageUrlV2(message.fileMetaInfo?.blobKey, isS3URL: message.fileMetaInfo?.url != nil ) { fileUrl, error in
            guard error == nil, let fileUrl = fileUrl else {
                print("Error downloading attachment :: \(String(describing: error))")
                return
            }
            let httpManager = ALKHTTPManager()
            httpManager.downloadDelegate = view as? ALKHTTPManagerDownloadDelegate
            let task = ALKDownloadTask(downloadUrl: fileUrl, fileName: message.fileMetaInfo?.name)
            task.identifier = message.identifier
            task.totalBytesExpectedToDownload = message.size
            httpManager.downloadCompleted = { [weak self] task in
                guard let weakSelf = self, let identifier = task.identifier else { return }
                var msg = weakSelf.messageForRow(identifier: identifier)
                if ThumbnailIdentifier.hasPrefix(in: identifier) {
                    msg?.fileMetaInfo?.thumbnailFilePath = task.filePath
                } else {
                    msg?.filePath = task.filePath
                }
            }
            httpManager.downloadAttachment(task: task)
        }
    }

    /// Received from notification
    open func addMessagesToList(_ messageList: [Any]) {
        guard let messages = messageList as? [ALMessage] else { return }

        var filteredArray = [ALMessage]()

        for message in messages {
            if channelKey != nil, channelKey == message.groupId {
                filteredArray.append(message)
            } else if message.channelKey == nil, channelKey == nil, contactId == message.to {
                filteredArray.append(message)
            }
        }

        var sortedArray = filteredArray.filter {
            !alMessageWrapper.contains(message: $0)
        }
        if sortedArray.count > 1 {
            sortedArray.sort { Int(truncating: $0.createdAtTime) < Int(truncating: $1.createdAtTime) }
        }
        guard !sortedArray.isEmpty else { return }
        
        ALKCustomEventHandler.shared.publish(triggeredEvent: KMCustomEvent.messageReceive, data: ["messageList":sortedArray])
        if alMessages.isEmpty, !KMConversationScreenConfiguration.staticTopMessage.isEmpty {
            sortedArray.insert(getInitialStaticFirstMessage(), at: 0)
        }
        _ = sortedArray.map { self.alMessageWrapper.addALMessage(toMessageArray: $0) }
        alMessages.append(contentsOf: sortedArray)
        let models = sortedArray.map { $0.messageModel }
        messageModels.append(contentsOf: models)
        print("new messages: ", models.map { $0.message })
        self.removeTypingIndicatorMessage()
        delegate?.newMessagesAdded()
        newFormMessageAdded()
    }
    
    @objc open func newFormMessageAdded() {
        let indexPath = IndexPath(row: 0, section: messageModels.count - 1)
        if let lastMessage = messageModels.last {
            reloadIfFormMessage(message: lastMessage, indexPath: indexPath)
        }
    }
    
    func reloadIfFormMessage(message: ALKMessageModel, indexPath: IndexPath) {
        guard message.messageType == .form else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
            self.delegate?.messageUpdated()
        })
    }
    
    private func getInitialStaticFirstMessage() -> ALMessage {
        let initialMessage = ALMessage()
        initialMessage.message = KMConversationScreenConfiguration.staticTopMessage
        initialMessage.contentType = Int16(ALMESSAGE_CONTENT_INITIAL_STATIC_MESSAGE)
        let date = Date().timeIntervalSince1970 * 1000
        initialMessage.createdAtTime = NSNumber(value: date)
        return initialMessage
    }
    
    private func getTypingIndicatorMessage() -> ALMessage {
        let typingIndicatorMessage = ALMessage()
        typingIndicatorMessage.contentType = Int16(ALMESSAGE_CONTENT_TYPING_INDICATOR)
        let date = Date().timeIntervalSince1970 * 1000
        typingIndicatorMessage.createdAtTime = NSNumber(value: date)
        return typingIndicatorMessage
    }

    open func markConversationRead() {
        if let channelKey = channelKey {
            print("mark read1")
            ALChannelService.sharedInstance().markConversation(asRead: channelKey, withCompletion: {
                _, error in
                print("mark read")
                if let error = error {
                    NSLog("error while marking conversation read: \(error)")
                }
            })
        } else if let contactId = contactId {
            ALUserService.sharedInstance().markConversation(asRead: contactId, withCompletion: {
                _, error in
                if let error = error {
                    NSLog("error while marking conversation read: \(error)")
                }
            })
        }
    }

    open func updateGroup(groupName: String, groupImage: String?, friendsAdded: [ALKFriendViewModel]) {
        if !groupName.isEmpty || groupImage != nil {
            updateGroupInfo(groupName: groupName, groupImage: groupImage, completion: { success in
                self.updateInfo()
                guard success, !friendsAdded.isEmpty else { return }
                self.addMembersToGroup(users: friendsAdded, completion: { _ in
                    print("group addition was succesful")
                })
            })
        } else {
            updateInfo()
            guard !friendsAdded.isEmpty else { return }
            addMembersToGroup(users: friendsAdded, completion: { _ in
                print("group addition was succesful")
            })
        }
    }

    open func updateDeliveryReport(messageKey: String, status: Int32) {
        let mesgArray = alMessages
        guard !mesgArray.isEmpty else { return }
        let filteredList = mesgArray.filter { ($0.key != nil) ? $0.key == messageKey : false }
        if !filteredList.isEmpty {
            updateMessageStatus(filteredList: filteredList, status: status)
        } else {
            guard let mesgFromService = ALMessageService
                .getMessagefromKeyValuePair("key", andValue: messageKey),
                let objectId = mesgFromService.msgDBObjectId else { return }
            let newFilteredList = mesgArray
                .filter { ($0.msgDBObjectId != nil) ? $0.msgDBObjectId == objectId : false }
            updateMessageStatus(filteredList: newFilteredList, status: status)
        }
    }

    open func updateStatusReportForConversation(contactId: String, status: Int32) {
        guard let id = self.contactId, id == contactId else { return }
        let mesgArray = alMessages
        guard !mesgArray.isEmpty else { return }
        for index in 0 ..< mesgArray.count {
            let mesg = mesgArray[index]
            if mesg.status != nil, mesg.status != NSNumber(value: status), mesg.sentToServer == true {
                mesg.status = status as NSNumber
                alMessages[index] = mesg
                messageModels[index] = mesg.messageModel
                delegate?.updateMessageAt(indexPath: IndexPath(row: 0, section: index))
            }
            guard index < messageModels.count else { return }
        }
    }

    open func updateSendStatus(message: ALMessage) {
        let filteredList = alMessages.filter { $0 == message }
        if let alMessage = filteredList.first, let index = alMessages.firstIndex(of: alMessage) {
            alMessage.sentToServer = true
            alMessages[index] = alMessage
            messageModels[index] = alMessage.messageModel
            delegate?.updateMessageAt(indexPath: IndexPath(row: 0, section: index))
        } else {
            loadMessagesFromDB()
        }
    }

    open func send(message: String, isOpenGroup: Bool = false, metadata: [AnyHashable: Any]?) {
        let alMessage = getMessageToPost(isTextMessage: true)
        alMessage.message = message
        alMessage.metadata = modfiedMessageMetadata(alMessage: alMessage, metadata: metadata)
        updateMetaDataForCustomField(message : alMessage)
        
        if let kmField = alMessages.last?.messageModel.getKmField() {
            if(!isValidReply(message: alMessage)){
                delegate?.showInvalidReplyAlert(kmField: kmField)
                return
            }
            updateUser(kmField: kmField, message: alMessage.message)
        }
        
        if emailCollectionAwayModeEnabled {
            if(!message.isValidEmail()) {
                delegate?.isEmailSentForUpdatingUser(status: false)
                return
            }
            emailCollectionAwayModeEnabled = false
            updateEmailFromCollectEmail(email: message)
            delegate?.isEmailSentForUpdatingUser(status: true)
        }
            
        var indexPath = IndexPath(row: 0, section: messageModels.count - 1)
        if !alMessage.isHiddenMessage() {
            addToWrapper(message: alMessage)
            indexPath = IndexPath(row: 0, section: messageModels.count - 1)
            delegate?.messageSent(at: indexPath)
        }
        if isOpenGroup {
            let messageClientService = ALMessageClientService()
            messageClientService.sendMessage(alMessage.dictionary(), withCompletionHandler: { _, error in
                guard error == nil, indexPath.section < self.messageModels.count else { return }
                NSLog("No errors while sending the message in open group")
                self.showTypingIndicatorAfterMessageSent()
                ALKCustomEventHandler.shared.publish(triggeredEvent: KMCustomEvent.messageSend, data: ["message":alMessage])
                #if canImport(ChatProvidersSDK)
                    if KMZendeskChatHandler.shared.isZendeskEnabled()  {
                        KMZendeskChatHandler.shared.sendMessage(message: alMessage)
                    }
                #endif
                guard !alMessage.isHiddenMessage() else {return}
                alMessage.status = NSNumber(integerLiteral: Int(SENT.rawValue))
                self.messageModels[indexPath.section] = alMessage.messageModel
                self.delegate?.updateMessageAt(indexPath: indexPath)
            })
        } else {
            ALMessageService.sharedInstance().sendMessages(alMessage, withCompletion: { _, error in
                NSLog("Message sent section: \(indexPath.section), \(String(describing: alMessage.message))")
                guard error == nil, indexPath.section < self.messageModels.count else { return }
                NSLog("No errors while sending the message")
                self.showTypingIndicatorAfterMessageSent()
                ALKCustomEventHandler.shared.publish(triggeredEvent: KMCustomEvent.messageSend, data: ["message":alMessage])
                #if canImport(ChatProvidersSDK)
                    if KMZendeskChatHandler.shared.isZendeskEnabled()  {
                        KMZendeskChatHandler.shared.sendMessage(message: alMessage)
                    }
                #endif
                guard !alMessage.isHiddenMessage() else {return}
                alMessage.status = NSNumber(integerLiteral: Int(SENT.rawValue))
                self.messageModels[indexPath.section] = alMessage.messageModel
                self.delegate?.updateMessageAt(indexPath: indexPath)
            })
        }
    }
    
    func updateMetaDataForCustomField(message : ALMessage){
        if let lastMessage = alMessages.last?.messageModel,
           let replyMetaData = lastMessage.getReplyMetaData() {
            message.metadata.addEntries(from: replyMetaData)
        }
    }
    
    func updateEmailFromCollectEmail(email: String) {
        ALUserClientService().updateUser(nil, email: email, ofUser: nil) { theJson, error in
            if(error == nil){
                print("User's email updated")
                self.delegate?.emailUpdatedForUser()
            } else {
                print("error occured while updating user's email \(String(describing: error?.localizedDescription))")
            }
        }
    }
    
    func updateUser(kmField: KMField, message: String) {
        guard let fieldType = kmField.fieldType,
              let action = kmField.action,
              let _ = action.updateUserDetails
        else {
            return
        }
        
        let alUserClientService = ALUserClientService()
        
        switch(fieldType.lowercased()){
        case "name":
            alUserClientService.updateUserDisplayName(message, andUserImageLink: nil, userStatus: nil, metadata: nil) { theJson, error in
                if(error == nil){
                    print("User's display name updated")
                } else {
                    print("error occured while updating user's display name \(error?.localizedDescription)")
                }
            }
        case "email":
            alUserClientService.updateUser(nil, email: message, ofUser: nil) { theJson, error in
                if(error == nil){
                    print("User's email updated")
                } else {
                    print("error occured while updating user's email \(error?.localizedDescription)")
                }
            }
        case "phone_number":
            alUserClientService.updateUser(message, email: nil, ofUser: nil) { theJson, error in
                if(error == nil){
                    print("User's phone number updated")
                } else {
                    print("error occured while updating user's phone number \(error?.localizedDescription)")
                }
            }
        default:
            alUserClientService.updateUserDisplayName(nil , andUserImageLink: nil, userStatus: nil, metadata: [kmField.field : message]) { theJson, error in
                if(error == nil){
                    print("User info updated")
                } else {
                    print("error occured while updating user info \(error?.localizedDescription)")
                }
            }
        }
    }
    
    func isValidReply(message : ALMessage) -> Bool {

        guard let lastMessage = alMessages.last?.messageModel,
              let kmField = lastMessage.getKmField(),
              let messageText = message.message,
              let validation = kmField.validation,
              let regex = validation["regex"] else {
            return true
        }

        do{
            return try ALKRegexValidator.matchPattern(text: messageText, pattern: regex)
        } catch {
            guard let fieldType = kmField.fieldType else {
                return true
            }
            switch(fieldType.lowercased()){
            case "email" :
                return fieldType.isValidEmail(email: messageText)
            case "phone_number" :
                return fieldType.isValidPhoneNumber
            default:
                return true
            }
        }
    }
    
    func showTypingIndicatorAfterMessageSent() {
        // If KMConversationScreenConfiguration.showTypingIndicatorWhileFetchingResponse is true and assignee is bot then typing indicator will be shown
        guard KMConversationScreenConfiguration.showTypingIndicatorWhileFetchingResponse,
              !self.alMessages.isEmpty,
              let channel = ALChannelService().getChannelByKey(self.alMessages[0].groupId as NSNumber),
              let assigneeUserId = channel.assigneeUserId,
              let alContact = ALContactService().loadContact(byKey: "userId", value:  assigneeUserId),
              alContact.roleType == NSNumber.init(value: AL_BOT.rawValue)
        else { return }
        self.delegate?.updateTyingStatus(status: true, userId:alContact.displayName)

    }

    func modfiedMessageMetadata(alMessage: ALMessage, metadata: [AnyHashable: Any]?) -> NSMutableDictionary {
        var metaData = NSMutableDictionary()

        if alMessage.metadata != nil {
            metaData = alMessage.metadata
        }

        if let messageMetadata = metadata, !messageMetadata.isEmpty {
            metaData.addEntries(from: messageMetadata)
        }
        for (key, value) in metaData {
            guard let value = value as? [AnyHashable: Any] else { continue }
            metaData[key] = ALUtilityClass.generateJsonString(from: value)
        }
        
        let languageCode = NSLocale.preferredLanguages.first?.prefix(2)
        
        updateMessageMetadataChatContext(info: ["kmUserLocale" : languageCode as Any], metadata: metaData)
        
        return metaData
    }
    
    func updateMessageMetadataChatContext(info: [String: Any], metadata : NSMutableDictionary) {
        var context: [String: Any] = [:]

        do {
            let contextDict = try chatContextFromMessageMetadata(messageMetadata: metadata as? [AnyHashable : Any])
            context = contextDict ?? [:]
            context.merge(info, uniquingKeysWith: { $1 })

            let messageInfoData = try JSONSerialization
                .data(withJSONObject: context, options: .prettyPrinted)
            let messageInfoString = String(data: messageInfoData, encoding: .utf8) ?? ""
            metadata["KM_CHAT_CONTEXT"] = messageInfoString
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func chatContextFromMessageMetadata(messageMetadata : [AnyHashable: Any]?) -> [String: Any]? {
        guard
            let messageMetadata = messageMetadata,
            let chatContext = messageMetadata["KM_CHAT_CONTEXT"] as? String,
            let contextData = chatContext.data(using: .utf8)
        else {
            return nil
        }
        do {
            let contextDict = try JSONSerialization
                .jsonObject(with: contextData, options: .allowFragments) as? [String: Any]
            return contextDict
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }

    open func send(photo: UIImage, metadata: [AnyHashable: Any]?, caption: String) -> (ALMessage?, IndexPath?) {
        print("image is:  ", photo)
        let filePath = ALKFileUtils().saveImageToDocDirectory(image: photo)
        print("filepath:: \(String(describing: filePath))")
        guard let path = filePath, let url = URL(string: path) else { return (nil, nil) }
        guard let alMessage = processAttachment(
            filePath: url,
            text: caption,
            contentType: Int(ALMESSAGE_CONTENT_ATTACHMENT),
            metadata: metadata
        ) else {
            return (nil, nil)
        }
        addToWrapper(message: alMessage)
        return (alMessage, IndexPath(row: 0, section: messageModels.count - 1))
    }

    open func send(voiceMessage: Data, metadata: [AnyHashable: Any]?) {
        print("voice data received: ", voiceMessage.count)
        let fileName = String(format: "AUD-%f.m4a", Date().timeIntervalSince1970 * 1000)
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fullPath = documentsURL.appendingPathComponent(fileName)
        do {
            try voiceMessage.write(to: fullPath, options: .atomic)
        } catch {
            NSLog("error when saving the voice message")
        }
        guard let alMessage = processAttachment(
            filePath: fullPath,
            text: "",
            contentType: Int(ALMESSAGE_CONTENT_AUDIO),
            metadata: metadata
        ) else { return }
        addToWrapper(message: alMessage)
        delegate?.messageSent(at: IndexPath(row: 0, section: messageModels.count - 1))
        uploadAudio(alMessage: alMessage, indexPath: IndexPath(row: 0, section: messageModels.count - 1))
    }
    
    open func addTypingIndicatorMessage(_ isAgentApp: Bool) {
        if alMessages.contains(where: { $0.contentType == Int16(ALMESSAGE_CONTENT_TYPING_INDICATOR) }) {
            self.removeTypingIndicatorMessage()
        }
        guard !isAgentApp || alMessages.count != 0 else { return }
        addToWrapper(message: getTypingIndicatorMessage())
        self.delegate?.newMessagesAdded()
    }
    
    open func removeTypingIndicatorMessage() {
        if alMessages.contains(where: { $0.contentType == Int16(ALMESSAGE_CONTENT_TYPING_INDICATOR) }) {
            alMessages.removeAll { $0.contentType == Int16(ALMESSAGE_CONTENT_TYPING_INDICATOR)}
            messageModels.removeAll {$0.contentType.rawValue == getTypingIndicatorMessage().contentType}
            self.delegate?.messageUpdated()
        }
    }
    
    open func add(geocode: Geocode, metadata: [AnyHashable: Any]?) -> (ALMessage?, IndexPath?) {
        let latlonString = ["lat": "\(geocode.location.latitude)", "lon": "\(geocode.location.longitude)"]
        guard let jsonString = createJson(dict: latlonString) else { return (nil, nil) }
        let message = getLocationMessage(latLonString: jsonString)
        message.metadata = modfiedMessageMetadata(alMessage: message, metadata: metadata)
        addToWrapper(message: message)
        let indexPath = IndexPath(row: 0, section: messageModels.count - 1)
        return (message, indexPath)
    }

    open func sendGeocode(message: ALMessage, indexPath: IndexPath) {
        send(alMessage: message) { updatedMessage in
            guard let mesg = updatedMessage else { return }
            DispatchQueue.main.async {
                print("UI updated at section: ", indexPath.section, message.isSent)
                message.status = NSNumber(integerLiteral: Int(SENT.rawValue))
                self.alMessages[indexPath.section] = mesg
                self.messageModels[indexPath.section] = mesg.messageModel
                self.delegate?.updateMessageAt(indexPath: indexPath)
            }
        }
    }

    open func sendVideo(atPath path: String, sourceType: UIImagePickerController.SourceType, metadata: [AnyHashable: Any]?, caption: String) -> (ALMessage?, IndexPath?) {
        guard let url = URL(string: path) else { return (nil, nil) }
        var contentType = ALMESSAGE_CONTENT_ATTACHMENT
        if sourceType == .camera {
            contentType = ALMESSAGE_CONTENT_CAMERA_RECORDING
        }

        guard let alMessage = processAttachment(filePath: url, text: caption, contentType: Int(contentType), isVideo: true, metadata: metadata) else { return (nil, nil) }
        addToWrapper(message: alMessage)
        return (alMessage, IndexPath(row: 0, section: messageModels.count - 1))
    }

    open func uploadVideo(view: UIView, indexPath: IndexPath) {
        let alMessage = alMessages[indexPath.section]
        let messageService = ALMessageDBService()
        let alHandler = ALDBHandler.sharedInstance()
        guard let dbMessage = messageService.getMeesageBy(alMessage.msgDBObjectId) as? DB_Message else {
            return
        }

        dbMessage.inProgress = 1
        dbMessage.isUploadFailed = 0

        let error = alHandler?.saveContext()
        if error != nil {
            print("Not saved due to error \(String(describing: error))")
            return
        }
        print("content type: ", alMessage.fileMeta.contentType ?? "")
        print("file path: ", alMessage.imageFilePath ?? "")
        let uploadManager = ALKVideoUploadManager()
        uploadManager.uploadDelegate = view as? ALKHTTPManagerUploadDelegate
        uploadManager.uploadCompleted = { [weak self] responseDict, task in
            if task.uploadError == nil, task.completed {
                self?.uploadAttachmentCompleted(responseDict: responseDict, indexPath: indexPath)
            }
        }
        uploadManager.uploadVideo(alMessage: alMessage)
    }

    // FIXME: Remove indexpath from this call and add message id param. Currently there is an unneccessary dependency on the indexpath.
    open func uploadAttachmentCompleted(responseDict: Any?, indexPath: IndexPath) {
        // populate metadata and send message
        guard alMessages.count > indexPath.section else { return }
        let alMessage = alMessages[indexPath.section]
        let messageService = ALMessageDBService()
        let alHandler = ALDBHandler.sharedInstance()
        guard let dbMessage = messageService.getMeesageBy(alMessage.msgDBObjectId) as? DB_Message,
              let message = messageService.createMessageEntity(dbMessage) else { return }
        

        guard let fileInfo = responseDict as? [String: Any] else { return }

        if let uploadUrl = ALApplozicSettings.getDefaultOverrideuploadUrl(), !uploadUrl.isEmpty,let metadata = fileInfo["metadata"] as? [String:Any] {
            message.metadata = modfiedMessageMetadata(alMessage: message, metadata: metadata)
        } else if ALApplozicSettings.isS3StorageServiceEnabled() {
            message.fileMeta.populate(fileInfo)
        } else {
            guard let fileMeta = fileInfo["fileMeta"] as? [String: Any] else { return }
            message.fileMeta.populate(fileMeta)
        }
        
        if let contentType = dbMessage.fileMetaInfo.contentType, contentType.hasPrefix("video") {
            let thumbnailUrl = dbMessage.fileMetaInfo.thumbnailUrl
            let thumbnailBlobKeyString = dbMessage.fileMetaInfo.thumbnailBlobKeyString
            message.fileMeta.thumbnailBlobKey = thumbnailBlobKeyString
            message.fileMeta.thumbnailUrl = thumbnailUrl
            dbMessage.fileMetaInfo.thumbnailBlobKeyString = thumbnailBlobKeyString
            dbMessage.fileMetaInfo.thumbnailUrl = thumbnailUrl
        }

        message.status = NSNumber(integerLiteral: Int(SENT.rawValue))
        
        let error = alHandler?.saveContext()
        if error != nil {
            print("Not saved due to error \(String(describing: error))")
            return
        }
        
        send(alMessage: message) {
            updatedMessage in
            guard let mesg = updatedMessage else { return }
            DispatchQueue.main.async {
                NSLog("UI updated at section: \(indexPath.section), \(message.isSent)")
                if let uploadUrl = ALApplozicSettings.getDefaultOverrideuploadUrl(), !uploadUrl.isEmpty {
                    // while storing message type was photo.Since Attachment is uploaded to client server, now its a rich message. thatswhy replacing it in DB.
                    messageService.deleteMessage(byKey: message.key)
                    messageService.add(updatedMessage)
                }
                self.showTypingIndicatorAfterMessageSent()
                self.alMessages[indexPath.section] = mesg
                self.messageModels[indexPath.section] = mesg.messageModel
                self.delegate?.updateMessageAt(indexPath: indexPath)
            }
        }
    }

    open func updateMessageModelAt(indexPath: IndexPath, data: Data) {
        var message = messageForRow(indexPath: indexPath)
        message?.voiceData = data
        messageModels[indexPath.section] = message as! ALKMessageModel
        delegate?.updateMessageAt(indexPath: indexPath)
    }

    @objc func sendTypingStatus() {
        mqttObject?.sendTypingStatus(ALUserDefaultsHandler.getApplicationKey(), userID: contactId, andChannelKey: channelKey, typing: true)
    }

    open func sendKeyboardBeginTyping() {
        guard shouldSendTyping else { return }
        shouldSendTyping = false
        sendTypingStatus()
        typingTimerTask = Timer.scheduledTimer(timeInterval: 25.0, target: self, selector: #selector(sendTypingStatus), userInfo: nil, repeats: true)
    }

    open func sendKeyboardDoneTyping() {
        shouldSendTyping = true
        typingTimerTask.invalidate()
        mqttObject?.sendTypingStatus(ALUserDefaultsHandler.getApplicationKey(), userID: contactId, andChannelKey: channelKey, typing: false)
    }

    func syncOpenGroup(message: ALMessage) {
        guard let groupId = message.groupId,
              groupId == channelKey,
              !message.isMyMessage,
              message.deviceKey != ALUserDefaultsHandler.getDeviceKeyString()
        else {
            return
        }
        addMessagesToList([message])
    }

    open func refresh() {
        if let key = channelKey, ALChannelService.isChannelDeleted(key) {
            return
        }
        delegate?.loadingStarted()
        guard !isOpenGroup else {
            loadOpenGroupMessages()
            return
        }
        ALMessageService.getLatestMessage(
            forUser: ALUserDefaultsHandler.getDeviceKeyString(),
            withCompletion: { messageList, error in
                self.delegate?.loadingFinished(error: error)
                guard error == nil,
                      let messages = messageList as? [ALMessage],
                      !messages.isEmpty else { return }
                self.loadMessagesFromDB()
            }
        )
    }

    open func uploadAudio(alMessage: ALMessage, indexPath: IndexPath) {
        let clientService = ALMessageClientService()
        let messageService = ALMessageDBService()
        let alHandler = ALDBHandler.sharedInstance()

        guard let dbMessage = messageService.getMeesageBy(alMessage.msgDBObjectId) as? DB_Message else {
            return
        }

        dbMessage.inProgress = 1
        dbMessage.isUploadFailed = 0
        let error = alHandler?.saveContext()
        if error != nil {
            print("Not saved due to error \(String(describing: error))")
            return
        }
        NSLog("content type: ", alMessage.fileMeta.contentType)
        NSLog("file path: ", alMessage.imageFilePath)
        clientService.sendPhoto(forUserInfo: alMessage.dictionary(), withCompletion: {
            urlStr, error in
            guard error == nil, let urlStr = urlStr, let url = URL(string: urlStr) else { return }
            let task = ALKUploadTask(url: url, fileName: alMessage.fileMeta.name)
            task.identifier = alMessage.key
            task.contentType = alMessage.fileMeta.contentType
            task.filePath = alMessage.imageFilePath
            task.groupdId = alMessage.groupId.stringValue
            let downloadManager = ALKHTTPManager()
            downloadManager.uploadAttachment(task: task)
            downloadManager.uploadCompleted = { [weak self] responseDict, task in
                if task.uploadError == nil, task.completed {
                    self?.uploadAttachmentCompleted(responseDict: responseDict, indexPath: indexPath)
                }
            }
        })
    }

    open func uploadImage(view: UIView, indexPath: IndexPath) {
        let alMessage = alMessages[indexPath.section]
        let clientService = ALMessageClientService()
        let messageService = ALMessageDBService()
        let alHandler = ALDBHandler.sharedInstance()
        guard let dbMessage = messageService.getMeesageBy(alMessage.msgDBObjectId) as? DB_Message else {
            return
        }
        dbMessage.inProgress = 1
        dbMessage.isUploadFailed = 0
        let error = alHandler?.saveContext()
        if error != nil {
            print("Not saved due to error \(String(describing: error))")
            return
        }
        NSLog("content type: ", alMessage.fileMeta.contentType)
        NSLog("file path: ", alMessage.imageFilePath)
        clientService.sendPhoto(forUserInfo: alMessage.dictionary(), withCompletion: {
            urlStr, error in
            guard error == nil, let urlStr = urlStr, let url = URL(string: urlStr) else { return }
            let task = ALKUploadTask(url: url, fileName: alMessage.fileMeta.name)
            task.identifier = alMessage.key
            task.contentType = alMessage.fileMeta.contentType
            task.filePath = alMessage.imageFilePath
            task.groupdId = alMessage.groupId.stringValue
            let downloadManager = ALKHTTPManager()
            downloadManager.uploadDelegate = view as? ALKHTTPManagerUploadDelegate
            downloadManager.uploadAttachment(task: task)
            downloadManager.uploadCompleted = { [weak self] responseDict, task in
                if task.uploadError == nil, task.completed {
                    self?.uploadAttachmentCompleted(responseDict: responseDict, indexPath: indexPath)
                }
            }
        })
    }

    open func encodeVideo(videoURL: URL, completion: @escaping (_ path: String?) -> Void) {
        guard let videoURL = URL(string: "file://\(videoURL.path)") else { return }

        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let myDocumentPath = URL(fileURLWithPath: documentsDirectory).appendingPathComponent(String(format: "VID-%f.MOV", Date().timeIntervalSince1970 * 1000))
        do {
            let data = try Data(contentsOf: videoURL)
            try data.write(to: myDocumentPath)
        } catch {
            NSLog("error: \(error)")
        }

        let documentsDirectory2 = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileName = String(format: "VID-%f.mp4", Date().timeIntervalSince1970 * 1000)
        let filePath = documentsDirectory2.appendingPathComponent(fileName)
        deleteFile(filePath: filePath)

        let avAsset = AVURLAsset(url: myDocumentPath)

        let startDate = NSDate()

        // Create Export session
        let exportSession = AVAssetExportSession(asset: avAsset, presetName: AVAssetExportPresetPassthrough)

        exportSession!.outputURL = filePath
        exportSession!.outputFileType = AVFileType.mp4
        exportSession!.shouldOptimizeForNetworkUse = true
        let start = CMTimeMakeWithSeconds(0.0, preferredTimescale: 0)
        let range = CMTimeRangeMake(start: start, duration: avAsset.duration)
        exportSession?.timeRange = range

        exportSession!.exportAsynchronously(completionHandler: { () in
            switch exportSession!.status {
            case .failed:
                print("%@", exportSession?.error as Any)
                completion(nil)
            case .cancelled:
                print("Export canceled")
                completion(nil)
            case .completed:
                // Video conversion finished
                let endDate = NSDate()

                let time = endDate.timeIntervalSince(startDate as Date)
                print(time)
                print("Successful!")
                print(exportSession?.outputURL as Any)
                completion(exportSession?.outputURL?.path)
            default:
                break
            }
        })
    }

    /// One of the template message was selected.
    open func selected(template: ALKTemplateMessageModel, metadata: [AnyHashable: Any]?) {
        // Send message if property is set
        guard template.sendMessageOnSelection else { return }
        var text = template.text
        if let messageToSend = template.messageToSend {
            text = messageToSend
        }

        send(message: text, isOpenGroup: isOpenGroup, metadata: metadata)
    }

    open func setSelectedMessageToReply(_ message: ALKMessageViewModel) {
        selectedMessageForReply = message
    }

    open func getSelectedMessageToReply() -> ALKMessageViewModel? {
        return selectedMessageForReply
    }

    open func clearSelectedMessageToReply() {
        selectedMessageForReply = nil
    }

    open func getIndexpathFor(message: ALKMessageModel) -> IndexPath? {
        guard let index = messageModels.firstIndex(of: message)
        else { return nil }
        return IndexPath(row: 0, section: index)
    }

    open func showPoweredByMessage() -> Bool {
        return ALApplicationInfo().showPoweredByMessage()
    }

    func updateUserDetail(_ userId: String) {
        let alUserService = ALUserService()
        alUserService.updateUserDetail(userId, withCompletion: {
            userDetail in
            guard userDetail != nil else { return }
            guard
                !self.isGroup,
                userId == self.contactId,
                let contact = ALContactService().loadContact(byKey: "userId", value: userId)
            else { return }
            self.delegate?.updateDisplay(contact: contact, channel: nil)
        })
    }
    
    func removeAlreadyDeletedMessageFromConversation() {
        for message in alMessages {
            if let metadata = message.metadata, let deleteGroupMessageForAll = metadata["AL_DELETE_GROUP_MESSAGE_FOR_ALL"] as? String, deleteGroupMessageForAll == "true" {
                removeMessageFromTheConversation(message: message)
            }
        }
    }
    
    func removeMessageFromTheConversation(message: ALMessage) {
        if let index = messageModels.firstIndex(where: { $0.identifier == message.identifier }) {
            messageModels.remove(at: index)
        }
        if let index = alMessages.firstIndex(where: { $0.identifier == message.identifier }) {
            alMessages.remove(at: index)
        }
        let messageService = ALMessageDBService()
        messageService.deleteMessage(byKey: message.identifier)
    }

    func currentConversationProfile(completion: @escaping (ALKConversationProfile?) -> Void) {
        if channelKey != nil {
            ALChannelService().getChannelInformation(channelKey, orClientChannelKey: nil) { channel in
                guard let channel = channel else {
                    print("Error while fetching channel details")
                    completion(nil)
                    return
                }
                guard
                    let userId = channel.getReceiverIdInGroupOfTwo(),
                    let contact = ALContactDBService().loadContact(byKey: "userId", value: userId)
                else {
                    completion(self.conversationProfileFrom(contact: nil, channel: channel))
                    return
                }
                completion(self.conversationProfileFrom(contact: contact, channel: nil))
            }
        } else if contactId != nil {
            ALUserService().getUserDetail(contactId) { contact in
                guard let contact = contact else {
                    print("Error while fetching contact details")
                    completion(nil)
                    return
                }
                self.updateUserDetail(contact.userId)
                completion(self.conversationProfileFrom(contact: contact, channel: nil))
            }
        }
    }

    func conversationProfileFrom(contact: ALContact?, channel: ALChannel?) -> ALKConversationProfile {
        var conversationProfile = ALKConversationProfile()
        conversationProfile.name = channel?.name ?? contact?.getDisplayName() ?? ""
        conversationProfile.imageUrl = channel?.channelImageURL ?? contact?.contactImageUrl
        guard let contact = contact, channel == nil else {
            return conversationProfile
        }
        conversationProfile.isBlocked = contact.block || contact.blockBy
        conversationProfile.status = ALKConversationProfile.Status(isOnline: contact.connected, lastSeenAt: contact.lastSeenAt)
        return conversationProfile
    }
    
    open func checkForTextToSpeech(list: [ALMessage]) {
        KMTextToSpeech.shared.addMessagesToSpeech(list)
    }
   
    func loadMessages() {
        var time: NSNumber?
        if let messageList = alMessageWrapper.getUpdatedMessageArray(), messageList.count > 1 {
            time = (messageList.firstObject as! ALMessage).createdAtTime
        }
        let messageListRequest = MessageListRequest()
        messageListRequest.userId = contactId
        messageListRequest.channelKey = channelKey
        messageListRequest.conversationId = conversationId
        messageListRequest.endTimeStamp = time
        ALMessageService.sharedInstance().getMessageList(forUser: messageListRequest, withCompletion: {
            messages, error, _ in
            guard error == nil, let messages = messages else {
                self.delegate?.loadingFinished(error: error)
                return
            }
            NSLog("messages loaded: ", messages)

            self.alMessages = messages.reversed() as! [ALMessage]

            if !KMConversationScreenConfiguration.staticTopMessage.isEmpty {
                self.alMessages.insert(self.getInitialStaticFirstMessage(), at: 0)
            }
            
            if(ALKConversationViewModel.lastSentMessage == nil){
                ALKConversationViewModel.lastSentMessage = self.getLastSentMessage()
            }
            if ALApplozicSettings.isAgentAppConfigurationEnabled() {
                self.getConversationEndUserID()
            }
            self.alMessageWrapper.addObject(toMessageArray: messages)
            
            self.modelsToBeAddedAfterDelay = self.alMessages.map { $0.messageModel }
            // Check for Conversation Assignee and conversation first message created time to show Typing Indicator.
            if self.isConversationAssignedToBot() && (self.botDelayTime > 0) && !self.isOldConversation() {
                self.showTypingIndicatorForWelcomeMessage()
            } else {
                self.messageModels = self.modelsToBeAddedAfterDelay
            }
            self.removeAlreadyDeletedMessageFromConversation()
            self.removeMessageForHidePostCTA(messages: self.messageModels)
            self.membersInGroup { members in
                self.groupMembers = members
                self.delegate?.loadingFinished(error: nil)
            }
        })
        self.lastMessage = alMessages.last
    }
    
    /*
        Since we are getting the welcome message from Api Call, we are using this method to Show Typing Delay Indicator for Welcome Messsages
     */
    
    public func getConversationEndUserID() {
        guard let channelKey = channelKey else { return }
        ALChannelDBService().membersInGroup(channelKey: channelKey) { contacts in
            guard let contacts = contacts, !contacts.isEmpty else { return }
            for contact in contacts {
                if contact.roleType == 3 {
                    self._conversationEndUserID = contact.userId
                }
            }
        }
    }
    
    func getLastSentMessage() -> ALMessage? {
        for message in alMessages.reversed() {
            if(message.isMyMessage){
                return message
            }
        }
        return nil
    }
    
    public func getLastReceivedMessage() -> ALMessage? {
        for message in alMessages.reversed() {
            if(message.isReceivedMessage() && message.to != "bot"){
                return message
            }
        }
        return nil
    }
    
    func showTypingIndicatorForWelcomeMessage() {
        if welcomeMessagePosition >= alMessages.count {
            return
        }
        self.delegate?.updateTyingStatus(status: true, userId: self.alMessages[0].to)
        let delay = TimeInterval(botDelayTime)
        self.timer = Timer.scheduledTimer(withTimeInterval:delay, repeats: false) {[self] timer in
            guard welcomeMessagePosition < modelsToBeAddedAfterDelay.count else{
                return
            }
            self.removeTypingIndicatorMessage()
            self.messageModels.append(modelsToBeAddedAfterDelay[welcomeMessagePosition])
            self.delegate?.messageUpdated()
            self.timer.invalidate()
            if welcomeMessagePosition >= alMessages.count  {
                welcomeMessagePosition = 0
            } else {
                welcomeMessagePosition += 1
                showTypingIndicatorForWelcomeMessage()
            }
        }
    }
    
    // Check for Old Conversation based on created time
    func isOldConversation() -> Bool {
        let createdTimeInMilliSec = self.alMessages[0].createdAtTime as? Double ?? 0.0
        let date = NSDate()
        let currentTimeInMilliSec = date.timeIntervalSince1970 * 1000
        let diff = currentTimeInMilliSec - createdTimeInMilliSec
        // Checking time difference of 10 seconds.
        if currentTimeInMilliSec - createdTimeInMilliSec < 10000 {
            return false
        }
        return true
    }
    
    func isConversationAssignedToBot() -> Bool {
        //If Welcome message is not configured, then return false
        guard !self.alMessages.isEmpty else { return false }

        let contactService = ALContactService()
        if let alContact = contactService.loadContact(byKey: "userId", value:  self.alMessages[0].to),
           let role = alContact.roleType,
           role ==  NSNumber.init(value: AL_BOT.rawValue) {
            return true
        }
        return false
    }
    
    func isBotHandelingConversation() -> Bool {
        if let channel = ALChannelService().getChannelByKey(channelKey),
        let assigneeUserId = channel.assigneeUserId,
        let assignee = ALContactService().loadContact(byKey: "userId", value: assigneeUserId),
        let roleType = assignee.roleType,
        roleType ==  NSNumber.init(value: AL_BOT.rawValue) {
            return true
        }
        return false
    }

    func loadSearchMessages() {
        var time: NSNumber?
        if let messageList = alMessageWrapper.getUpdatedMessageArray(), messageList.count > 1 {
            guard let message = messageList.firstObject as? ALMessage else {
                return
            }
            time = message.createdAtTime
        }
        let messageListRequest = MessageListRequest()
        messageListRequest.userId = contactId
        messageListRequest.channelKey = channelKey
        messageListRequest.conversationId = conversationId
        messageListRequest.endTimeStamp = time
        ALMessageClientService().getMessageList(forUser: messageListRequest, isSearch: true) { [weak self] messages, error in
            guard error == nil, let messages = messages, let weakSelf = self else {
                self?.delegate?.loadingFinished(error: error)
                return
            }

            if let list = weakSelf.alMessageWrapper.getUpdatedMessageArray(), list.count > 1 {
                weakSelf.fetchReplyMessages(from: messages) { [weak self] result in
                    guard let replyWeakSelf = self else {
                        self?.delegate?.loadingFinished(error: nil)
                        return
                    }
                    switch result {
                    case let .success(messagesArray):
                        for mesg in messagesArray as! [ALMessage] {
                            guard let msg = self?.alMessages.first, let time = Double(msg.createdAtTime.stringValue) else { continue }
                            if let msgTime = Double(mesg.createdAtTime.stringValue), time <= msgTime {
                                continue
                            }
                            replyWeakSelf.alMessageWrapper
                                .getUpdatedMessageArray()
                                .insert(mesg, at: 0)
                            replyWeakSelf.alMessages.insert(mesg, at: 0)
                            replyWeakSelf.messageModels.insert(mesg.messageModel, at: 0)
                        }
                        replyWeakSelf.delegate?.loadingFinished(error: nil)
                    case let .failure(error):
                        print("Error in fetching messages:", error.localizedDescription)
                        replyWeakSelf.delegate?.loadingFinished(error: nil)
                    }
                }
                return
            }

            weakSelf.fetchReplyMessages(from: messages) { [weak self] result in
                guard let replyWeakSelf = self else {
                    self?.delegate?.loadingFinished(error: nil)
                    return
                }
                switch result {
                case let .success(messagesArray):
                    replyWeakSelf.alMessages = messagesArray.reversed() as! [ALMessage]
                    replyWeakSelf.alMessageWrapper.addObject(toMessageArray: messages)
                    let models = replyWeakSelf.alMessages.map { $0.messageModel }
                    replyWeakSelf.messageModels = models
                    replyWeakSelf.delegate?.loadingFinished(error: nil)
                case let .failure(error):
                    print("Error in fetching messages:", error.localizedDescription)
                    replyWeakSelf.delegate?.loadingFinished(error: nil)
                }
            }
        }
    }

    func fetchReplyMessages(from messages: NSMutableArray, _ completion: @escaping (Result<NSMutableArray, Error>) -> Void) {
        let service = ALMessageService()
        let messageDb = ALMessageDBService()
        let replyMessageKeys = NSMutableArray()
        let contactService = ALContactService()
        let contactDBService = ALContactDBService()

        let alUserService = ALUserService()
        if let newMessages = messages as? [ALMessage] {
            for msg in newMessages {
                if let metadata = msg.metadata,
                   let replyKey = metadata.value(forKey: AL_MESSAGE_REPLY_KEY) as? String,
                   messageDb.getMessageByKey("key", value: replyKey) == nil,
                   !replyMessageKeys.contains(replyKey)
                {
                    replyMessageKeys.add(replyKey)
                }
            }

            service.fetchReplyMessages(replyMessageKeys) { replyMessages in
                var userNotPresentIds = [String]()

                if let newMessages = replyMessages as? [ALMessage], !newMessages.isEmpty {
                    for replyMessage in newMessages {
                        if !contactService.isContactExist(replyMessage.to) {
                            userNotPresentIds.append(replyMessage.to)
                        }
                    }
                }

                guard !userNotPresentIds.isEmpty else {
                    completion(.success(messages))
                    return
                }
                alUserService.fetchAndupdateUserDetails(NSMutableArray(array: userNotPresentIds), withCompletion: { userDetailArray, theError in

                    guard theError == nil else {
                        completion(.failure(theError!))
                        return
                    }
                    contactDBService.addUserDetails(userDetailArray)
                    completion(.success(messages))
                })
            }
        }
    }

    func loadMessagesFromDB(isFirstTime: Bool = true) {
        
        let startTime = alMessages.first?.createdAtTime ?? nil;
        
        ALMessageService.getMessageList(forContactId: contactId, isGroup: isGroup, channelKey: channelKey, conversationId: conversationId, start: 0, startTime: startTime, withCompletion: {
            messages in
            guard let messages = messages, messages.count != 0 else {
                if(ALUserDefaultsHandler.isShowLoadEarlierOption(self.chatId)){
                    self.loadEarlierMessages()
                }
                self.delegate?.loadingFinished(error: nil)
                return
            }
            NSLog("messages loaded: %@", messages)
            if !KMConversationScreenConfiguration.staticTopMessage.isEmpty {
                messages.insert(self.getInitialStaticFirstMessage(), at: 0)
            }
            self.alMessages.insert(contentsOf: messages as! [ALMessage], at: 0)

            self.alMessageWrapper.addObject(toMessageArray: messages)
            if(ALKConversationViewModel.lastSentMessage == nil){
                ALKConversationViewModel.lastSentMessage = self.getLastSentMessage()
            }
            if ALApplozicSettings.isAgentAppConfigurationEnabled() {
                self.getConversationEndUserID()
            }
            let models = messages.map { ($0 as! ALMessage).messageModel }
            self.messageModels.insert(contentsOf: models, at: 0)
            self.removeAlreadyDeletedMessageFromConversation()
            self.removeMessageForHidePostCTA(messages: models)
            if isFirstTime {
                self.membersInGroup { members in
                    self.groupMembers = members
                    self.delegate?.loadingFinished(error: nil)
                }
            } else {
                self.delegate?.messageUpdated()
            }
        })
        self.lastMessage = alMessages.last
    }
    
    func removeMessageForHidePostCTA(messages : [ALKMessageModel]){
        guard let lastSentMessageTime = ALKConversationViewModel.lastSentMessage?.createdAtTime,
                  UserDefaults.standard.bool(forKey: SuggestedReplyView.hidePostCTA) else { return }

        for message in messages {
            guard let currentMessageTime = message.createdAtTime else { continue }

            let messageType = message.messageType
            let checkMessageDelete = !message.isMyMessage &&
                                      (messageType == .allButtons || messageType == .quickReply) &&
                                      message.message == nil &&
                                      !message.containsHidePostCTARestrictedButtons() &&
                                      currentMessageTime.int64Value <= lastSentMessageTime.int64Value
            
           if checkMessageDelete {
                messageModels.removeAll { $0.identifier == message.identifier }
                alMessages.removeAll { $0.identifier == message.identifier }
            }
        }
    }

    open func loadOpenGroupMessages() {
        var time: NSNumber?
        if let messageList = alMessageWrapper.getUpdatedMessageArray(), messageList.count > 1 {
            time = (messageList.firstObject as! ALMessage).createdAtTime
        }
        NSLog("Last time: \(String(describing: time))")
        fetchOpenGroupMessages(time: time, contactId: contactId, channelKey: channelKey, completion: {
            messageList in

            guard let messages = messageList else {
                self.delegate?.loadingFinished(error: nil)
                return
            }
            self.addMessagesToList(messages)
            self.delegate?.loadingFinished(error: nil)
        })
    }

    func fetchGroupMembersForAutocompletion() -> [KMAutoCompleteItem] {
        guard let members = groupMembers else { return [] }
        let items =
            members
                .filter { $0.userId != ALUserDefaultsHandler.getUserId() }
                .map { KMAutoCompleteItem(key: $0.userId, content: $0.displayName ?? $0.userId, displayImageURL: $0.friendDisplayImgURL) }
                .sorted { $0.content < $1.content }
        return items
    }

    func displayNames(ofUserIds userIds: Set<String>) -> [String: String]? {
        guard let groupMembers = groupMembers else { return nil }
        var names: [String: String] = [:]
        groupMembers
            .filter { userIds.contains($0.userId) }
            .forEach { names[$0.userId] = $0.displayName ?? $0.userId }
        return names
    }

    func sendFile(at url: URL, fileName: String, metadata: [AnyHashable: Any]?) -> (ALMessage?, IndexPath?) {
        var fileData: Data?
        do {
            fileData = try Data(contentsOf: url)
        } catch {
            print("Failed to read the content of the file at path: \(url) due to error: \(error.localizedDescription)")
        }
        guard fileData != nil else { return (nil, nil) }
        guard let alMessage = processAttachment(
            filePath: url,
            text: "",
            contentType: Int(ALMESSAGE_CONTENT_ATTACHMENT),
            metadata: metadata,
            fileName: fileName
        ) else {
            return (nil, nil)
        }
        addToWrapper(message: alMessage)
        return (alMessage, IndexPath(row: 0, section: messageModels.count - 1))
    }

    // MARK: - Private Methods

    private func updateGroupInfo(
        groupName: String,
        groupImage: String?,
        completion: @escaping (Bool) -> Void
    ) {
        guard let groupId = groupKey() else { return }
        let alchanneService = ALChannelService()
        alchanneService.updateChannel(
            groupId, andNewName: groupName,
            andImageURL: groupImage,
            orClientChannelKey: nil,
            isUpdatingMetaData: false,
            metadata: nil,
            orChildKeys: nil,
            orChannelUsers: nil,
            withCompletion: {
                errorReceived in
                if let error = errorReceived {
                    print("error received while updating group info: ", error)
                    completion(false)
                } else {
                    completion(true)
                }
            }
        )
    }

    private func loadEarlierMessages() {
        delegate?.loadingStarted()
        var time: NSNumber?
        if let messageList = alMessageWrapper.getUpdatedMessageArray(),
           messageList.count > 1,
           let first = alMessages.first
        {
            time = first.createdAtTime
        }
        let messageListRequest = MessageListRequest()
        messageListRequest.userId = contactId
        messageListRequest.channelKey = channelKey
        messageListRequest.conversationId = conversationId
        messageListRequest.endTimeStamp = time
        ALMessageService.sharedInstance().getMessageList(forUser: messageListRequest, withCompletion: {
            messages, error, _ in
            guard error == nil, let newMessages = messages as? [ALMessage] else {
                self.delegate?.loadingFinished(error: error)
                return
            }
            //                NSLog("messages loaded: ", messages)
            for mesg in newMessages {
                guard let msg = self.alMessages.first, let time = Double(msg.createdAtTime.stringValue) else { continue }
                if let msgTime = Double(mesg.createdAtTime.stringValue), time <= msgTime {
                    continue
                }
                self.alMessageWrapper.getUpdatedMessageArray().insert(newMessages, at: 0)
                self.alMessages.insert(mesg, at: 0)
                self.messageModels.insert(mesg.messageModel, at: 0)
                self.removeAlreadyDeletedMessageFromConversation()
                self.removeMessageForHidePostCTA(messages: [mesg.messageModel])
            }
            self.delegate?.loadingFinished(error: nil)
        })
    }

    private func fetchOpenGroupMessages(time: NSNumber?, contactId: String?, channelKey: NSNumber?, completion: @escaping ([ALMessage]?) -> Void) {
        let messageListRequest = MessageListRequest()
        messageListRequest.userId = contactId
        messageListRequest.channelKey = channelKey
        messageListRequest.conversationId = conversationId
        messageListRequest.endTimeStamp = time
        let messageClientService = ALMessageClientService()
        messageClientService.getMessageList(forUser: messageListRequest, withCompletion: {
            messages, _, userDetailsList in

            let contactDbService = ALContactDBService()
            contactDbService.addUserDetails(userDetailsList)
            guard let alMessages = messages as? [ALMessage] else {
                completion(nil)
                return
            }
            let contactService = ALContactService()
            var contactsNotPresent = [String]()
            for message in alMessages {
                let contactId = message.to ?? ""
                if !contactService.isContactExist(contactId) {
                    contactsNotPresent.append(contactId)
                }
            }

            if !contactsNotPresent.isEmpty {
                let userService = ALUserService()
                userService.fetchAndupdateUserDetails(NSMutableArray(array: contactsNotPresent), withCompletion: { userDetails, _ in
                    contactDbService.addUserDetails(userDetails)
                    completion(alMessages)
                })
            } else {
                completion(alMessages)
            }

        })
    }

    private func addMembersToGroup(users: [ALKFriendViewModel], completion: @escaping (Bool) -> Void) {
        guard let groupId = groupKey() else { return }
        let alchanneService = ALChannelService()
        let channels = NSMutableArray(object: groupId)
        let channelUsers = NSMutableArray(array: users.map { $0.friendUUID as Any })
        alchanneService.addMultipleUsers(toChannel: channels, channelUsers: channelUsers, andCompletion: {
            error in
            if error != nil {
                print("error while adding members to group")
                completion(false)
            } else {
                completion(true)
            }
        })
    }

    private func updateDbMessageWith(key: String, value: String, filePath: String) {
        let messageService = ALMessageDBService()
        messageService.updateDbMessageWith(key: key, value: value, filePath: filePath)
    }

    private func getMessageToPost(isTextMessage: Bool = false) -> ALMessage {
        var alMessage = ALMessage()
        // If it's a text message then set the reply id
        if isTextMessage { alMessage = setReplyId(message: alMessage) }

        delegate?.willSendMessage()
        alMessage.to = contactId
        alMessage.contactIds = contactId
        alMessage.message = ""
        alMessage.type = "5"
        let date = Date().timeIntervalSince1970 * 1000
        alMessage.createdAtTime = NSNumber(value: date)
        alMessage.sendToDevice = false
        alMessage.deviceKey = ALUserDefaultsHandler.getDeviceKeyString()
        alMessage.shared = false
        alMessage.fileMeta = nil
        alMessage.storeOnDevice = false
        alMessage.contentType = Int16(ALMESSAGE_CONTENT_DEFAULT)
        alMessage.key = UUID().uuidString
        alMessage.source = Int16(AL_SOURCE_IOS)
        alMessage.conversationId = conversationId
        alMessage.groupId = channelKey
        return alMessage
    }

    private func getFileMetaInfo() -> ALFileMetaInfo {
        let info = ALFileMetaInfo()
        info.blobKey = nil
        info.contentType = ""
        info.createdAtTime = nil
        info.key = nil
        info.name = ""
        info.size = ""
        info.userKey = ""
        info.thumbnailUrl = ""
        info.progressValue = 0
        return info
    }

    private func processAttachment(
        filePath: URL,
        text : String,
        contentType: Int,
        isVideo _: Bool = false,
        metadata: [AnyHashable: Any]?,
        fileName: String? = nil
    ) -> ALMessage? {
        let alMessage = getMessageToPost()
        alMessage.metadata = modfiedMessageMetadata(alMessage: alMessage, metadata: metadata)
        alMessage.contentType = Int16(contentType)
        alMessage.fileMeta = getFileMetaInfo()
        alMessage.message = text
        alMessage.imageFilePath = filePath.lastPathComponent
        alMessage.fileMeta.name = fileName ?? String(format: "AUD-5-%@", filePath.lastPathComponent)
        if fileName == nil, let contactId = contactId {
            alMessage.fileMeta.name = String(format: "%@-5-%@", contactId, filePath.lastPathComponent)
        }
        let pathExtension = filePath.pathExtension
        let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as NSString, nil)?.takeRetainedValue()
        let mimetype = (UTTypeCopyPreferredTagWithClass(uti!, kUTTagClassMIMEType)?.takeRetainedValue()) as String?
        alMessage.fileMeta.contentType = mimetype ?? "application/zip"
        if contentType == ALMESSAGE_CONTENT_VCARD {
            alMessage.fileMeta.contentType = "text/x-vcard"
        }

        guard let imageData = NSData(contentsOfFile: filePath.path) else {
            // Empty image.
            return nil
        }
        alMessage.fileMeta.size = String(format: "%lu", imageData.length)

        let dbHandler = ALDBHandler.sharedInstance()
        let messageService = ALMessageDBService()

        guard let messageEntity = messageService.createMessageEntityForDBInsertion(with: alMessage) else {
            return nil
        }
        let error = dbHandler?.saveContext()

        if error == nil {
            alMessage.msgDBObjectId = messageEntity.objectID
            return alMessage
        }
        print("Not saved due to error \(String(describing: error))")
        return nil
    }

    private func createJson(dict: [String: String]) -> String? {
        var jsonData: Data?
        do {
            jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
        } catch {
            print("error creating json")
        }
        guard let data = jsonData, let str = String(data: data, encoding: .utf8) else {
            return nil
        }
        return str
    }

    private func getLocationMessage(latLonString: String) -> ALMessage {
        let alMessage = getMessageToPost()
        alMessage.contentType = Int16(ALMESSAGE_CONTENT_LOCATION)
        alMessage.message = latLonString
        return alMessage
    }

    private func send(alMessage: ALMessage, completion: @escaping (ALMessage?) -> Void) {
        ALMessageService.sharedInstance().sendMessages(alMessage, withCompletion: {
            message, error in
            let newMesg = alMessage
            #if canImport(ChatProvidersSDK)
                if KMZendeskChatHandler.shared.isZendeskEnabled() {
                    KMZendeskChatHandler.shared.sendAttachment(message: alMessage)
                }
            #endif
            NSLog("message is: ", newMesg.key)
            NSLog("Message sent: \(String(describing: message)), \(String(describing: error))")
            if error == nil {
                NSLog("No errors while sending the message")
                completion(newMesg)
            } else {
                completion(nil)
            }
        })
    }

    private func updateMessageStatus(filteredList: [ALMessage], status: Int32) {
        if !filteredList.isEmpty {
            let message = filteredList.first
            message?.status = status as NSNumber
            guard let model = message?.messageModel, let index = messageModels.firstIndex(of: model) else { return }
            messageModels[index] = model
            delegate?.updateMessageAt(indexPath: IndexPath(row: 0, section: index))
        }
    }

    private func deleteFile(filePath: URL) {
        guard FileManager.default.fileExists(atPath: filePath.path) else {
            return
        }
        do {
            try FileManager.default.removeItem(atPath: filePath.path)
        } catch {
            fatalError("Unable to delete file: \(error) : \(#function).")
        }
    }

    private func setReplyId(message: ALMessage) -> ALMessage {
        if let replyMessage = getSelectedMessageToReply() {
            let metaData = NSMutableDictionary()
            metaData[AL_MESSAGE_REPLY_KEY] = replyMessage.identifier
            message.metadata = metaData
        }
        return message
    }

    private func updateInfo() {
        guard let groupId = groupKey() else { return }
        let channel = ALChannelService().getChannelByKey(groupId)
        delegate?.updateDisplay(contact: nil, channel: channel)
    }

    private func getGenericCardTemplateFor(message: ALKMessageViewModel) -> ALKGenericCardTemplate? {
        guard
            let metadata = message.metadata,
            let payload = metadata["payload"] as? String
        else { return nil }
        do {
            let cards = try JSONDecoder().decode([ALKGenericCard].self, from: payload.data)
            let cardTemplate = ALKGenericCardTemplate(cards: cards)
            richMessages[message.identifier] = cardTemplate
            return cardTemplate
        } catch {
            print("\(error)")
            return nil
        }
    }

    private func membersInGroup(completion: @escaping ((Set<ALContact>?) -> Void)) {
        guard let channelKey = channelKey else {
            completion(nil)
            return
        }
        ALChannelDBService().membersInGroup(channelKey: channelKey) { contacts in
            guard let contacts = contacts, !contacts.isEmpty else {
                completion(nil)
                return
            }
            completion(contacts)
        }
    }
}

public extension ALChannel {
    static let ConversationAssignee = "CONVERSATION_ASSIGNEE"

    var assigneeUserId: String? {
        guard type == Int16(SUPPORT_GROUP.rawValue),
              let assigneeId = metadata?[ALChannel.ConversationAssignee] as? String
        else {
            return nil
        }
        return assigneeId
    }
}
