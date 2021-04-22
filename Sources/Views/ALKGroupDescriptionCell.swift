//
//  ALKGroupDescriptionCell.swift
//  ApplozicSwift
//
//  Created by apple on 15/04/21.
//

import Foundation
import UIKit
#if canImport(RichMessageKit)
    import RichMessageKit
#endif

// MARK: Group description cell

class ALKGroupDescriptionCell: UICollectionViewCell, Localizable {
    // MARK: - Variables and Types

    enum Padding {
        enum DescriptionLabel {
            static let top: CGFloat = 5.0
            static let bottom: CGFloat = 5.0
            static let left: CGFloat = 17.0
            static let right: CGFloat = 17.0
            static let minHeight: CGFloat = 40.0
        }
    }

    var channelDetailConfig: ALKChannelDetailViewConfiguration?
    var localizedStringFileName: String?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = Font.normal(size: 14).font()
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    func updateView(localizedStringFileName: String,
                    descriptionText: String?,
                    channelDetailConfig: ALKChannelDetailViewConfiguration?)
    {
        self.localizedStringFileName = localizedStringFileName
        self.channelDetailConfig = channelDetailConfig
        guard let groupDescriptionText = descriptionText, !groupDescriptionText.trim().isEmpty else {
            descriptionLabel.text = localizedString(forKey: "AddGroupDescriptionPlaceHolder", withDefaultValue: SystemMessage.LabelName.AddGroupDescriptionPlaceHolder, fileName: localizedStringFileName)
            descriptionLabel.textColor = .lightGray
            return
        }
        descriptionLabel.text = descriptionText
        descriptionLabel.textColor = .black
    }

    class func rowHeight(descrption: String?, maxWidth: CGFloat) -> CGFloat {
        var height: CGFloat
        if let descrptionText = descrption {
            height = descrptionText.heightWithConstrainedWidth(maxWidth - Padding.DescriptionLabel.left + Padding.DescriptionLabel.right, font: Font.normal(size: 14).font())
        } else {
            height = Padding.DescriptionLabel.minHeight
        }
        return Padding.DescriptionLabel.top + Padding.DescriptionLabel.bottom + height
    }

    // MARK: Private methods

    private func setupConstraints() {
        contentView.addViewsForAutolayout(views: [descriptionLabel])
        descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Padding.DescriptionLabel.left).isActive = true
        descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Padding.DescriptionLabel.right).isActive = true
        descriptionLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Padding.DescriptionLabel.top).isActive = true
        descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Padding.DescriptionLabel.bottom).isActive = true
    }
}

// MARK: Group header cell

class ALKGroupHeaderTitleCell: UICollectionViewCell {
    // MARK: - Variables and Types

    enum Padding {
        enum HeaderTitleLabel {
            static let top: CGFloat = 5.0
            static let bottom: CGFloat = 5.0
            static let left: CGFloat = 17.0
            static let right: CGFloat = 17.0
            static let minHeight: CGFloat = 30.0
        }
    }

    static let cellID = "ALKGroupHeaderTitleCell"
    var channelDetailConfig = ALKChannelDetailViewConfiguration()
    var localizedStringFileName: String?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let headerTitleLabel: UILabel = {
        let label = UILabel()
        return label
    }()

    func updateView(titleText: String,
                    localizedStringFileName: String,
                    channelDetailConfig: ALKChannelDetailViewConfiguration)
    {
        self.localizedStringFileName = localizedStringFileName
        headerTitleLabel.text = titleText
        headerTitleLabel.font = channelDetailConfig.participantHeaderTitle.font
        headerTitleLabel.textColor = channelDetailConfig.participantHeaderTitle.text
    }

    class func rowHeight(descrption: String?, maxWidth: CGFloat, font: UIFont) -> CGFloat {
        var height: CGFloat
        if let descrptionText = descrption {
            height = descrptionText.heightWithConstrainedWidth(maxWidth - Padding.HeaderTitleLabel.left + Padding.HeaderTitleLabel.right, font: font)
        } else {
            height = Padding.HeaderTitleLabel.minHeight
        }
        return Padding.HeaderTitleLabel.top + Padding.HeaderTitleLabel.bottom + height
    }

    // MARK: Private methods

    private func setupConstraints() {
        contentView.addViewsForAutolayout(views: [headerTitleLabel])
        headerTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Padding.HeaderTitleLabel.left).isActive = true
        headerTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Padding.HeaderTitleLabel.right).isActive = true
        headerTitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Padding.HeaderTitleLabel.top).isActive = true
        headerTitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Padding.HeaderTitleLabel.bottom).isActive = true
    }
}
