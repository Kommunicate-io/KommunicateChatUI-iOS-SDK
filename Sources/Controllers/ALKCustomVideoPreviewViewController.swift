//
//  ALKCustomVideoPreviewViewController.swift
//  ApplozicSwift
//
//  Created by Mukesh Thawani on 06/07/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

final class ALKCustomVideoPreviewViewController: ALKBaseViewController {

    // MARK: - Variables and Types
    private var customCamDelegate:ALKCustomCameraProtocol!

    var path: String!

    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var customVideoView: UIView!
    @IBOutlet fileprivate weak var scrollView: UIScrollView!
    @IBOutlet fileprivate weak var imageView: UIImageView!

    @IBOutlet private weak var imageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var imageViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var imageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var imageViewTrailingConstraint: NSLayoutConstraint!

    // MARK: - Lifecycle
    static func instance(with path: String) -> ALKCustomVideoPreviewViewController {
        let viewController: ALKCustomVideoPreviewViewController = UIStoryboard(storyboard: .video).instantiateViewController()
        viewController.path = path
        return viewController
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.title = "Send Video"
    }

    override func loadView() {
        super.loadView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        playVideo()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupNavigation()
    }

    private func setupNavigation() {
        self.navigationItem.title = title

        self.navigationController?.navigationBar.setBackgroundImage(UIImage(color: .main, alpha: 0.6), for: .default)
        guard let navVC = self.navigationController else {return}
        navVC.navigationBar.shadowImage = UIImage()
        navVC.navigationBar.isTranslucent = true
    }

    //    func setSelectedImage(pickImage:UIImage,camDelegate:ALKCustomCameraProtocol)
    //    {
    //        self.image = pickImage
    //        self.customCamDelegate = camDelegate
    //    }

    func setUpPath(path: String) {
        self.path = path
    }

    private func playVideo() {
        guard let path = path else {
            debugPrint("video.m4v not found")
            return
        }
        let player = AVPlayer(url: URL(fileURLWithPath: path))
        player.actionAtItemEnd = .none
        let videoLayer = AVPlayerLayer(player: player)
        videoLayer.frame = self.customVideoView.bounds
        videoLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.customVideoView.layer.addSublayer(videoLayer)

    }

    @IBAction private func sendPhotoPress(_ sender: Any) {
//        self.navigationController?.dismiss(animated: false, completion: {
//            self.customCamDelegate.customCameraDidTakePicture(cropedImage:self.image
//            )
//        })
    }
    @IBAction private func close(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: false)
    }
    @IBAction func playButtonAction(_ sender: UIButton) {

        let playerController = AVPlayerViewController()
        let player = AVPlayer(url: URL(fileURLWithPath: path))
        player.actionAtItemEnd = .pause
        playerController.player = player
        present(playerController, animated: true) {
            player.play()
        }

    }
}
