//
//  ALKGroupMemberCell.swift
//  ApplozicSwift
//
//  Created by Shivam Pokhriyal on 08/05/19.
//

import Foundation
import Kingfisher

struct GroupMemberInfo {

    let id: String
    let name: String
    let image: String?
    let isAdmin: Bool
    let addCell: Bool
    let adminText: String?

    init(id: String, name: String, image: String?, isAdmin: Bool = false, addCell: Bool = false, adminText: String) {
        self.id = id
        self.name = name
        self.image = image
        self.isAdmin = isAdmin
        self.addCell = addCell
        self.adminText = adminText
    }

    init(name: String, addCell: Bool = true) {
        self.id = ""
        self.name = name
        self.addCell = addCell
        self.isAdmin = false
        self.image = nil
        self.adminText = nil
    }

}

class ALKGroupMemberCell: UICollectionViewCell {

    struct Padding {
        struct Profile {
            static let left: CGFloat = 20
            static let width: CGFloat = 40
            static let height: CGFloat = 40
            static let top: CGFloat = 10
            static let bottom: CGFloat = 10
        }
        struct Name {
            static let left: CGFloat = 10
            static let right: CGFloat = 10
        }
        struct Admin {
            static let right: CGFloat = 20
        }
    }

    let profile: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "contactPlaceholder", in: Bundle.applozic, compatibleWith: nil)
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true
        return imageView
    }()

    let nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont(name: "HelveticaNeue", size: 15)
        label.textColor = UIColor(red: 89, green: 87, blue: 87)
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    let adminLabel: UILabel = {
        let label = UILabel()
        label.text = "Admin"
        label.font = UIFont(name: "HelveticaNeue", size: 13)
        label.textColor = UIColor(red: 131, green: 128, blue: 128)
        label.numberOfLines = 1
        label.isHidden = true
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateView(model: GroupMemberInfo) {
        nameLabel.text = model.name
        adminLabel.isHidden = !model.isAdmin

        if model.addCell {
            let image = UIImage(named: "icon_add_people-1", in: Bundle.applozic, compatibleWith: nil)
            profile.image = image
        }

        if let urlString = model.image, let url = URL(string: urlString) {
            let placeHolder = UIImage(named: "contactPlaceholder", in: Bundle.applozic, compatibleWith: nil)
            let resource = ImageResource(downloadURL: url, cacheKey:url.absoluteString)
            profile.kf.setImage(with: resource, placeholder: placeHolder, options: nil, progressBlock: nil, completionHandler: nil)
        }

        if let text = model.adminText {
            adminLabel.text = text
        }
    }

    func rowHeight() -> CGFloat {
        return Padding.Profile.top + Padding.Profile.bottom + Padding.Profile.height
    }

    private func setupConstraints() {
        self.contentView.addViewsForAutolayout(views: [profile, adminLabel, nameLabel])

        profile.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Padding.Profile.left).isActive = true
        profile.widthAnchor.constraint(equalToConstant: Padding.Profile.width).isActive = true
        profile.heightAnchor.constraint(equalToConstant: Padding.Profile.height).isActive = true
        profile.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Padding.Profile.top).isActive = true
        profile.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Padding.Profile.bottom).isActive = true

        adminLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Padding.Admin.right).isActive = true
        adminLabel.centerYAnchor.constraint(equalTo: profile.centerYAnchor).isActive = true

        nameLabel.leadingAnchor.constraint(equalTo: profile.trailingAnchor, constant: Padding.Name.left).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profile.centerYAnchor).isActive = true
        nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: adminLabel.leadingAnchor, constant: -Padding.Name.right).isActive = true

    }
}
