//
//  ALKVoiceCell.swift
//  ApplozicSwift
//
//  Created by Mukesh Thawani on 04/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import Foundation

import UIKit
import Foundation
import Kingfisher
import AVFoundation
import Applozic

protocol ALKVoiceCellProtocol: class {
    func playAudioPress(identifier: String)
}

public enum ALKVoiceCellState {
    case playing
    case stop
    case pause
}

class ALKVoiceCell:ALKChatBaseCell<ALKMessageViewModel>,
                    ALKReplyMenuItemProtocol {
    
    var soundPlayerView: UIView = {
        let mv = UIView()
        mv.backgroundColor = UIColor.background(.grayF2)
        mv.contentMode = .scaleAspectFill
        mv.clipsToBounds = true
        mv.layer.cornerRadius = 12
        return mv
    }()
    
    fileprivate let frameView: ALKTappableView = {
        let view = ALKTappableView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = true
        return view
    }()
    
    var playTimeLabel: UILabel = {
        let lb = UILabel()
        return lb
    }()
    
    var progressBar: UIProgressView = {
        let progress = UIProgressView()
        progress.trackTintColor = UIColor.clear
        progress.tintColor = UIColor.background(.main).withAlphaComponent(0.32)
        return progress
    }()
    
    var timeLabel: UILabel = {
        let lb = UILabel()
        return lb
    }()
    
    var actionButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .clear
        return button
    }()
    
    var clearButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .clear
        return button
    }()
    
    var bubbleView: UIView = {
        let bv = UIView()
        bv.backgroundColor = .gray
        bv.layer.cornerRadius = 12
        bv.isUserInteractionEnabled = false
        return bv
    }()

    var downloadTapped:((Bool)->())?
    
    class func topPadding() -> CGFloat {
        return 12
    }
    
    class func bottomPadding() -> CGFloat {
        return 12
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override class func rowHeigh(viewModel: ALKMessageViewModel,width: CGFloat) -> CGFloat {
        
        let heigh: CGFloat
        heigh = 37
        return topPadding()+heigh+bottomPadding()
    }
    
    
    func getTimeString(secLeft:CGFloat) -> String {
        
        let min = (Int(secLeft) / 60) % 60
        let sec = (Int(secLeft) % 60)
        let minStr = String(min)
        var secStr = String(sec)
        if sec < 10 {secStr = "0\(secStr)"}
        
        return "\(minStr):\(secStr)"
    }
    
    
    override func update(viewModel: ALKMessageViewModel) {
        super.update(viewModel: viewModel)

        /// Auto-Download
        if viewModel.filePath == nil {
            downloadTapped?(true)
        } else if let filePath = viewModel.filePath {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            if let data = NSData(contentsOfFile: (documentsURL.appendingPathComponent(filePath)).path) as Data? {
                updateViewForDownloadedState(data: data)
            }
        }

        if viewModel.voiceCurrentState == .pause && viewModel.voiceCurrentDuration > 0{
            actionButton.isSelected = false
            playTimeLabel.text = getTimeString(secLeft:viewModel.voiceCurrentDuration)
        } else if viewModel.voiceCurrentState == .playing {
            print("identifier: ", viewModel.identifier)
            actionButton.isSelected = true
            playTimeLabel.text = getTimeString(secLeft:viewModel.voiceCurrentDuration)
        }
        else if viewModel.voiceCurrentState == .stop {
            actionButton.isSelected = false
            playTimeLabel.text = getTimeString(secLeft:viewModel.voiceTotalDuration)
        } else {
            actionButton.isSelected = false
            playTimeLabel.text = getTimeString(secLeft:viewModel.voiceTotalDuration)
        }
        
        let timeLeft = Int(viewModel.voiceTotalDuration)-Int(viewModel.voiceCurrentDuration)
        let totalTime = Int(viewModel.voiceTotalDuration)
        let percent = viewModel.voiceTotalDuration == 0 ? 0 : Float(timeLeft)/Float(totalTime)
        
        if viewModel.voiceCurrentState == .stop || viewModel.voiceCurrentDuration == 0 {
            progressBar.setProgress(0, animated: false)
        }
        else {
            progressBar.setProgress(Float(percent), animated: false)
        }
        timeLabel.text   = viewModel.time
    }
    
    weak var voiceDelegate: ALKVoiceCellProtocol?
    
    func setCellDelegate(delegate:ALKVoiceCellProtocol) {
        voiceDelegate = delegate
    }
    
    func actionTapped() {
        guard let identifier = viewModel?.identifier else {return}
        voiceDelegate?.playAudioPress(identifier: identifier)
    }
    
    override func setupStyle() {
        super.setupStyle()
        timeLabel.setStyle(style: ALKMessageStyle.time)
        playTimeLabel.setStyle(style: ALKMessageStyle.playTime)
    }
    
    override func setupViews() {
        super.setupViews()

        actionButton.setImage(UIImage(named: "icon_play", in: Bundle.applozic, compatibleWith: nil), for: .normal)
        actionButton.setImage(UIImage(named: "icon_pause", in: Bundle.applozic, compatibleWith: nil), for: .selected)

        frameView.addGestureRecognizer(longPressGesture)
        actionButton.addTarget(self, action: #selector(actionTapped), for: .touchUpInside)
        clearButton.addTarget(self, action: #selector(ALKVoiceCell.soundPlayerAction), for: .touchUpInside)

        contentView.addViewsForAutolayout(views: [soundPlayerView,bubbleView,progressBar,actionButton,playTimeLabel,frameView,timeLabel,clearButton])
        contentView.bringSubview(toFront: soundPlayerView)
        contentView.bringSubview(toFront: progressBar)
        contentView.bringSubview(toFront: playTimeLabel)
        contentView.bringSubview(toFront: clearButton)
        contentView.bringSubview(toFront: frameView)
        contentView.bringSubview(toFront: actionButton)
        
        bubbleView.topAnchor.constraint(equalTo: soundPlayerView.topAnchor).isActive = true
        bubbleView.bottomAnchor.constraint(equalTo: soundPlayerView.bottomAnchor).isActive = true
        bubbleView.leftAnchor.constraint(equalTo: soundPlayerView.leftAnchor).isActive = true
        bubbleView.rightAnchor.constraint(equalTo: soundPlayerView.rightAnchor).isActive = true

        progressBar.topAnchor.constraint(equalTo: soundPlayerView.topAnchor).isActive = true
        progressBar.bottomAnchor.constraint(equalTo: soundPlayerView.bottomAnchor).isActive = true
        progressBar.leftAnchor.constraint(equalTo: soundPlayerView.leftAnchor).isActive = true
        progressBar.rightAnchor.constraint(equalTo: soundPlayerView.rightAnchor, constant: -2).isActive = true
        
        frameView.topAnchor.constraint(equalTo: soundPlayerView.topAnchor, constant: 0).isActive = true
        frameView.bottomAnchor.constraint(equalTo: soundPlayerView.bottomAnchor, constant: 0).isActive = true
        frameView.leftAnchor.constraint(equalTo: soundPlayerView.leftAnchor, constant: 0).isActive = true
        frameView.rightAnchor.constraint(equalTo: soundPlayerView.rightAnchor, constant: 0).isActive = true
        
        clearButton.topAnchor.constraint(equalTo: soundPlayerView.topAnchor).isActive = true
        clearButton.bottomAnchor.constraint(equalTo: soundPlayerView.bottomAnchor).isActive = true
        clearButton.leftAnchor.constraint(equalTo: soundPlayerView.leftAnchor).isActive = true
        clearButton.rightAnchor.constraint(equalTo: soundPlayerView.rightAnchor).isActive = true
        
        actionButton.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
        actionButton.leftAnchor.constraint(equalTo: soundPlayerView.leftAnchor,constant:0).isActive = true
        actionButton.widthAnchor.constraint(equalToConstant: 45).isActive = true
        actionButton.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        playTimeLabel.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
        playTimeLabel.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
        playTimeLabel.leftAnchor.constraint(greaterThanOrEqualTo: actionButton.leftAnchor,constant:25).isActive = true
        playTimeLabel.rightAnchor.constraint(greaterThanOrEqualTo: actionButton.rightAnchor,constant:25).isActive = true
        
    }
    
    deinit {
        clearButton.removeTarget(self, action: #selector(ALKVoiceCell.soundPlayerAction), for: .touchUpInside)
        actionButton.removeTarget(self, action: #selector(actionTapped), for: .touchUpInside)
    }

    func updateViewForDownloadedState(data: Data) {
        do {
            let player = try AVAudioPlayer(data: data, fileTypeHint: AVFileTypeWAVE)
            viewModel?.voiceData = data
            viewModel?.voiceTotalDuration = CGFloat(player.duration)
            playTimeLabel.text = getTimeString(secLeft:viewModel!.voiceTotalDuration)
        }
        catch(let error) {
            print(error)
        }
    }

    @objc private func soundPlayerAction() {
        guard isMessageSent() else { return }
        showMediaViewer()
    }

    private func isMessageSent() -> Bool {
        guard let viewModel = viewModel else { return false}
        return viewModel.isSent || viewModel.isAllReceived || viewModel.isAllRead
    }

    private func showMediaViewer() {
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
        })
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

extension ALKVoiceCell: ALKHTTPManagerDownloadDelegate {
    func dataDownloaded(task: ALKDownloadTask) {
        
    }

    func dataDownloadingFinished(task: ALKDownloadTask) {

        // update viewmodel's data field and time and then call update
        guard task.downloadError == nil, let filePath = task.filePath, let identifier = task.identifier, let _ = self.viewModel else {
            return
        }
        self.updateDbMessageWith(key: "key", value: identifier, filePath: filePath)
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        if let data = NSData(contentsOfFile: (documentsURL.appendingPathComponent(task.filePath ?? "")).path) as Data? {
            updateViewForDownloadedState(data: data)
        }
    }
}
