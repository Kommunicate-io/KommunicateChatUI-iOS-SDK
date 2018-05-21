//
//  ALKGenericCardCell.swift
//  ApplozicSwift
//
//  Created by Mukesh Thawani on 28/03/18.
//

import UIKit
import Kingfisher

open class ALKGenericCardCollectionView: ALKIndexedCollectionView {

    open var cardTemplate: ALKGenericCardTemplate?

    override open func setMessage(viewModel: ALKMessageViewModel) {
        super.setMessage(viewModel: viewModel)
        // set card template

        guard
            let metadata = viewModel.metadata,
            let payload = metadata["payload"] as? String
            else { return}
        do {
            cardTemplate = try JSONDecoder().decode(ALKGenericCardTemplate.self, from: payload.data)
        } catch(let error) {
            print("\(error)")
        }
    }

    override open class func rowHeightFor(message: ALKMessageViewModel) -> CGFloat {
        guard let template = getCardTemplate(message: message),
            !template.cards.isEmpty,
            let card = template.cards.first
            else {
                return 0
        }
        return ALKGenericCardCell.rowHeightFor(card: card)
    }

    private class func getCardTemplate(message: ALKMessageViewModel) -> ALKGenericCardTemplate? {
        guard
            let metadata = message.metadata,
            let payload = metadata["payload"] as? String
            else { return nil}
        do {
            let cardTemplate = try JSONDecoder().decode(ALKGenericCardTemplate.self, from: payload.data)
            return cardTemplate
        } catch(let error) {
            print("\(error)")
            return nil
        }
    }

}

open class ALKGenericCardCell: UICollectionViewCell {

    open let coverImageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect.zero)
        imageView.image = UIImage(named: "placeholder", in: Bundle.applozic, compatibleWith: nil)
        return imageView
    }()

    open let titleLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.numberOfLines = 1
        label.font = Font.bold(size: 17.0).font()
        label.textColor = UIColor.black
        return label
    }()

    open let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.numberOfLines = 1
        label.font = Font.bold(size: 15.0).font()
        label.textColor = UIColor.gray
        return label
    }()

    open let descriptionLabel: VerticalAlignLabel = {
        let label = VerticalAlignLabel()
        label.text = "DescriptionLabel"
        label.numberOfLines = 3
        label.font = Font.normal(size: 16.0).font()
        label.textColor = UIColor.gray
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
        stackView.spacing = 3.0
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
        view.layer.cornerRadius = 5
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.borderWidth = 1
        return view
    }()

    public enum Padding {
        enum CoverImageView {
            static var top: CGFloat = 5.0
            static var left: CGFloat = 5.0
            static var right: CGFloat = -5.0
            static var height: CGFloat = 80.0
        }
        enum mainStackView {
            static var bottom: CGFloat = -20.0
            static var left: CGFloat = 0
            static var right: CGFloat = 0
        }
    }

    open var descriptionLabelHeight: CGFloat = 80.0
    open var titleLabelStackViewHeight: CGFloat = 50.0

    open var actionButtons = [UIButton]()
    open var card: ALKGenericCard!
    open var buttonSelected: ((_ index: Int, _ name: String)->())?

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

    open class func rowHeightFor(card: ALKGenericCard) -> CGFloat {
        let buttonHeight = 30
        let baseHeight:CGFloat = 170
        let padding:CGFloat = 10
        let coverImageHeight = (card.imageUrl != nil) ? Padding.CoverImageView.height:0
        let totalButtonHeight:CGFloat = (card.buttons != nil) ? CGFloat(buttonHeight*(card.buttons?.count)!):0
        return baseHeight + coverImageHeight + totalButtonHeight + padding
    }

    open func update(card: ALKGenericCard) {
        self.card = card
        self.titleLabel.text = card.title
        self.subtitleLabel.text = card.subtitle
        self.descriptionLabel.text = card.description
        guard let buttons = card.buttons, !buttons.isEmpty else {return}
        updateViewFor(buttons)
        guard let url = card.imageUrl else {
            coverImageView.isHidden = true
            return
        }
        self.coverImageView.kf.setImage(with: url)

    }

    @objc func buttonSelected(_ action: UIButton) {
        self.buttonSelected?(action.tag, action.currentTitle ?? "")
    }

    private func setUpButtons() {
        actionButtons = (1...3).map {
            let button = UIButton()
            button.setTitleColor(.gray, for: .normal)
            button.setFont(font: UIFont.font(.bold(size: 16.0)))
            button.setTitle("Button", for: .normal)
            button.addTarget(self, action: #selector(buttonSelected(_:)), for: .touchUpInside)
            button.layer.borderWidth = 1.0
            button.tag = $0
            button.layer.borderColor = UIColor.gray.cgColor
            return button
        }
    }
    
    private func setUpViews() {
        setupConstraints()
        backgroundColor = .clear
    }

    private func setupConstraints() {
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
        coverImageView.heightAnchor.constraint(equalToConstant: Padding.CoverImageView.height).isActive = true

        titleStackView.heightAnchor.constraint(equalToConstant: titleLabelStackViewHeight).isActive = true
        titleStackView.leadingAnchor.constraint(equalTo: mainStackView.leadingAnchor, constant: 10).isActive = true
        titleStackView.trailingAnchor.constraint(equalTo: mainStackView.leadingAnchor, constant: -10).isActive = true
        descriptionLabel.leadingAnchor.constraint(equalTo: mainStackView.leadingAnchor, constant: 10).isActive = true
        descriptionLabel.trailingAnchor.constraint(equalTo: mainStackView.leadingAnchor, constant: -10).isActive = true

        descriptionLabel.heightAnchor.constraint(equalToConstant: descriptionLabelHeight).isActive = true
        mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Padding.mainStackView.left).isActive = true
        mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: Padding.mainStackView.right).isActive = true
        mainStackView.topAnchor.constraint(equalTo: coverImageView.bottomAnchor).isActive = true
        mainStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: Padding.mainStackView.bottom).isActive = true

        mainBackgroundView.leadingAnchor.constraint(equalTo: mainStackView.leadingAnchor).isActive = true
        mainBackgroundView.trailingAnchor.constraint(equalTo: mainStackView.trailingAnchor).isActive = true
        mainBackgroundView.topAnchor.constraint(equalTo: coverImageView.topAnchor).isActive = true
        mainBackgroundView.bottomAnchor.constraint(equalTo: mainStackView.bottomAnchor).isActive = true
        buttonStackView.leadingAnchor.constraint(equalTo: mainStackView.leadingAnchor, constant: 0).isActive = true
    }

    private func updateViewFor(_ buttons: [ALKGenericCard.Button]) {
        // Hide extra buttons
        actionButtons.enumerated().forEach {
            if $0 >= buttons.count {$1.isHidden = true}
            else {$1.setTitle(buttons[$0].title, for: .normal)}
        }
    }
}

