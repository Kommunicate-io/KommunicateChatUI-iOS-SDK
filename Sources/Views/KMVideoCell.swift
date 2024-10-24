//
//  KMVideoCell.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by sathyan elangovan on 28/09/23.
//

import Foundation
import UIKit
import AVFoundation
import AVKit


class KMVideoCell: UITableViewCell {
    
    var progressView: KDCircularProgress = {
        let view = KDCircularProgress(frame: .zero)
        view.startAngle = -90
        view.clockwise = true
        return view
    }()
    public var tapped: ((_ url: String) -> Void)?

    fileprivate var playButton: UIButton = {
        let button = UIButton(type: .custom)
        let image = UIImage(named: "PLAY", in: Bundle.km, compatibleWith: nil)
        button.setImage(image, for: .normal)
        button.accessibilityIdentifier = "KMVideoPlayer"
        return button
    }()
    
    var photoView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .darkGray
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    var captionLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .gray
        lbl.font = Font.bold(size: 12).font()
        lbl.numberOfLines = 0
        lbl.lineBreakMode = .byWordWrapping
        lbl.textAlignment = .center
        return lbl
    }()
    
    var viewModel: KMVideoTemplate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.isUserInteractionEnabled = true
        addConstraints()
        self.backgroundColor = .clear
    }
    
    func addConstraints() {
        addViewsForAutolayout(views: [photoView, captionLabel, playButton, progressView])
        
        photoView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        photoView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        photoView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        photoView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.48).isActive = true
        
        captionLabel.topAnchor.constraint(equalTo: photoView.bottomAnchor).isActive = true
        captionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5).isActive = true
        captionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5).isActive = true
        captionLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        playButton.centerXAnchor.constraint(equalTo: photoView.centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo: photoView.centerYAnchor).isActive = true
        playButton.widthAnchor.constraint(equalToConstant: 50.0).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        playButton.addTarget(self, action: #selector(playButtonAction(_:)), for: .touchUpInside)

        progressView.heightAnchor.constraint(equalToConstant: 25.0).isActive = true
        progressView.widthAnchor.constraint(equalToConstant: 25.0).isActive = true
        progressView.centerXAnchor.constraint(equalTo: photoView.centerXAnchor).isActive = true
        progressView.centerYAnchor.constraint(equalTo: photoView.centerYAnchor).isActive = true
        
        playButton.isHidden = true
        photoView.layer.borderColor = UIColor.gray.cgColor
        photoView.layer.borderWidth = 1
        photoView.layer.cornerRadius = 5
    }
    
    
    func updateVideModel(model: KMVideoTemplate) {
        self.viewModel = model
        captionLabel.text = model.caption ?? ""
        if let url = URL(string:model.url) {
            self.setThumbnailImageFromVideoUrl(url: url)
        } else {
            playButton.isHidden = false
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func playButtonAction(_: UIButton) {
        guard let model = viewModel else {return}
        tapped?(model.url)
    }
    
    
    func setThumbnailImageFromVideoUrl(url: URL) {
        DispatchQueue.global().async {
            self.progressView.isHidden = false
            let asset = AVAsset(url: url)
            let avAssetImageGenerator = AVAssetImageGenerator(asset: asset)
            avAssetImageGenerator.appliesPreferredTrackTransform = true
            let thumnailTime = CMTimeMake(value: 2, timescale: 1)
            do {
                let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumnailTime, actualTime: nil)
                let thumbImage = UIImage(cgImage: cgThumbImage)
                DispatchQueue.main.async {
                    self.photoView.image = thumbImage
                    self.progressView.isHidden = true
                    self.playButton.isHidden = false
                }
            } catch {
                print(error.localizedDescription) //10
                self.progressView.isHidden = true
                self.playButton.isHidden = false
            }
        }
    }
}
