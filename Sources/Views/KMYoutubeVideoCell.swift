//
//  KMYoutubeVideoCell.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by Abhijeet Ranjan on 22/11/23.
//

import Foundation
import UIKit
import WebKit

class KMYoutubeVideoCell: UITableViewCell {

    var webView: WKWebView = {
        let webView = WKWebView()
        webView.scrollView.isScrollEnabled = false
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.backgroundColor = .gray
        webView.layer.borderColor = UIColor.gray.cgColor
        webView.layer.borderWidth = 1
        webView.layer.cornerRadius = 5
        webView.layer.masksToBounds = true
        return webView
    }()

    var captionLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .gray
        lbl.font = UIFont.boldSystemFont(ofSize: 12)
        return lbl
    }()

    var viewModel: VideoTemplate?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.isUserInteractionEnabled = true
        addConstraints()
        self.backgroundColor = .clear
    }

    func addConstraints() {
        addViewsForAutolayout(views: [webView, captionLabel])

        webView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        webView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        webView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.48).isActive = true

        captionLabel.topAnchor.constraint(equalTo: webView.bottomAnchor).isActive = true
        captionLabel.centerXAnchor.constraint(equalTo: webView.centerXAnchor).isActive = true
        captionLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }

    func updateVideModel(model: VideoTemplate) {
        self.viewModel = model
        captionLabel.text = model.caption ?? ""
        loadYouTubeVideo(url: model.url)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func loadYouTubeVideo(url: String) {
        guard let youtubeURL = URL(string: "\(url)?rel=0&showinfo=0&controls=0&modestbranding=1") else {
            return }
        
        let request = URLRequest(url: youtubeURL)
        webView.load(request)
    }
}