public class VerticalAlignLabel: UILabel {
    enum VerticalAlignment {
        case top
        case middle
        case bottom
    }

    var verticalAlignment : VerticalAlignment = .top {
        didSet {
            setNeedsDisplay()
        }
    }

    override public func textRect(forBounds bounds: CGRect, limitedToNumberOfLines: Int) -> CGRect {
        let rect = super.textRect(forBounds: bounds, limitedToNumberOfLines: limitedToNumberOfLines)

        if UIView.userInterfaceLayoutDirection(for: .unspecified) == .rightToLeft {
            switch verticalAlignment {
            case .top:
                return CGRect(x: self.bounds.size.width - rect.size.width, y: bounds.origin.y, width: rect.size.width, height: rect.size.height)
            case .middle:
                return CGRect(x: self.bounds.size.width - rect.size.width, y: bounds.origin.y + (bounds.size.height - rect.size.height) / 2, width: rect.size.width, height: rect.size.height)
            case .bottom:
                return CGRect(x: self.bounds.size.width - rect.size.width, y: bounds.origin.y + (bounds.size.height - rect.size.height), width: rect.size.width, height: rect.size.height)
            }
        } else {
            switch verticalAlignment {
            case .top:
                return CGRect(x: bounds.origin.x, y: bounds.origin.y, width: rect.size.width, height: rect.size.height)
            case .middle:
                return CGRect(x: bounds.origin.x, y: bounds.origin.y + (bounds.size.height - rect.size.height) / 2, width: rect.size.width, height: rect.size.height)
            case .bottom:
                return CGRect(x: bounds.origin.x, y: bounds.origin.y + (bounds.size.height - rect.size.height), width: rect.size.width, height: rect.size.height)
            }
        }
    }

    override public func drawText(in rect: CGRect) {
        let r = self.textRect(forBounds: rect, limitedToNumberOfLines: self.numberOfLines)
        super.drawText(in: r)
    }
}
