//
//  ALKPhotoCell.swift
//  
//
//  Created by Mukesh Thawani on 04/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher
import Applozic

// MARK: - ALKPhotoCell
class ALKPhotoCell: ALKChatBaseCell<ALKMessageViewModel>,
                    ALKReplyMenuItemProtocol {

    var photoView: UIImageView = {
        let mv = UIImageView()
        mv.backgroundColor = .clear
        mv.contentMode = .scaleAspectFill
        mv.clipsToBounds = true
        mv.layer.cornerRadius = 12
        return mv
    }()

    var timeLabel: UILabel = {
        let lb = UILabel()
        return lb
    }()

    var fileSizeLabel: UILabel = {
        let lb = UILabel()
        return lb
    }()

    var bubbleView: UIView = {
        let bv = UIView()
        bv.backgroundColor = .gray
        bv.layer.cornerRadius = 12
        bv.isUserInteractionEnabled = false
        return bv
    }()

    private var frontView: ALKTappableView = {
        let view = ALKTappableView()
        view.alpha = 1.0
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = true
        return view
    }()

    fileprivate var downloadButton: UIButton = {
        let button = UIButton(type: .custom)
        let image = UIImage(named: "DownloadiOS", in: Bundle.applozic, compatibleWith: nil)
        button.setImage(image, for: .normal)
        button.backgroundColor = UIColor.black
        return button
    }()

    var uploadButton: UIButton = {
        let button = UIButton(type: .custom)
        let image = UIImage(named: "UploadiOS2", in: Bundle.applozic, compatibleWith: nil)
        button.setImage(image, for: .normal)
        button.backgroundColor = UIColor.black
        return button
    }()

    fileprivate let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)

    var url: URL? = nil
    enum state {
        case upload(filePath: String)
        case uploading(filePath: String)
        case uploaded
        case download
        case downloading
        case downloaded(filePath: String)
    }

    var uploadTapped:((Bool) ->())?
    var uploadCompleted: ((_ responseDict: Any?) ->())?

    var downloadTapped:((Bool) ->())?


    class func topPadding() -> CGFloat {
        return 12
    }

    class func bottomPadding() -> CGFloat {
        return 16
    }

    override class func rowHeigh(viewModel: ALKMessageViewModel,width: CGFloat) -> CGFloat {

        let heigh: CGFloat

        if viewModel.ratio < 1 {
            heigh = viewModel.ratio == 0 ? (width*0.48) : ceil((width*0.48)/viewModel.ratio)
        } else {
            heigh = ceil((width*0.64)/viewModel.ratio)
        }

        return topPadding()+heigh+bottomPadding()
    }

    override func update(viewModel: ALKMessageViewModel) {

        self.viewModel = viewModel
        activityIndicator.color = .black
        print("Update ViewModel filePath:: %@", viewModel.filePath ?? "")
        if viewModel.isMyMessage {
            if viewModel.isSent || viewModel.isAllRead || viewModel.isAllReceived {
                if let filePath = viewModel.filePath, !filePath.isEmpty {
                    updateView(for: state.downloaded(filePath: filePath))
                } else {
                    updateView(for: state.download)
                }
            } else {
                if let filePath = viewModel.filePath, !filePath.isEmpty {
                    updateView(for: .upload(filePath: filePath))
                }
            }
        } else {
            if let filePath = viewModel.filePath, !filePath.isEmpty {
                updateView(for: state.downloaded(filePath: filePath))
            } else {
                updateView(for: state.download)
            }
        }
        timeLabel.text   = viewModel.time

    }

    func actionTapped(button: UIButton) {
        let storyboard = UIStoryboard.name(storyboard: UIStoryboard.Storyboard.mediaViewer, bundle: Bundle.applozic)

        let nav = storyboard.instantiateInitialViewController() as? UINavigationController
        let vc = nav?.viewControllers.first as? ALKMediaViewerViewController
        let dbService = ALMessageDBService()
        guard let messages = dbService.getAllMessagesWithAttachment(forContact: viewModel?.contactId, andChannelKey: viewModel?.channelKey, onlyDownloadedAttachments: true) as? [ALMessage] else { return }

        let messageModels = messages.map { $0.messageModel }
        NSLog("Messages with attachment: ", messages )

        guard let viewModel = viewModel as? ALKMessageModel,
            let currentIndex = messageModels.index(of: viewModel) else { return }
        vc?.viewModel = ALKMediaViewerViewModel(messages: messageModels, currentIndex: currentIndex)
        UIViewController.topViewController()?.present(nav!, animated: true, completion: {
            button.isEnabled = true
        })

    }

    override func setupStyle() {
        super.setupStyle()

        timeLabel.setStyle(style: ALKMessageStyle.time)
        fileSizeLabel.setStyle(style: ALKMessageStyle.time)
    }

    override func setupViews() {
        super.setupViews()
        frontView.addGestureRecognizer(longPressGesture)
        uploadButton.isHidden = true
        uploadButton.addTarget(self, action: #selector(ALKPhotoCell.uploadButtonAction(_:)), for: .touchUpInside)
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(actionTapped))
        singleTap.numberOfTapsRequired = 1
        frontView.addGestureRecognizer(singleTap)

        downloadButton.addTarget(self, action: #selector(ALKPhotoCell.downloadButtonAction(_:)), for: .touchUpInside)
        contentView.addViewsForAutolayout(views: [frontView ,photoView,bubbleView,timeLabel,fileSizeLabel,uploadButton, downloadButton, activityIndicator])
        contentView.bringSubview(toFront: photoView)
        contentView.bringSubview(toFront: frontView)
        contentView.bringSubview(toFront: downloadButton)
        contentView.bringSubview(toFront: uploadButton)
        contentView.bringSubview(toFront: activityIndicator)

        frontView.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive = true
        frontView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor).isActive = true
        frontView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor).isActive = true
        frontView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true

        bubbleView.topAnchor.constraint(equalTo: photoView.topAnchor).isActive = true
        bubbleView.bottomAnchor.constraint(equalTo: photoView.bottomAnchor).isActive = true
        bubbleView.leftAnchor.constraint(equalTo: photoView.leftAnchor).isActive = true
        bubbleView.rightAnchor.constraint(equalTo: photoView.rightAnchor).isActive = true
        
        fileSizeLabel.topAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: 2).isActive = true
        activityIndicator.heightAnchor.constraint(equalToConstant: 40).isActive = true
        activityIndicator.widthAnchor.constraint(equalToConstant: 50).isActive = true
        activityIndicator.centerXAnchor.constraint(equalTo: photoView.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: photoView.centerYAnchor).isActive = true

        uploadButton.centerXAnchor.constraint(equalTo: photoView.centerXAnchor).isActive = true
        uploadButton.centerYAnchor.constraint(equalTo: photoView.centerYAnchor).isActive = true
        uploadButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        uploadButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        downloadButton.centerXAnchor.constraint(equalTo: photoView.centerXAnchor).isActive = true
        downloadButton.centerYAnchor.constraint(equalTo: photoView.centerYAnchor).isActive = true
        downloadButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        downloadButton.widthAnchor.constraint(equalToConstant: 50).isActive = true

    }

    @objc private func downloadButtonAction(_ selector: UIButton) {
        downloadTapped?(true)
    }

    func updateView(for state: state) {
        DispatchQueue.main.async {
            self.updateView(state: state)
        }
    }

    private func updateView(state: state) {
        switch state {
        case .upload(let filePath):
            frontView.isUserInteractionEnabled = false
            activityIndicator.isHidden = true
            downloadButton.isHidden = true
            let docDirPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let path = docDirPath.appendingPathComponent(filePath)
            photoView.kf.setImage(with: path)
            uploadButton.isHidden = false
        case .uploaded:
            if activityIndicator.isAnimating{
                activityIndicator.stopAnimating()
            }
            frontView.isUserInteractionEnabled = true
            uploadButton.isHidden = true
            activityIndicator.isHidden = true
            downloadButton.isHidden = true
        case .uploading( _):
            uploadButton.isHidden = true
            frontView.isUserInteractionEnabled = false
            activityIndicator.isHidden = false
            if !activityIndicator.isAnimating{
                activityIndicator.startAnimating()
            }
            downloadButton.isHidden = true
        case .download:
            downloadButton.isHidden = false
            frontView.isUserInteractionEnabled = false
            activityIndicator.isHidden = true
            uploadButton.isHidden = true
            let thumbnailUrl = viewModel?.thumbnailURL
            photoView.kf.setImage(with: thumbnailUrl)
        case .downloading:
            uploadButton.isHidden = true
            activityIndicator.isHidden = false
            if !activityIndicator.isAnimating{
                activityIndicator.startAnimating()
            }
            downloadButton.isHidden = true
            frontView.isUserInteractionEnabled = false
        case .downloaded(let filePath):
            activityIndicator.isHidden = false
            if !activityIndicator.isAnimating{
                activityIndicator.startAnimating()
            }
            if activityIndicator.isAnimating{
                activityIndicator.stopAnimating()
            }
            viewModel?.filePath = filePath
            let docDirPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let path = docDirPath.appendingPathComponent(filePath)
            photoView.kf.setImage(with: path)
            frontView.isUserInteractionEnabled = true
            uploadButton.isHidden = true
            activityIndicator.isHidden = true
            downloadButton.isHidden = true
        }
    }

    func setImage(imageView: UIImageView, name: String) {
        DispatchQueue.global(qos: .background).async {
            let docDirPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let path = docDirPath.appendingPathComponent(name)
            do {
                let data = try Data(contentsOf: path)
                DispatchQueue.main.async {
                    imageView.image = UIImage(data: data)
                }
            } catch {
                DispatchQueue.main.async {
                    imageView.image = nil
                }
            }
        }
    }

    @objc private func uploadButtonAction(_ selector: UIButton) {
        uploadTapped?(true)
    }

    fileprivate func updateDbMessageWith(key: String, value: String, filePath: String) {
        let messageService = ALMessageDBService()
        let alHandler = ALDBHandler.sharedInstance()
        let dbMessage: DB_Message = messageService.getMessageByKey(key, value: value) as! DB_Message
        dbMessage.filePath = filePath
        do {
            try alHandler?.managedObjectContext.save()
        } catch {
            NSLog("Not saved due to error")
        }
    }

    func menuReply(_ sender: Any) {
        menuAction?(.reply)
    }
}

