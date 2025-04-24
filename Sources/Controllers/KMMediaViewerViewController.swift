//
//  KMMediaViewerViewController.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by Abhijeet Ranjan on 24/04/25.
//

import UIKit
import AVKit

final class KMMediaViewerViewController: UIViewController {

    // MARK: - Properties

    private let viewModel: ALKMediaViewerViewModel
    private var playerViewController: AVPlayerViewController?

    // MARK: - Initialization

    init(viewModel: ALKMediaViewerViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavigationBar()
        setupCloseButtonIfNeeded()
        playCurrentVideo()
    }

    // MARK: - Setup Methods

    private func setupView() {
        view.backgroundColor = .black
    }

    private func setupNavigationBar() {
        navigationItem.title = viewModel.getTitle()
    }

    private func setupCloseButtonIfNeeded() {
        guard isPresentedModally(),
              let closeImage = UIImage(named: "close", in: Bundle.km, compatibleWith: nil)?
                .withRenderingMode(.alwaysTemplate) else { return }

        let closeButton = KMExtendedTouchAreaButton(type: .custom)
        closeButton.setImage(closeImage, for: .normal)
        closeButton.tintColor = .white
        closeButton.backgroundColor = .clear
        closeButton.imageView?.contentMode = .scaleAspectFit
        closeButton.addTarget(self, action: #selector(dismissViewController), for: .touchUpInside)

        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: closeButton)
    }

    // MARK: - Video Playback

    private func playCurrentVideo() {
        guard
            let message = viewModel.getMessageForCurrentIndex(),
            let filePath = message.filePath,
            !filePath.isEmpty
        else {
            print("Local video file path is missing")
            return
        }

        let videoURL = viewModel.getURLFor(name: filePath)

        guard FileManager.default.fileExists(atPath: videoURL.path) else {
            print("⚠️ Video file does not exist at path: \(videoURL.path)")
            return
        }

        print("🎥 Playing video from: \(videoURL.path)")
        setupPlayer(with: videoURL)
    }

    private func setupPlayer(with url: URL) {
        let player = AVPlayer(url: url)
        let playerVC = AVPlayerViewController()
        playerVC.player = player
        playerVC.showsPlaybackControls = true
        playerVC.view.translatesAutoresizingMaskIntoConstraints = false

        addChild(playerVC)
        view.addSubview(playerVC.view)
        playerVC.didMove(toParent: self)

        NSLayoutConstraint.activate([
            playerVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            playerVC.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            playerVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        player.play()
        self.playerViewController = playerVC
    }

    // MARK: - Actions

    @objc private func dismissViewController() {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Utility

    private func isPresentedModally() -> Bool {
        presentingViewController != nil ||
        navigationController?.presentingViewController?.presentedViewController == navigationController
    }
}

// MARK: - ALKMediaViewerViewModelDelegate

extension KMMediaViewerViewController: ALKMediaViewerViewModelDelegate {
    func reloadView() {
        navigationItem.title = viewModel.getTitle()
        playerViewController?.player?.pause()
        playerViewController?.view.removeFromSuperview()
        playerViewController?.removeFromParent()
        playerViewController = nil
        playCurrentVideo()
    }
}
