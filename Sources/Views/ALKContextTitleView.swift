//
//  ALKContextTitleView.swift
//  ApplozicSwift
//
//  Created by Mukesh Thawani on 04/12/17.
//

import UIKit
import Kingfisher

protocol ALKContextTitleViewType {
    func configureWith(value: ALKContextTitleDataType)
}

public final class ALKContextTitleView: UIView, ALKContextTitleViewType {

    private var viewModel: ALKContextTitleViewModelType?

    //MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: - Public Methods

    public func configureWith(value data: ALKContextTitleDataType) {
        self.viewModel = ALKContextTitleViewModel(data: data)
        setupUI()
    }

    //MARK: - Private Methods

    private let contextImageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect.zero)
        return imageView
    }()

    private func setupUI() {
        setupConstraints()
        let imageUrl = viewModel?.getTitleImageURL()
        contextImageView.kf.setImage(with: imageUrl)
    }

    private func setupConstraints() {
        let view = self
        view.addViewsForAutolayout(views: [contextImageView])
        contextImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        contextImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
        contextImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10).isActive = true
        contextImageView.widthAnchor.constraint(equalTo: contextImageView.heightAnchor).isActive = true


        view.layoutIfNeeded()
    }

}
