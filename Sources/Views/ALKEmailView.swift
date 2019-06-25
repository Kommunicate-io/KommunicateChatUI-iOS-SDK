//
//  ALKEmailCell.swift
//  ApplozicSwift
//
//  Created by Shivam Pokhriyal on 13/03/19.
//

import UIKit

class ALKEmailTopView: UIView {

    static let height: CGFloat = 20

    // MARK: - Private properties
    
    fileprivate var emailImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "alk_replied_icon",
                           in: Bundle.applozic,
                           compatibleWith: nil)
        imageView.isUserInteractionEnabled = false
        imageView.contentMode = .center
        imageView.isHidden = true
        return imageView
    }()

    fileprivate var emailLabel: UILabel = {
        let label = UILabel()
        label.text = "via email"
        label.numberOfLines = 1
        label.font = UIFont(name: "Helvetica", size: 12)
        label.isOpaque = true
        label.isHidden = true
        return label
    }()

    // MARK: - Initializer

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Internal APIs

    func show(_ show: Bool) {
        emailImage.isHidden = !show
        emailLabel.isHidden = !show
    }

    // MARK: - Private helper methods

    private func setupConstraints() {
        self.backgroundColor = .clear
        self.addViewsForAutolayout(views: [emailImage, emailLabel])

        NSLayoutConstraint.activate ([
            emailImage.topAnchor.constraint(equalTo: topAnchor),
            emailImage.leadingAnchor.constraint(equalTo: leadingAnchor),
            emailImage.heightAnchor.constraint(equalToConstant: ALKEmailTopView.height),
            emailImage.widthAnchor.constraint(equalToConstant: ALKEmailTopView.height),

            emailLabel.topAnchor.constraint(equalTo: topAnchor),
            emailLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            emailLabel.leadingAnchor.constraint(equalTo: emailImage.trailingAnchor),
            emailLabel.heightAnchor.constraint(equalToConstant: ALKEmailTopView.height)
            ])
    }

}
