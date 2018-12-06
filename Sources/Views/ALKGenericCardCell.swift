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
            let cards = try JSONDecoder().decode([ALKGenericCard].self, from: payload.data)
            cardTemplate = ALKGenericCardTemplate(cards: cards)
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
            let cards = try JSONDecoder().decode([ALKGenericCard].self, from: payload.data)
            let cardTemplate = ALKGenericCardTemplate(cards: cards)
            return cardTemplate
        } catch(let error) {
            print("\(error)")
            return nil
        }
    }

}

open class ALKGenericCardCell: UICollectionViewCell {

    open var coverImageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect.zero)
        imageView.image = UIImage(named: "placeholder", in: Bundle.applozic, compatibleWith: nil)
        return imageView
    }()
    
    var overlayText: InsetLabel = {
        let label = InsetLabel(insets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
        label.backgroundColor = UIColor.white
        label.text = ""
        label.textColor = UIColor.black
        label.font = Font.bold(size: 17.0).font()
        label.layer.borderColor = UIColor.lightGray.cgColor
        label.layer.borderWidth = 1
        label.numberOfLines = 1
        return label
    }()
    
    var ratingLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = UIColor.black
        label.font = Font.normal(size: 15.0).font()
        label.numberOfLines = 1
        return label
    }()

    open var titleLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.numberOfLines = 1
        label.font = Font.bold(size: 17.0).font()
        label.textColor = UIColor.black
        return label
    }()

    open var subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.numberOfLines = 1
        label.font = Font.bold(size: 15.0).font()
        label.textColor = UIColor.gray
        return label
    }()

    open var descriptionLabel: VerticalAlignLabel = {
        let label = VerticalAlignLabel()
        label.text = "DescriptionLabel"
        label.numberOfLines = 3
        label.font = Font.normal(size: 16.0).font()
        label.textColor = UIColor.gray
        return label
    }()
    
    open var titleStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        return stackView
    }()

    open var mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 3.0
        return stackView
    }()

    open var buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    open var mainBackgroundView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 5
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.borderWidth = 1
        return view
    }()

    public enum Padding {
        enum CoverImageView {
            static var top: CGFloat = 10.0
            static var left: CGFloat = 0.0
            static var right: CGFloat = 0.0
            static var height: CGFloat = 80.0
        }
        enum mainStackView {
            static var bottom: CGFloat = -20.0
            static var left: CGFloat = 0
            static var right: CGFloat = 0
        }
    }

    open var descriptionLabelHeight: CGFloat = 80.0
    open var titleLabelStackViewHeight: CGFloat = 30.0
    open var subtitleLabelHeight: CGFloat = 20.0

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
        let buttonHeight = 35
        let baseHeight:CGFloat = 200
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
        setOverlayText(card)
        setCoverImage(card)
        setRatingLabel(card)
        guard let buttons = card.buttons, !buttons.isEmpty else {return}
        updateViewFor(buttons)
    }

    @objc func buttonSelected(_ action: UIButton) {
        self.buttonSelected?(action.tag, action.currentTitle ?? "")
    }
    
    private func setOverlayText(_ card: ALKGenericCard) {
        guard let overlay = card.overlayText else {
            self.overlayText.isHidden = true
            return
        }
        self.overlayText.text = overlay
    }
    
    private func setCoverImage(_ card: ALKGenericCard) {
        guard let url = card.imageUrl else {
            coverImageView.constraint(withIdentifier: "coverImage")?.constant = 0
            coverImageView.isHidden = true
            return
        }
        coverImageView.constraint(withIdentifier: "coverImage")?.constant = Padding.CoverImageView.height
        self.coverImageView.kf.setImage(with: url)
    }
    
    private func setRatingLabel(_ card: ALKGenericCard) {
        guard let rating = card.rating else {
            return
        }
        self.ratingLabel.text = String(rating)
    }

    private func setUpButtons() {
        actionButtons = (1...3).map {
            let button = UIButton()
            button.setTitleColor(UIColor(netHex: 0x5c5aa7), for: .normal)
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
        titleStackView.addArrangedSubview(ratingLabel)
        actionButtons.forEach {
            buttonStackView.addArrangedSubview($0)
            $0.heightAnchor.constraint(equalToConstant: 35).isActive = true
        }
        mainStackView.addArrangedSubview(titleStackView)
        mainStackView.addArrangedSubview(subtitleLabel)
        mainStackView.addArrangedSubview(subtitleLabel)
        mainStackView.addArrangedSubview(descriptionLabel)
        mainStackView.addArrangedSubview(buttonStackView)

        view.addViewsForAutolayout(views: [mainBackgroundView, coverImageView, mainStackView, overlayText])

        coverImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: Padding.CoverImageView.top).isActive = true
        coverImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Padding.CoverImageView.left).isActive = true
        coverImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: Padding.mainStackView.right).isActive = true
        coverImageView.heightAnchor.constraint(equalToConstant: Padding.CoverImageView.height).isActive = true
        coverImageView.heightAnchor.constraintEqualToAnchor(constant: 0, identifier: "coverImage")?.isActive = true

        overlayText.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        overlayText.centerYAnchor.constraint(equalTo: coverImageView.centerYAnchor, constant: 0).isActive = true
        overlayText.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor).isActive = true

        mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Padding.mainStackView.left).isActive = true
        mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: Padding.mainStackView.right).isActive = true
        mainStackView.topAnchor.constraint(equalTo: coverImageView.bottomAnchor).isActive = true
        mainStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: Padding.mainStackView.bottom).isActive = true

        titleStackView.heightAnchor.constraint(equalToConstant: titleLabelStackViewHeight).isActive = true
        titleStackView.leadingAnchor.constraint(equalTo: mainStackView.leadingAnchor, constant: 10).isActive = true
        titleStackView.trailingAnchor.constraint(equalTo: mainStackView.trailingAnchor, constant: -10).isActive = true

        ratingLabel.trailingAnchor.constraint(equalTo: titleStackView.trailingAnchor, constant: -10).isActive = true
        ratingLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 40).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: titleStackView.leadingAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: ratingLabel.leadingAnchor, constant: -10).isActive = true

        subtitleLabel.heightAnchor.constraint(equalToConstant: subtitleLabelHeight).isActive = true
        subtitleLabel.leadingAnchor.constraint(equalTo: mainStackView.leadingAnchor, constant: 10).isActive = true
        subtitleLabel.trailingAnchor.constraint(equalTo: mainStackView.trailingAnchor, constant: -10).isActive = true

        descriptionLabel.leadingAnchor.constraint(equalTo: mainStackView.leadingAnchor, constant: 10).isActive = true
        descriptionLabel.trailingAnchor.constraint(equalTo: mainStackView.trailingAnchor, constant: -10).isActive = true
        descriptionLabel.heightAnchor.constraint(equalToConstant: descriptionLabelHeight).isActive = true

        mainBackgroundView.leadingAnchor.constraint(equalTo: mainStackView.leadingAnchor).isActive = true
        mainBackgroundView.trailingAnchor.constraint(equalTo: mainStackView.trailingAnchor).isActive = true
        mainBackgroundView.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
        mainBackgroundView.bottomAnchor.constraint(equalTo: mainStackView.bottomAnchor).isActive = true

        buttonStackView.leadingAnchor.constraint(equalTo: mainStackView.leadingAnchor, constant: 0).isActive = true
        
    }

    private func updateViewFor(_ buttons: [ALKGenericCard.Button]) {
        // Hide extra buttons
        actionButtons.enumerated().forEach {
            if $0 >= buttons.count {$1.isHidden = true}
            else {$1.setTitle(buttons[$0].name, for: .normal)}
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

class InsetLabel: UILabel {
    
    var insets = UIEdgeInsets()
    
    convenience init(insets: UIEdgeInsets) {
        self.init(frame: CGRect.zero)
        self.insets = insets
    }
    
    convenience init(dx: CGFloat, dy: CGFloat) {
        let insets = UIEdgeInsets(top: dy, left: dx, bottom: dy, right: dx)
        self.init(insets: insets)
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }
    
    override var intrinsicContentSize: CGSize  {
        var size = super.intrinsicContentSize
        size.width += insets.left + insets.right
        size.height += insets.top + insets.bottom
        return size
    }
}
