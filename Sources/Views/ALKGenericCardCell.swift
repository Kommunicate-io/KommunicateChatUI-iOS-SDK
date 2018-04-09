//
//  ALKGenericCardCell.swift
//  ApplozicSwift
//
//  Created by Mukesh Thawani on 28/03/18.
//

import UIKit


open class ALKGenericCardCell: UITableViewCell {

    open let coverImageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect.zero)
        imageView.image = UIImage(named: "icon_mic", in: Bundle.applozic, compatibleWith: nil)
        return imageView
    }()

    open let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "First label"
        label.numberOfLines = 1
        return label
    }()

    open let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Subtitle"
        label.numberOfLines = 1
        return label
    }()

    open let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "DescriptionLabel"
        label.numberOfLines = 3
        return label
    }()
    
    open let titleStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        return stackView
    }()

    open let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        return stackView
    }()
    
    open let mainBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gray
        return view
    }()

    public enum Padding {
        enum CoverImageView {
            static var top = 20.0
        }
    }

    private let descriptionLabelHeight: CGFloat = 80.0
    private let titleLabelStackViewHeight: CGFloat = 50.0
    private let coverImageViewHeight: CGFloat = 80.0

    override open func awakeFromNib() {
        super.awakeFromNib()
    }

    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpViews()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    static public func rowHeight() -> CGFloat {
        return 250
    }
    
    private func setUpViews() {

        let view = self

        titleStackView.addArrangedSubview(titleLabel)
        titleStackView.addArrangedSubview(subtitleLabel)
        mainStackView.addArrangedSubview(titleStackView)
        mainStackView.addArrangedSubview(descriptionLabel)

        view.addViewsForAutolayout(views: [mainBackgroundView, coverImageView, mainStackView])

        coverImageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        coverImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        coverImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        coverImageView.heightAnchor.constraint(equalToConstant: coverImageViewHeight).isActive = true

        titleStackView.heightAnchor.constraint(equalToConstant: titleLabelStackViewHeight).isActive = true
        descriptionLabel.heightAnchor.constraint(equalToConstant: descriptionLabelHeight).isActive = true
        mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        mainStackView.topAnchor.constraint(equalTo: coverImageView.bottomAnchor, constant: 5.0).isActive = true
        mainStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10.0).isActive = true

        mainBackgroundView.leadingAnchor.constraint(equalTo: mainStackView.leadingAnchor).isActive = true
        mainBackgroundView.trailingAnchor.constraint(equalTo: mainStackView.trailingAnchor).isActive = true
        mainBackgroundView.topAnchor.constraint(equalTo: coverImageView.topAnchor).isActive = true
        mainBackgroundView.bottomAnchor.constraint(equalTo: mainStackView.bottomAnchor).isActive = true
    }
}
