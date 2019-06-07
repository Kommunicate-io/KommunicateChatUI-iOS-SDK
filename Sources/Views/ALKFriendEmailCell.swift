//
//  ALKEmailCell.swift
//  ApplozicSwift
//
//  Created by apple on 24/12/18.
//

import Foundation
import UIKit
import Kingfisher

open class ALKFriendEmailCell: UITableViewCell {

    struct Padding {
        struct NameLabel {
            static let top: CGFloat =  6
            static let leading: CGFloat =  57
            static let trailing: CGFloat =  57
            static let height: CGFloat =  16
        }

        struct AvatarImageView {
            static let top: CGFloat =  18
            static let leading: CGFloat =  9
            static let width: CGFloat =  37
            static let height: CGFloat =  37
        }

        struct EmailView {
            static let top: CGFloat =  10
            static let trailing: CGFloat =  50
            static let leading: CGFloat =  10
        }

        struct TimeLabel {
            static let top: CGFloat =  1
            static let trailing: CGFloat =  10
            static let width: CGFloat =  50
            static let height: CGFloat =  37
        }
    }

    // MARK: - Properties

    lazy var emailView = ALKEmailView(frame: .zero)

    private var avatarImageView: UIImageView = {
        let imv = UIImageView()
        imv.contentMode = .scaleAspectFill
        imv.clipsToBounds = true
        let layer = imv.layer
        layer.cornerRadius = 18.5
        layer.masksToBounds = true
        imv.isUserInteractionEnabled = true
        return imv
    }()

    private var nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.isOpaque = true
        return label
    }()

    fileprivate var timeLabel: UILabel = {
        let timeLabel = UILabel()
        timeLabel.isOpaque = true
        return timeLabel
    }()

    lazy var emailViewHeight = emailView.heightAnchor.constraint(equalToConstant: ALKEmailView.rowHeight(nil))

    // MARK: - Initializer

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupConstraints()
        setupStyle()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Internal methods

    func update(viewModel: ALKMessageViewModel) {
        guard let emailMessage = viewModel.message else { return }
        emailView.loadWebView(with: emailMessage)
        nameLabel.text = viewModel.displayName
        timeLabel.text = viewModel.time

        let placeHolder = UIImage(named: "placeholder", in: Bundle.applozic, compatibleWith: nil)
        guard let url = viewModel.avatarURL else {
            self.avatarImageView.image = placeHolder
            return
        }
        let resource = ImageResource(downloadURL: url, cacheKey: url.absoluteString)
        avatarImageView.kf.setImage(with: resource, placeholder: placeHolder, options: nil, progressBlock: nil, completionHandler: nil)
    }

    func updateHeight(_ height: CGFloat?) {
        emailView.updateHeight(height)
        emailViewHeight.constant = ALKEmailView.rowHeight(height)
    }

    class func rowHeight(viewModel: ALKMessageViewModel, height: CGFloat?) -> CGFloat {
        var totalHeight: CGFloat = 0
        totalHeight += Padding.NameLabel.height + Padding.NameLabel.top
        totalHeight += Padding.TimeLabel.height + Padding.TimeLabel.top  /// time height
        totalHeight += ALKEmailView.rowHeight(height) + Padding.EmailView.top
        return totalHeight
    }

    // MARK: - Private helper methods

    private func setupConstraints() {
        contentView.addViewsForAutolayout(views: [avatarImageView, nameLabel, emailView, timeLabel])

        nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Padding.NameLabel.top).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Padding.NameLabel.leading).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Padding.NameLabel.trailing).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: Padding.NameLabel.height).isActive = true

        avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Padding.AvatarImageView.top).isActive = true
        avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Padding.AvatarImageView.leading).isActive = true
        avatarImageView.heightAnchor.constraint(equalToConstant: Padding.AvatarImageView.height).isActive = true
        avatarImageView.widthAnchor.constraint(equalToConstant: Padding.AvatarImageView.width ).isActive = true

        emailView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: Padding.EmailView.top).isActive = true
        emailView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Padding.EmailView.trailing).isActive = true
        emailView.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: Padding.EmailView.leading).isActive = true
        emailViewHeight.isActive = true

        timeLabel.topAnchor.constraint(equalTo: emailView.bottomAnchor, constant: Padding.TimeLabel.top).isActive = true
        timeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Padding.TimeLabel.trailing).isActive = true
        timeLabel.heightAnchor.constraint(equalToConstant: Padding.TimeLabel.height).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: Padding.TimeLabel.width).isActive = true
    }

    private func setupStyle() {
        contentView.backgroundColor = UIColor.clear
        timeLabel.setStyle(ALKMessageStyle.time)
        nameLabel.setStyle(ALKMessageStyle.displayName)
    }

}
