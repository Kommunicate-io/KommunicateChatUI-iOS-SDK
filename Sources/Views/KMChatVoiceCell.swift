//
//  KMChatVoiceCell.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by Mukesh Thawani on 04/05/17.
//

import Foundation
#if canImport(RichMessageKit)
    import RichMessageKit
#endif
import AVFoundation
import Kingfisher
import KommunicateCore_iOS_SDK
import UIKit

protocol KMChatVoiceCellProtocol: AnyObject {
    func playAudioPress(identifier: String)
}

public enum KMChatVoiceCellState {
    case playing
    case stop
    case pause
}

class KMChatVoiceCell: KMChatChatBaseCell<KMChatMessageViewModel>,
    KMChatReplyMenuItemProtocol, KMChatReportMessageMenuItemProtocol {
    var soundPlayerView: UIView = {
        let mv = UIView()
        mv.contentMode = .scaleAspectFill
        mv.clipsToBounds = true
        return mv
    }()

    fileprivate let frameView: KMChatTappableView = {
        let view = KMChatTappableView()
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
        progress.clipsToBounds = true
        progress.layer.cornerRadius = 12
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

    var downloadTapped: ((Bool) -> Void)?

    class func topPadding() -> CGFloat {
        return 12
    }

    class func bottomPadding() -> CGFloat {
        return 12
    }

    override class func rowHeigh(viewModel _: KMChatMessageViewModel, width _: CGFloat) -> CGFloat {
        let heigh: CGFloat
        heigh = 37
        return topPadding() + heigh + bottomPadding()
    }

    func getTimeString(secLeft: CGFloat) -> String {
        let min = (Int(secLeft) / 60) % 60
        let sec = (Int(secLeft) % 60)
        let minStr = String(min)
        var secStr = String(sec)
        if sec < 10 { secStr = "0\(secStr)" }

        return "\(minStr):\(secStr)"
    }

    override func update(viewModel: KMChatMessageViewModel) {
        super.update(viewModel: viewModel)

        // Auto-Download
        if viewModel.filePath == nil {
            downloadTapped?(true)
        } else if let filePath = viewModel.filePath {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            if let data = NSData(contentsOfFile: documentsURL.appendingPathComponent(filePath).path) as Data? {
                updateViewForDownloadedState(data: data)
            }
        }

        let timeLeft = Int(viewModel.voiceTotalDuration) - Int(viewModel.voiceCurrentDuration)
        let totalTime = Int(viewModel.voiceTotalDuration)
        let percent = viewModel.voiceTotalDuration == 0 ? 0 : Float(timeLeft) / Float(totalTime)

        let currentPlayTime = CGFloat(timeLeft)

        if viewModel.voiceCurrentState == .pause && viewModel.voiceCurrentDuration > 0 {
            actionButton.isSelected = false
            playTimeLabel.text = getTimeString(secLeft: viewModel.voiceTotalDuration)
        } else if viewModel.voiceCurrentState == .playing {
            print("identifier: ", viewModel.identifier)
            actionButton.isSelected = true
            playTimeLabel.text = getTimeString(secLeft: currentPlayTime)
        } else if viewModel.voiceCurrentState == .stop {
            actionButton.isSelected = false
            playTimeLabel.text = getTimeString(secLeft: currentPlayTime)
        } else {
            actionButton.isSelected = false
            playTimeLabel.text = getTimeString(secLeft: currentPlayTime)
        }

        if viewModel.voiceCurrentState == .stop || viewModel.voiceCurrentDuration == 0 {
            progressBar.setProgress(0, animated: false)
        } else {
            progressBar.setProgress(Float(percent), animated: false)
        }
        timeLabel.text = viewModel.time
    }

    weak var voiceDelegate: KMChatVoiceCellProtocol?

    func setCellDelegate(delegate: KMChatVoiceCellProtocol) {
        voiceDelegate = delegate
    }

    @objc func actionTapped() {
        guard let identifier = viewModel?.identifier else { return }
        voiceDelegate?.playAudioPress(identifier: identifier)
    }

    override func setupStyle() {
        super.setupStyle()
        timeLabel.setStyle(KMChatMessageStyle.time)
        playTimeLabel.setStyle(KMChatMessageStyle.playTime)
    }

    override func setupViews() {
        super.setupViews()

        accessibilityIdentifier = "audioCell"

        var playIcon = UIImage(named: "icon_play", in: Bundle.km, compatibleWith: nil)
        playIcon = playIcon?.imageFlippedForRightToLeftLayoutDirection()

        var pauseIcon = UIImage(named: "icon_pause", in: Bundle.km, compatibleWith: nil)
        pauseIcon = pauseIcon?.imageFlippedForRightToLeftLayoutDirection()

        actionButton.setImage(playIcon, for: .normal)
        actionButton.setImage(pauseIcon, for: .selected)

        frameView.addGestureRecognizer(longPressGesture)
        actionButton.addTarget(self, action: #selector(actionTapped), for: .touchUpInside)
        clearButton.addTarget(self, action: #selector(KMChatVoiceCell.soundPlayerAction), for: .touchUpInside)

        contentView.addViewsForAutolayout(views: [soundPlayerView, bubbleView, progressBar, actionButton, playTimeLabel, frameView, timeLabel, clearButton])
        contentView.bringSubviewToFront(soundPlayerView)
        contentView.bringSubviewToFront(progressBar)
        contentView.bringSubviewToFront(playTimeLabel)
        contentView.bringSubviewToFront(clearButton)
        contentView.bringSubviewToFront(frameView)
        contentView.bringSubviewToFront(actionButton)

        bubbleView.topAnchor.constraint(equalTo: soundPlayerView.topAnchor).isActive = true
        bubbleView.bottomAnchor.constraint(equalTo: soundPlayerView.bottomAnchor).isActive = true
        bubbleView.leadingAnchor.constraint(equalTo: soundPlayerView.leadingAnchor).isActive = true
        bubbleView.trailingAnchor.constraint(equalTo: soundPlayerView.trailingAnchor).isActive = true

        progressBar.topAnchor.constraint(equalTo: soundPlayerView.topAnchor).isActive = true
        progressBar.bottomAnchor.constraint(equalTo: soundPlayerView.bottomAnchor).isActive = true
        progressBar.leadingAnchor.constraint(equalTo: soundPlayerView.leadingAnchor).isActive = true
        progressBar.trailingAnchor.constraint(equalTo: soundPlayerView.trailingAnchor, constant: -2).isActive = true

        frameView.topAnchor.constraint(equalTo: soundPlayerView.topAnchor, constant: 0).isActive = true
        frameView.bottomAnchor.constraint(equalTo: soundPlayerView.bottomAnchor, constant: 0).isActive = true
        frameView.leadingAnchor.constraint(equalTo: soundPlayerView.leadingAnchor, constant: 0).isActive = true
        frameView.trailingAnchor.constraint(equalTo: soundPlayerView.trailingAnchor, constant: 0).isActive = true

        clearButton.topAnchor.constraint(equalTo: soundPlayerView.topAnchor).isActive = true
        clearButton.bottomAnchor.constraint(equalTo: soundPlayerView.bottomAnchor).isActive = true
        clearButton.leadingAnchor.constraint(equalTo: soundPlayerView.leadingAnchor).isActive = true
        clearButton.trailingAnchor.constraint(equalTo: soundPlayerView.trailingAnchor).isActive = true

        actionButton.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
        actionButton.leadingAnchor.constraint(equalTo: soundPlayerView.leadingAnchor, constant: 0).isActive = true
        actionButton.widthAnchor.constraint(equalToConstant: 45).isActive = true
        actionButton.heightAnchor.constraint(equalToConstant: 45).isActive = true

        playTimeLabel.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
        playTimeLabel.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
        playTimeLabel.leadingAnchor.constraint(greaterThanOrEqualTo: actionButton.leadingAnchor, constant: 25).isActive = true
        playTimeLabel.trailingAnchor.constraint(greaterThanOrEqualTo: actionButton.trailingAnchor, constant: 25).isActive = true
    }

    deinit {
        clearButton.removeTarget(self, action: #selector(KMChatVoiceCell.soundPlayerAction), for: .touchUpInside)
        actionButton.removeTarget(self, action: #selector(actionTapped), for: .touchUpInside)
    }

    func updateViewForDownloadedState(data: Data) {
        do {
            let player = try AVAudioPlayer(data: data, fileTypeHint: AVFileType.wav.rawValue)
            viewModel?.voiceData = data
            viewModel?.voiceTotalDuration = CGFloat(player.duration)
            playTimeLabel.text = getTimeString(secLeft: viewModel!.voiceTotalDuration)
        } catch {
            print(error)
        }
    }

    @objc private func soundPlayerAction() {
        guard isMessageSent() else { return }
        showMediaViewer()
    }

    private func isMessageSent() -> Bool {
        guard let viewModel = viewModel else { return false }
        return viewModel.isSent || viewModel.isAllReceived || viewModel.isAllRead
    }

    private func showMediaViewer() {
        let storyboard = UIStoryboard.name(storyboard: UIStoryboard.Storyboard.mediaViewer, bundle: Bundle.km)

        let nav = storyboard.instantiateInitialViewController() as? UINavigationController
        let vc = nav?.viewControllers.first as? KMChatMediaViewerViewController
        let dbService = KMCoreMessageDBService()
        guard let messages = dbService.getAllMessagesWithAttachment(
            forContact: viewModel?.contactId,
            andChannelKey: viewModel?.channelKey,
            onlyDownloadedAttachments: true
        ) as? [KMCoreMessage] else { return }

        let messageModels = messages.map { $0.messageModel }
        NSLog("Messages with attachment: ", messages)

        guard let viewModel = viewModel as? KMChatMessageModel,
              let currentIndex = messageModels.firstIndex(of: viewModel) else { return }
        vc?.viewModel = KMChatMediaViewerViewModel(messages: messageModels, currentIndex: currentIndex, localizedStringFileName: localizedStringFileName)
        UIViewController.topViewController()?.present(nav!, animated: true, completion: {})
    }

    func menuReply(_: Any) {
        menuAction?(.reply)
    }

    func menuReport(_: Any) {
        menuAction?(.report)
    }
}

extension KMChatVoiceCell: KMChatHTTPManagerDownloadDelegate {
    func dataDownloaded(task _: KMChatDownloadTask) {}

    func dataDownloadingFinished(task: KMChatDownloadTask) {
        // update viewmodel's data field and time and then call update
        guard task.downloadError == nil, let filePath = task.filePath, let identifier = task.identifier, viewModel != nil else {
            return
        }
        KMCoreMessageDBService().updateDbMessageWith(key: "key", value: identifier, filePath: filePath)
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        if let data = NSData(contentsOfFile: documentsURL.appendingPathComponent(task.filePath ?? "").path) as Data? {
            updateViewForDownloadedState(data: data)
        }
    }
}
