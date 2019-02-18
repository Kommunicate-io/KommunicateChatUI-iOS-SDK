//
//  ALKMediaViewerViewController.swift
//  ApplozicSwift
//
//  Created by Mukesh Thawani on 24/08/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import Foundation
import AVFoundation
import AVKit

final class ALKMediaViewerViewController: UIViewController {

    // to be injected
    var viewModel: ALKMediaViewerViewModel?

    @IBOutlet private weak var fakeView: UIView!

    fileprivate let scrollView: UIScrollView = {
        let sv = UIScrollView(frame: .zero)
        sv.backgroundColor = UIColor.clear
        sv.isUserInteractionEnabled = true
        sv.isScrollEnabled = true
        return sv
    }()


    fileprivate let imageView: UIImageView = {
        let mv = UIImageView(frame: .zero)
        mv.contentMode = .scaleAspectFit
        mv.backgroundColor = UIColor.clear
        mv.isUserInteractionEnabled = false
        return mv
    }()

    fileprivate let playButton: UIButton = {
        let button = UIButton(type: .custom)
        let image = UIImage(named: "PLAY", in: Bundle.applozic, compatibleWith: nil)
        button.setImage(image, for: .normal)
        return button
    }()

    fileprivate let audioPlayButton: UIButton = {
        let button = UIButton(type: .custom)
        let image = UIImage(named: "audioPlay", in: Bundle.applozic, compatibleWith: nil)
        button.imageView?.tintColor = UIColor.gray
        button.setImage(image, for: .normal)
        return button
    }()

    fileprivate let audioIcon: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.image = UIImage(named: "mic", in: Bundle.applozic, compatibleWith: nil)
        return imageView
    }()

    private weak var imageViewBottomConstraint: NSLayoutConstraint?
    private weak var imageViewTopConstraint: NSLayoutConstraint?
    private weak var imageViewTrailingConstraint: NSLayoutConstraint?
    private weak var imageViewLeadingConstraint: NSLayoutConstraint?


    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        guard let message = viewModel?.getMessageForCurrentIndex() else { return }
        updateView(message: message)
    }


    private func setupNavigation() {
        self.navigationController?.navigationBar.backgroundColor = UIColor.white
        guard let navVC = self.navigationController else {return}
        navVC.navigationBar.shadowImage = UIImage()
        navVC.navigationBar.isTranslucent = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigation()
        viewModel?.delegate = self
    }

    fileprivate func setupView() {
        playButton.addTarget(self, action: #selector(ALKMediaViewerViewController.playButtonAction(_:)), for: .touchUpInside)
        audioPlayButton.addTarget(self, action: #selector(ALKMediaViewerViewController.audioPlayButtonAction(_:)), for: .touchUpInside)
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(ALKMediaViewerViewController.swipeRightAction)) // put : at the end of method name
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        self.view.addGestureRecognizer(swipeRight)

        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(ALKMediaViewerViewController.swipeLeftAction))
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
        self.view.addGestureRecognizer(swipeLeft)
        view.addViewsForAutolayout(views: [imageView, playButton, audioPlayButton, audioIcon])
        imageView.bringSubviewToFront(playButton)
        view.bringSubviewToFront(audioPlayButton)
        view.bringSubviewToFront(audioIcon)

        playButton.centerXAnchor.constraint(equalTo: imageView.centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 80).isActive = true
        playButton.widthAnchor.constraint(equalToConstant: 80).isActive = true

        imageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true

        audioPlayButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30).isActive = true
        audioPlayButton.centerXAnchor.constraint(equalTo: imageView.centerXAnchor).isActive = true
        audioPlayButton.heightAnchor.constraint(equalToConstant: 100).isActive = true
        audioPlayButton.widthAnchor.constraint(equalToConstant: 100).isActive = true

        audioIcon.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
        audioIcon.centerXAnchor.constraint(equalTo: imageView.centerXAnchor).isActive = true
        audioIcon.heightAnchor.constraint(equalToConstant: 80).isActive = true
        audioIcon.widthAnchor.constraint(equalToConstant: 50).isActive = true

        view.layoutIfNeeded()
    }


    @IBAction private func dismissPress(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }


    @objc private func swipeRightAction() {
        viewModel?.updateCurrentIndex(by: -1)
    }

    @objc private func swipeLeftAction() {
        viewModel?.updateCurrentIndex(by: +1)
    }

    func showPhotoView(message: ALKMessageViewModel) {
        guard let filePath = message.filePath else { return }
        let url = viewModel?.getURLFor(name: filePath)
        imageView.kf.setImage(with: url)
        imageView.sizeToFit()
        playButton.isHidden = true
        audioPlayButton.isHidden = true
        audioIcon.isHidden = true
    }

    func showVideoView(message: ALKMessageViewModel) {
        guard let filePath = message.filePath,
            let url = viewModel?.getURLFor(name: filePath) else { return }
        imageView.image = viewModel?.getThumbnail(filePath: url)
        imageView.sizeToFit()
        playButton.isHidden = false
        audioPlayButton.isHidden = true
        audioIcon.isHidden = true
        guard let viewModel = viewModel,
            viewModel.isAutoPlayTrueForCurrentIndex() else { return }
        playVideo()
        viewModel.currentIndexAudioVideoPlayed()
    }

    func showAudioView(message: ALKMessageViewModel) {
        imageView.image = nil
        audioPlayButton.isHidden = false
        playButton.isHidden = true
        audioIcon.isHidden = false
        guard let viewModel = viewModel,
            viewModel.isAutoPlayTrueForCurrentIndex() else { return }
        playAudio()
        viewModel.currentIndexAudioVideoPlayed()
    }

    fileprivate func updateView(message: ALKMessageViewModel) {
        guard let viewModel = viewModel else { return }
        switch message.messageType {
        case .photo:
            print("Photo type")
            updateTitle(title: viewModel.getTitle())
            showPhotoView(message: message)
        case .video:
            print("Video type")
            updateTitle(title: viewModel.getTitle())
            showVideoView(message: message)
        case .voice:
            print("Audio type")
            updateTitle(title: viewModel.getTitle())
            showAudioView(message: message)
        default:
            print("Other type")
        }
    }

    private func updateTitle(title: String) {
        navigationItem.title = title
    }

    private func playVideo() {
        guard let message = viewModel?.getMessageForCurrentIndex(), let filePath = message.filePath,
            let url = viewModel?.getURLFor(name: filePath) else { return }
        let player = AVPlayer(url: url)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        UIViewController.topViewController()?.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }

    private func playAudio() {
        guard let message = viewModel?.getMessageForCurrentIndex(), let filePath = message.filePath,
            let url = viewModel?.getURLFor(name: filePath) else { return }
        let player = AVPlayer(url: url)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        UIViewController.topViewController()?.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }

    @objc private func playButtonAction(_ action: UIButton) {
        playVideo()
    }

    @objc private func audioPlayButtonAction(_ action: UIButton) {
        playAudio()
    }
}

extension ALKMediaViewerViewController: ALKMediaViewerViewModelDelegate {
    func reloadView() {
        guard let message = viewModel?.getMessageForCurrentIndex() else { return }
        updateView(message: message)
    }
}
