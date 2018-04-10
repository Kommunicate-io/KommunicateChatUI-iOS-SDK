//
//  ALKGenericCardCell.swift
//  ApplozicSwift
//
//  Created by Mukesh Thawani on 28/03/18.
//

import UIKit


open class ALKGenericCardCell: UICollectionViewCell {

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

    open let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    open let mainBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gray
        return view
    }()

    public enum Padding {
        enum CoverImageView {
            static var top: CGFloat = 5.0
            static var left: CGFloat = 5.0
            static var right: CGFloat = -5.0
        }
        enum mainStackView {
            static var bottom: CGFloat = -10.0
            static var left: CGFloat = 5.0
            static var right: CGFloat = -5.0
        }
    }

    open var descriptionLabelHeight: CGFloat = 80.0
    open var titleLabelStackViewHeight: CGFloat = 50.0
    open var coverImageViewHeight: CGFloat = 80.0

    open var actionButtons = [UIButton]()

    override open func awakeFromNib() {
        super.awakeFromNib()
    }


    public override init(frame: CGRect) {
        super.init(frame: frame)
        setUpButtons()
        setUpViews()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    static public func rowHeight() -> CGFloat {

        // Update height based on number of buttons
        // present and if image is set.
        return 350
    }

    private func setUpButtons() {
        actionButtons = (1...3).map {
            _ in
            let button = UIButton()
            button.setTitle("title", for: .normal)
            return button
        }
    }
    
    private func setUpViews() {

        let view = contentView

        titleStackView.addArrangedSubview(titleLabel)
        titleStackView.addArrangedSubview(subtitleLabel)
        actionButtons.forEach {
            buttonStackView.addArrangedSubview($0)
            $0.heightAnchor.constraint(equalToConstant: 30).isActive = true
        }
        mainStackView.addArrangedSubview(titleStackView)
        mainStackView.addArrangedSubview(descriptionLabel)
        mainStackView.addArrangedSubview(buttonStackView)

        view.addViewsForAutolayout(views: [mainBackgroundView, coverImageView, mainStackView])

        coverImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: Padding.CoverImageView.top).isActive = true
        coverImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Padding.CoverImageView.left).isActive = true
        coverImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: Padding.mainStackView.right).isActive = true
        coverImageView.heightAnchor.constraint(equalToConstant: coverImageViewHeight).isActive = true

        titleStackView.heightAnchor.constraint(equalToConstant: titleLabelStackViewHeight).isActive = true
        descriptionLabel.heightAnchor.constraint(equalToConstant: descriptionLabelHeight).isActive = true
        mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Padding.mainStackView.left).isActive = true
        mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: Padding.mainStackView.right).isActive = true
        mainStackView.topAnchor.constraint(equalTo: coverImageView.bottomAnchor).isActive = true
        mainStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: Padding.mainStackView.bottom).isActive = true

        mainBackgroundView.leadingAnchor.constraint(equalTo: mainStackView.leadingAnchor).isActive = true
        mainBackgroundView.trailingAnchor.constraint(equalTo: mainStackView.trailingAnchor).isActive = true
        mainBackgroundView.topAnchor.constraint(equalTo: coverImageView.topAnchor).isActive = true
        mainBackgroundView.bottomAnchor.constraint(equalTo: mainStackView.bottomAnchor).isActive = true


    }
}