extension ALKPhotoCell: ALKHTTPManagerUploadDelegate {
    func dataUploaded(task: ALKUploadTask) {
        NSLog("VIDEO CELL DATA UPDATED AND FILEPATH IS: %@", viewModel?.filePath ?? "")
        DispatchQueue.main.async {
            print("task filepath:: ", task.filePath ?? "")
            self.updateView(for: .uploading(filePath: task.filePath ?? ""))
        }
    }

    func dataUploadingFinished(task: ALKUploadTask) {
        NSLog("VIDEO CELL DATA UPLOADED FOR PATH: %@", viewModel?.filePath ?? "")
        if task.uploadError == nil && task.completed == true && task.filePath != nil {
            DispatchQueue.main.async {
                self.updateView(for: state.uploaded)
            }
        } else {
            DispatchQueue.main.async {
                self.updateView(for: .upload(filePath: task.filePath ?? ""))
            }
        }
    }
}

extension ALKPhotoCell: ALKHTTPManagerDownloadDelegate {
    func dataDownloaded(task: ALKDownloadTask) {
        NSLog("Image Bytes downloaded: %i", task.totalBytesDownloaded)
        DispatchQueue.main.async {
            self.updateView(for: .downloading)
        }
    }

    func dataDownloadingFinished(task: ALKDownloadTask) {
        guard task.downloadError == nil, let filePath = task.filePath, let identifier = task.identifier, let _ = self.viewModel else {
            updateView(for: .download)
            return
        }
        self.updateDbMessageWith(key: "key", value: identifier, filePath: filePath)
        DispatchQueue.main.async {
            self.updateView(for: .downloaded(filePath: filePath))
        }
    }
}
