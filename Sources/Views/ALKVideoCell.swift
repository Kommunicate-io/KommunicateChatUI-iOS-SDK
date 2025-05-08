//
//  ALKVideoCell.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by Mukesh Thawani on 10/07/17.
//

import AVKit
import Kingfisher
import KommunicateCore_iOS_SDK
import UIKit
#if canImport(RichMessageKit)
    import RichMessageKit
#endif
class ALKVideoCell: ALKChatBaseCell<ALKMessageViewModel>,
    ALKReplyMenuItemProtocol, ALKReportMessageMenuItemProtocol {
    enum State {
        case download
        case downloading(progress: Double, totalCount: Int64)
        case downloaded(filePath: String)
        case upload(filePath: String)
        case uploaded
    }
    
    // This will be used to calculate the size of the photo view.
    static var heightPercentage: CGFloat = 0.5
    static var widthPercentage: CGFloat = 0.48
        
    static var maxWidth = UIScreen.main.bounds.width

    enum Padding {
        enum CaptionLabel {
            static var bottom: CGFloat = 10.0
            static var left: CGFloat = 5.0
            static var right: CGFloat = 5.0
        }
    }
    
    // To be changed from the class that is subclassing `ALKPhotoCell`
    class var messageTextFont: UIFont {
        return Font.normal(size: 12).font()
    }

    var photoView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    var captionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()

    var timeLabel: UILabel = {
        let lb = UILabel()
        return lb
    }()

    var fileSizeLabel: UILabel = {
        let lb = UILabel()
        return lb
    }()

    fileprivate var actionButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .clear
        button.isHidden = true
        return button
    }()

    fileprivate var downloadButton: UIButton = {
        let button = UIButton(type: .custom)
        let image = UIImage(named: "DownloadiOS", in: Bundle.km, compatibleWith: nil)
        button.setImage(image, for: .normal)
        button.backgroundColor = UIColor.black
        return button
    }()

    fileprivate var playButton: UIButton = {
        let button = UIButton(type: .custom)
        let image = UIImage(named: "PLAY", in: Bundle.km, compatibleWith: nil)
        button.setImage(image, for: .normal)
        return button
    }()

    fileprivate var uploadButton: UIButton = {
        let button = UIButton(type: .custom)
        let image = UIImage(named: "UploadiOS2", in: Bundle.km, compatibleWith: nil)
        button.setImage(image, for: .normal)
        button.backgroundColor = UIColor.black
        return button
    }()

    var bubbleView: UIView = {
        let bv = UIView()
        bv.clipsToBounds = true
        bv.isUserInteractionEnabled = false
        return bv
    }()

    var progressView: KDCircularProgress = {
        let view = KDCircularProgress(frame: .zero)
        view.startAngle = -90
        view.clockwise = true
        return view
    }()

    private var frontView: ALKTappableView = {
        let view = ALKTappableView()
        view.alpha = 1.0
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = true
        return view
    }()

    var url: URL?

    var uploadTapped: ((Bool) -> Void)?
    var uploadCompleted: ((_ responseDict: Any?) -> Void)?

    var downloadTapped: ((Bool) -> Void)?

    class func topPadding() -> CGFloat {
        return 12
    }

    class func bottomPadding() -> CGFloat {
        return 16
    }

    override class func rowHeigh(viewModel: ALKMessageViewModel, width: CGFloat) -> CGFloat {
        var height: CGFloat

        if viewModel.ratio < 1 {
            height = viewModel.ratio == 0 ? (width * heightPercentage) : ceil((width * heightPercentage) / viewModel.ratio)
        } else {
            height = ceil((width * 0.64) / viewModel.ratio)
        }
        
        if let message = viewModel.message, !message.isEmpty {
            height += message.rectWithConstrainedWidth(
                width * widthPercentage,
                font: messageTextFont
            ).height.rounded(.up) + Padding.CaptionLabel.bottom
        }

        return topPadding() + height + bottomPadding()
    }

    override func update(viewModel: ALKMessageViewModel) {
        self.viewModel = viewModel
        timeLabel.text = viewModel.time
        captionLabel.text = viewModel.message
        
        if viewModel.isMyMessage {
            if viewModel.isSent || viewModel.isAllRead || viewModel.isAllReceived {
                if let filePath = viewModel.filePath, !filePath.isEmpty {
                    updateView(for: State.downloaded(filePath: filePath))
                } else {
                    updateView(for: State.download)
                }
            } else {
                updateView(for: .upload(filePath: viewModel.filePath ?? ""))
            }
        } else {
            if let filePath = viewModel.filePath, !filePath.isEmpty {
                updateView(for: State.downloaded(filePath: filePath))
            } else {
                updateView(for: State.download)
            }
        }
    }

    @objc func actionTapped(button: UIButton) {
        button.isEnabled = false
    }

    override func setupStyle() {
        super.setupStyle()

        timeLabel.setStyle(ALKMessageStyle.time)
        fileSizeLabel.setStyle(ALKMessageStyle.time)
    }

    override func setupViews() {
        super.setupViews()
        playButton.isHidden = true
        progressView.isHidden = true
        uploadButton.isHidden = true

        frontView.addGestureRecognizer(longPressGesture)
        actionButton.addTarget(self, action: #selector(actionTapped), for: .touchUpInside)
        downloadButton.addTarget(self, action: #selector(ALKVideoCell.downloadButtonAction(_:)), for: UIControl.Event.touchUpInside)
        uploadButton.addTarget(self, action: #selector(ALKVideoCell.uploadButtonAction(_:)), for: .touchUpInside)
        playButton.addTarget(self, action: #selector(ALKVideoCell.playButtonAction(_:)), for: .touchUpInside)

        contentView.addViewsForAutolayout(views:
            [frontView,
             photoView,
             bubbleView,
             timeLabel,
             fileSizeLabel,
             captionLabel,
             downloadButton,
             playButton,
             progressView,
             uploadButton])

        contentView.bringSubviewToFront(photoView)
        contentView.bringSubviewToFront(frontView)
        contentView.bringSubviewToFront(actionButton)
        contentView.bringSubviewToFront(downloadButton)
        contentView.bringSubviewToFront(playButton)
        contentView.bringSubviewToFront(progressView)
        contentView.bringSubviewToFront(uploadButton)

        frontView.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive = true
        frontView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor).isActive = true
        frontView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor).isActive = true
        frontView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true

        bubbleView.topAnchor.constraint(equalTo: photoView.topAnchor).isActive = true
        bubbleView.bottomAnchor.constraint(equalTo: captionLabel.bottomAnchor).isActive = true
        bubbleView.leftAnchor.constraint(equalTo: photoView.leftAnchor).isActive = true
        bubbleView.rightAnchor.constraint(equalTo: photoView.rightAnchor).isActive = true

        downloadButton.centerXAnchor.constraint(equalTo: photoView.centerXAnchor).isActive = true
        downloadButton.centerYAnchor.constraint(equalTo: photoView.centerYAnchor).isActive = true
        downloadButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        downloadButton.widthAnchor.constraint(equalToConstant: 50).isActive = true

        uploadButton.centerXAnchor.constraint(equalTo: photoView.centerXAnchor).isActive = true
        uploadButton.centerYAnchor.constraint(equalTo: photoView.centerYAnchor).isActive = true
        uploadButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        uploadButton.widthAnchor.constraint(equalToConstant: 50).isActive = true

        playButton.centerXAnchor.constraint(equalTo: photoView.centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo: photoView.centerYAnchor).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        playButton.widthAnchor.constraint(equalToConstant: 60).isActive = true

        progressView.centerXAnchor.constraint(equalTo: photoView.centerXAnchor).isActive = true
        progressView.centerYAnchor.constraint(equalTo: photoView.centerYAnchor).isActive = true
        progressView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        progressView.widthAnchor.constraint(equalToConstant: 60).isActive = true

        fileSizeLabel.topAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: 2).isActive = true
        
        captionLabel.layout {
            $0.leading == photoView.leadingAnchor + Padding.CaptionLabel.left
            $0.trailing == photoView.trailingAnchor - Padding.CaptionLabel.right
            $0.top == photoView.bottomAnchor
            $0.bottom == contentView.bottomAnchor - ALKVideoCell.bottomPadding()
        }
    }

    deinit {
        actionButton.removeTarget(self, action: #selector(actionTapped), for: .touchUpInside)
    }

    func menuReply(_: Any) {
        menuAction?(.reply)
    }

    func menuReport(_: Any) {
        menuAction?(.report)
    }

    @objc private func downloadButtonAction(_: UIButton) {
        downloadTapped?(true)
    }

    @objc private func playButtonAction(_: UIButton) {
        let dbService = ALMessageDBService()
        guard let messages = dbService.getAllMessagesWithAttachment(
            forContact: viewModel?.contactId,
            andChannelKey: viewModel?.channelKey,
            onlyDownloadedAttachments: true
        ) as? [ALMessage] else { return }

        let messageModels = messages.map { $0.messageModel }
        NSLog("Messages with attachment: ", messages)

        guard let viewModel = viewModel as? ALKMessageModel,
              let currentIndex = messageModels.firstIndex(of: viewModel) else { return }

        let mediaViewerViewModel = ALKMediaViewerViewModel(
            messages: messageModels,
            currentIndex: currentIndex,
            localizedStringFileName: localizedStringFileName
        )
        
        let mediaVC = KMMediaViewerViewController(viewModel: mediaViewerViewModel)
        let nav = ALKBaseNavigationViewController(rootViewController: mediaVC)
        nav.modalPresentationStyle = .formSheet
        UIViewController.topViewController()?.present(nav, animated: true, completion: {
            self.playButton.isEnabled = true
        })
    }

    @objc private func uploadButtonAction(_: UIButton) {
        uploadTapped?(true)
    }

    fileprivate func updateView(for state: State) {
        switch state {
        case .download:
            uploadButton.isHidden = true
            downloadButton.isHidden = false
            playButton.isHidden = true
            progressView.isHidden = true
            loadThumbnail()
        case let .downloaded(filePath):
            uploadButton.isHidden = true
            downloadButton.isHidden = true
            progressView.isHidden = true
            playButton.isHidden = false
            loadThumbnail(isDownloaded: true, filePath: filePath)
        case let .downloading(progress, _):
            // show progress bar
            print("downloading")
            uploadButton.isHidden = true
            downloadButton.isHidden = true
            progressView.isHidden = false
            if progress == 360.0 {
                progressView.isHidden = true
            }
            progressView.angle = progress
        case let .upload(filePath):
            downloadButton.isHidden = true
            progressView.isHidden = true
            playButton.isHidden = true
            photoView.image = UIImage(named: "VIDEO", in: Bundle.km, compatibleWith: nil)
            uploadButton.isHidden = false
            let docDirPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let path = docDirPath.appendingPathComponent(filePath)
            let fileUtills = ALKFileUtils()
            photoView.image = fileUtills.getThumbnail(filePath: path)
        case .uploaded:
            uploadButton.isHidden = true
            downloadButton.isHidden = true
            progressView.isHidden = true
            playButton.isHidden = false
        }
    }

    func loadThumbnail(isDownloaded: Bool = false, filePath: String? = nil) {
        guard let message = viewModel, let metadata = message.fileMetaInfo else {
            return
        }
        let placeHolderImage = UIImage(named: "VIDEO", in: Bundle.km, compatibleWith: nil)
        guard KMCoreSettings.isS3StorageServiceEnabled() || KMCoreSettings.isGoogleCloudServiceEnabled() else {
            photoView.kf.setImage(with: message.thumbnailURL, placeholder: placeHolderImage)
            return
        }
        /*
            if Video is already Downloaded, then the Thumbnail will be directly fetched from file.
         */
        if isDownloaded, let filePath = filePath {
            let docDirPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let path = docDirPath.appendingPathComponent(filePath)
            let fileUtills = ALKFileUtils()
            photoView.image = fileUtills.getThumbnail(filePath: path) ?? placeHolderImage
            return
        }
        /*
            if URL is exist on metadata, then it was upload by S3 Service. if not it was uploaded by Google
         */
        if metadata.url == nil && !message.isMyMessage {
            photoView.kf.setImage(with: message.thumbnailURL, placeholder: placeHolderImage)
            return
        }
        // If thumbnailblobkey is nil,set thumbnail with placeholder
        guard let thumbnailBlobKey = metadata.thumbnailBlobKey else {
            photoView.image = placeHolderImage
            return
        }
        // If thumbanailBlobkey has spaces, remove it before creating the URL.
        var updatedBlobKey = thumbnailBlobKey
        if thumbnailBlobKey.contains(" ") {
            updatedBlobKey = thumbnailBlobKey.replacingOccurrences(of: " ", with: "%20")
        }
        guard let thumbnailPath = metadata.thumbnailFilePath else {
            ALMessageClientService().downloadImageThumbnailUrlV2(metadata.thumbnailUrl, isS3URL: metadata.url != nil, blobKey: updatedBlobKey) { url, error in
                guard error == nil,
                      let url = url
                else {
                    print("Error downloading thumbnail url")
                    self.photoView.image = UIImage(named: "VIDEO", in: Bundle.km, compatibleWith: nil)
                    return
                }
                let httpManager = ALKHTTPManager()
                httpManager.downloadDelegate = self
                let task = ALKDownloadTask(downloadUrl: url, fileName: metadata.name)
                task.identifier = ThumbnailIdentifier.addPrefix(to: message.identifier)
                httpManager.downloadAttachment(task: task)
            }
            return
        }
        setThumbnail(thumbnailPath)
    }

    fileprivate func setThumbnail(_ path: String) {
        let docDirPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let path = docDirPath.appendingPathComponent(path)
        setPhotoViewImageFromFileURL(path)
    }

    func setPhotoViewImageFromFileURL(_ fileURL: URL) {
        let provider = LocalFileImageDataProvider(fileURL: fileURL)
        let placeHolder = UIImage(named: "VIDEO", in: Bundle.km, compatibleWith: nil)
        photoView.kf.setImage(with: provider, placeholder: placeHolder)
    }

    fileprivate func convertToDegree(total: Int64, written: Int64) -> Double {
        let divergence = Double(total) / 360.0
        let degree = Double(written) / divergence
        return degree
    }

    fileprivate func updateThumbnailPath(_ key: String, filePath: String) {
        let messageKey = ThumbnailIdentifier.removePrefix(from: key)
        guard let dbMessage = ALMessageDBService().getMessageByKey("key", value: messageKey) as? DB_Message else { return }
        dbMessage.fileMetaInfo.thumbnailFilePath = filePath

        let dbHandler = ALDBHandler.sharedInstance()
        let error = dbHandler?.saveContext()
        if error != nil {
            print("Not saved due to error \(String(describing: error))")
        }
    }
}

extension ALKVideoCell: ALKHTTPManagerUploadDelegate {
    func dataUploaded(task: ALKUploadTask) {
        NSLog("Data uploaded: \(task.totalBytesUploaded) out of total: \(task.totalBytesExpectedToUpload)")
        let progress = convertToDegree(total: task.totalBytesExpectedToUpload, written: task.totalBytesUploaded)
        updateView(for: .downloading(progress: progress, totalCount: task.totalBytesExpectedToUpload))
    }

    func dataUploadingFinished(task: ALKUploadTask) {
        NSLog("VIDEO CELL DATA UPLOADED FOR PATH: %@", viewModel?.filePath ?? "")
        if task.uploadError == nil, task.completed == true, task.filePath != nil {
            DispatchQueue.main.async {
                self.updateView(for: .uploaded)
            }
        } else {
            DispatchQueue.main.async {
                guard let path = task.filePath else {
                    return
                }
                self.updateView(for: .upload(filePath: path))
            }
        }
    }
}

extension ALKVideoCell: ALKHTTPManagerDownloadDelegate {
    func dataDownloaded(task: ALKDownloadTask) {
        NSLog("VIDEO CELL DATA UPDATED AND FILEPATH IS: %@", viewModel?.filePath ?? "")
        let total = task.totalBytesExpectedToDownload
        var progress = 360.0
        if total != 0 {
            progress = convertToDegree(total: total, written: task.totalBytesDownloaded)
        }
        updateView(for: .downloading(progress: progress, totalCount: total))
    }

    func dataDownloadingFinished(task: ALKDownloadTask) {
        guard task.downloadError == nil, let filePath = task.filePath, let identifier = task.identifier, viewModel != nil else {
            updateView(for: .download)
            return
        }
        guard !ThumbnailIdentifier.hasPrefix(in: identifier) else {
            DispatchQueue.main.async {
                self.setThumbnail(filePath)
            }
            updateThumbnailPath(identifier, filePath: filePath)
            return
        }
        ALMessageDBService().updateDbMessageWith(key: "key", value: identifier, filePath: filePath)
        DispatchQueue.main.async {
            self.updateView(for: .downloaded(filePath: filePath))
        }
    }
}
