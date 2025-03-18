//
//  KMConversationInfoView.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by sathyan elangovan on 16/03/23.
//

import Foundation
import UIKit

open class KMConversationInfoView: UIView {
    private var viewModel: KMConversationInfoViewModel?
    
    private let leadingImageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect.zero)
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.numberOfLines = 0
        return label
    }()
    
    public let trailingImageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect.zero)
        return imageView
    }()
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupConstraints() {
        let view = self
        view.addViewsForAutolayout(views: [titleLabel, leadingImageView, trailingImageView])
        
        NSLayoutConstraint.activate([
            // Leading Image
            leadingImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            leadingImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 15),
            leadingImageView.widthAnchor.constraint(equalToConstant: 20),
            leadingImageView.heightAnchor.constraint(equalToConstant: 20),
            leadingImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -15),
            // Title Label
            titleLabel.leadingAnchor.constraint(equalTo: leadingImageView.trailingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: trailingImageView.leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: leadingImageView.centerYAnchor),
            // Trailing Image
            trailingImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            trailingImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 15),
            trailingImageView.widthAnchor.constraint(equalToConstant: 20),
            trailingImageView.heightAnchor.constraint(equalToConstant: 20),
            trailingImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -15)
        ])
    }
    
    public func configureViewWith(model: KMConversationInfoViewModel) {
        viewModel = model
        setupUI(viewModel: model)
    }
    
    func setupUI(viewModel: KMConversationInfoViewModel) {
        titleLabel.text = viewModel.infoContent
        leadingImageView.image = viewModel.leadingImage
        trailingImageView.image = viewModel.trailingImage
        titleLabel.font = viewModel.contentFont ?? Font.normal(size: 16.0).font()
        titleLabel.textColor = .kmDynamicColor(light: viewModel.contentColor, dark: viewModel.contentDarkColor)
    }

}
