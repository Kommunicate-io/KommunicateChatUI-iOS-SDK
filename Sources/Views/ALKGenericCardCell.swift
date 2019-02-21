//
//  ALKGenericCardCell.swift
//  ApplozicSwift
//
//  Created by Mukesh Thawani on 28/03/18.
//

import UIKit
import Kingfisher

open class ALKGenericCardCollectionView: ALKIndexedCollectionView {

    open var cardTemplate: [CardTemplateModel]?

    override open func setMessage(viewModel: ALKMessageViewModel) {
        super.setMessage(viewModel: viewModel)
        // set card template
        guard let template = ALKGenericCardCollectionView.getCardTemplate(message: viewModel) else { return}
        cardTemplate = template
    }

    override open class func rowHeightFor(message: ALKMessageViewModel, width: CGFloat) -> CGFloat {
        guard let template = getCardTemplate(message: message),
            let card = template.first
            else {
                return 0
        }
        return ALKGenericCardCell.rowHeight(card: card, maxWidth: width)
    }

    class func getCardTemplate(message: ALKMessageViewModel) -> [CardTemplateModel]? {
        guard
            let metadata = message.metadata,
            let payload = metadata["payload"] as? String,
            let templateId = metadata["templateId"] as? String
            else { return nil}
        if templateId == "10" {
            do {
                let templates = try JSONDecoder().decode([CardTemplateModel].self, from: payload.data)
                return templates
            } catch(let error) {
                print("\(error)")
                return nil
            }
        } else if templateId == "2" {
            do {
                let cards = try JSONDecoder().decode([ALKGenericCard].self, from: payload.data)
                var templates = [CardTemplateModel]()
                for card in cards {
                    templates.append(Util().cardTemplate(from: card))
                }
                return templates
            } catch(let error) {
                print("\(error)")
                return nil
            }
        }
        return nil
    }

}

open class ALKGenericCardCell: UICollectionViewCell {

    public struct Font {

        public static var overlayText = UIFont(name: "HelveticaNeue-Medium", size: 16) ??
            UIFont.systemFont(ofSize: 16)

        public static var rating = UIFont(name: "HelveticaNeue", size: 12) ??
            UIFont.systemFont(ofSize: 12)

        public static var title = UIFont(name: "HelveticaNeue-Medium", size: 18) ??
            UIFont.boldSystemFont(ofSize: 18)

        public static var subtitle = UIFont(name: "HelveticaNeue", size: 14) ??
            UIFont.systemFont(ofSize: 14)

        public static var description = UIFont(name: "HelveticaNeue-Light", size: 14) ??
            UIFont.systemFont(ofSize: 14)

    }

    public struct Config {

        public static let buttonHeight: CGFloat = 40

        public static let imageHeight: CGFloat = 100

        public static let padding: CGFloat = 3

        public struct OverlayText {
            public static let width: CGFloat = 80
            public static let height: CGFloat = 35
        }

    }

    enum ConstraintIdentifier: String {
        case titleView = "titleView"
        case subtitleView = "subtitleView"
        case descriptionView = "descriptionView"
        case buttonsView = "buttonsView"
    }

    lazy var coverImageHeight = self.coverImageView.heightAnchor.constraint(equalToConstant: Config.imageHeight)

    open var coverImageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect.zero)
        imageView.layer.cornerRadius = 0
        return imageView
    }()
    
    open var overlayText: UILabel = {
        let label = UILabel(frame: .zero)
        label.backgroundColor = UIColor.white
        label.textColor = UIColor(red: 13, green: 13, blue: 14)
        label.font = Font.overlayText
        label.numberOfLines = 1
        label.textAlignment = .center
        label.layer.cornerRadius = 5
        label.clipsToBounds = true
        label.layer.masksToBounds = false
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOpacity = 0.5
        label.layer.shadowOffset = .zero
        return label
    }()
    
    open var ratingLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = UIColor(red: 0, green: 0, blue: 0)
        label.font = Font.rating
        label.numberOfLines = 1
        return label
    }()

    open var titleLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.numberOfLines = 1
        label.font = Font.title
        label.textColor = UIColor(red: 20, green: 19, blue: 19)
        return label
    }()

    open var subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.numberOfLines = 1
        label.font = Font.subtitle
        label.textColor = UIColor(red: 86, green: 84, blue: 84)
        return label
    }()

    open var descriptionLabel: VerticalAlignLabel = {
        let label = VerticalAlignLabel()
        label.text = ""
        label.numberOfLines = 3
        label.font = Font.description
        label.textColor = UIColor(red: 121, green: 116, blue: 116)
        return label
    }()
    
    open var titleStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        return stackView
    }()

    open var buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 1
        return stackView
    }()

    open var buttonsBackground: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .lightGray
        return view
    }()

    open var actionButtons = [UIButton]()
    open var card: CardTemplateModel!
    open var buttonSelected: ((_ index: Int, _ name: String, _ card: CardTemplateModel)->())?

    override open func awakeFromNib() {
        super.awakeFromNib()
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setUpButtons()
        setupConstraints()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open class func rowHeight(card: CardTemplateModel, maxWidth: CGFloat) -> CGFloat {
        var headerHeight: CGFloat = 0
        if let header = card.header {
            let textHeight = header.overlayText != nil ? Config.OverlayText.height : CGFloat(0)
            headerHeight = (header.imgSrc != nil && URL(string: header.imgSrc!) != nil) ? Config.imageHeight : textHeight
        }
        let titleConstraint = CGSize(width: maxWidth, height: Font.title.lineHeight)
        let titleHeight = card.title.rectWithConstrainedSize(titleConstraint, font: Font.title).height.rounded(.up)

        let subtitleConstraint = CGSize(width: maxWidth, height: Font.subtitle.lineHeight)
        let subtitleHeight = card.subtitle.rectWithConstrainedSize(subtitleConstraint, font: Font.subtitle).height.rounded(.up)

        let descriptionConstraint = CGSize(width: maxWidth, height: Font.description.lineHeight)
        let descriptionHeight = (card.description?.rectWithConstrainedSize(descriptionConstraint, font: Font.description).height.rounded(.up) ?? CGFloat(0)) * CGFloat(3)

        let totalButtonHeight = Config.buttonHeight * CGFloat(card.buttons?.count ?? 0)

        var stackViewSpacing = 6
        stackViewSpacing += (card.buttons != nil) ? 3 : 0
        stackViewSpacing += (card.description != nil) ? 3 : 0
        stackViewSpacing += (card.buttons?.count ?? 1) - 1 // 1 space between 2 buttons.

        return headerHeight + titleHeight + subtitleHeight + descriptionHeight + totalButtonHeight + CGFloat(stackViewSpacing)
    }

    @objc func buttonSelected(_ action: UIButton) {
        self.buttonSelected?(action.tag, action.currentTitle ?? "", card)
    }

    open func update(card: CardTemplateModel) {
        self.card = card
        setTitle(card.title)
        setSubtitle(card.subtitle)
        setDescription(card)
        setRatingLabel(card)
        setOverlayText(card.header)
        setCoverImage(card.header)
        self.contentView.layoutIfNeeded()
        guard let buttons = card.buttons, !buttons.isEmpty else {return}
        updateViewFor(buttons)
        self.contentView.layoutIfNeeded()
    }

    private func setTitle(_ text: String) {
        titleLabel.text = text
        let titleConstraint = CGSize(width: 200, height: Font.title.lineHeight)
        let height = text.rectWithConstrainedSize(titleConstraint, font: Font.title).height.rounded(.up)
        titleStackView.constraint(withIdentifier: ConstraintIdentifier.titleView.rawValue)?.constant = height
    }

    private func setSubtitle(_ text: String) {
        subtitleLabel.text = card.subtitle
        let subtitleConstraint = CGSize(width: 200, height: Font.subtitle.lineHeight)
        let height = text.rectWithConstrainedSize(subtitleConstraint, font: Font.subtitle).height.rounded(.up)
        subtitleLabel.constraint(withIdentifier: ConstraintIdentifier.subtitleView.rawValue)?.constant = height
    }

    private func setOverlayText(_ header: CardTemplateModel.Header?) {
        guard let text = header?.overlayText else {
            self.overlayText.isHidden = true
            return
        }
        self.overlayText.isHidden = false
        self.overlayText.text = text
    }

    private func setCoverImage(_ header: CardTemplateModel.Header?) {
        guard let urlString = header?.imgSrc, let url = URL(string: urlString) else {
            coverImageHeight.constant = header?.overlayText != nil ? Config.OverlayText.height : CGFloat(0)
            coverImageView.isHidden = true
            overlayText.backgroundColor = UIColor(red: 230, green: 229, blue: 236)
            overlayText.layer.masksToBounds = true
            return
        }
        coverImageView.isHidden = false
        coverImageHeight.constant = Config.imageHeight
        self.coverImageView.kf.setImage(with: url)
    }

    private func setRatingLabel(_ card: CardTemplateModel) {
        guard let rating = card.titleExt else {
            self.ratingLabel.isHidden = true
            return
        }
        ratingLabel.isHidden = false
        ratingLabel.text = String(rating)
    }

    private func setDescription(_ card: CardTemplateModel) {
        guard let description = card.description else {
            descriptionLabel.constraint(withIdentifier: ConstraintIdentifier.descriptionView.rawValue)?.constant = 0
            descriptionLabel.isHidden = true
            return
        }
        descriptionLabel.isHidden = false
        descriptionLabel.text = description
        let descriptionConstraint = CGSize(width: 200, height: Font.description.lineHeight * 1)
        let height = description.rectWithConstrainedSize(descriptionConstraint, font: Font.description).height.rounded(.up) * CGFloat(3)
        descriptionLabel.constraint(withIdentifier: ConstraintIdentifier.descriptionView.rawValue)?.constant = height
    }

    private func updateViewFor(_ buttons: [CardTemplateModel.Button]?) {
        guard let buttons = buttons else { return }
        // Hide extra buttons
        actionButtons.enumerated().forEach {
            if $0 >= buttons.count {$1.isHidden = true}
            else {$1.isHidden = false; $1.setTitle(buttons[$0].name, for: .normal)}
        }
        let count = CGFloat(min(buttons.count, actionButtons.count))
        buttonStackView.constraint(withIdentifier: ConstraintIdentifier.buttonsView.rawValue)?.constant = count * Config.buttonHeight
    }

    private func setUpButtons() {
        actionButtons = (0...7).map {
            let button = UIButton()
            button.setTitleColor(UIColor(netHex: 0x5c5aa7), for: .normal)
            button.setFont(font: UIFont.systemFont(ofSize: 15, weight: .medium))
            button.setTitle("Button", for: .normal)
            button.addTarget(self, action: #selector(buttonSelected(_:)), for: .touchUpInside)
            button.tag = $0
            button.backgroundColor = .white
            return button
        }
    }

    private func setupConstraints() {
        let view = contentView
        view.backgroundColor = UIColor.white
        titleStackView.addArrangedSubview(titleLabel)
        titleStackView.addArrangedSubview(ratingLabel)
        actionButtons.forEach {
            buttonStackView.addArrangedSubview($0)
            $0.heightAnchor.constraint(equalToConstant: Config.buttonHeight).isActive = true
        }
        view.addViewsForAutolayout(views: [coverImageView, overlayText, titleStackView, subtitleLabel, descriptionLabel, buttonsBackground, buttonStackView])
        view.bringSubviewToFront(overlayText)
        view.bringSubviewToFront(buttonStackView)

        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.borderWidth = 1

        coverImageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        coverImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        coverImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        coverImageHeight.isActive = true

        overlayText.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        overlayText.centerYAnchor.constraint(equalTo: coverImageView.centerYAnchor, constant: 0).isActive = true
        overlayText.widthAnchor.constraint(equalToConstant: Config.OverlayText.width).isActive = true
        overlayText.heightAnchor.constraint(equalToConstant: Config.OverlayText.height).isActive = true

        titleStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        titleStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        titleStackView.topAnchor.constraint(equalTo: coverImageView.bottomAnchor, constant: Config.padding).isActive = true
        titleStackView.heightAnchor.constraintEqualToAnchor(constant: 0, identifier: ConstraintIdentifier.titleView.rawValue)?.isActive = true

        ratingLabel.trailingAnchor.constraint(equalTo: titleStackView.trailingAnchor, constant: -10).isActive = true
        ratingLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 40).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: titleStackView.leadingAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: ratingLabel.leadingAnchor, constant: -10).isActive = true

        subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        subtitleLabel.topAnchor.constraint(equalTo: titleStackView.bottomAnchor, constant: Config.padding).isActive = true
        subtitleLabel.heightAnchor.constraintEqualToAnchor(constant: 0, identifier: ConstraintIdentifier.subtitleView.rawValue)?.isActive = true

        descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        descriptionLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: Config.padding).isActive = true
        descriptionLabel.heightAnchor.constraintEqualToAnchor(constant: 0, identifier: ConstraintIdentifier.descriptionView.rawValue)?.isActive = true

        buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        buttonStackView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: Config.padding).isActive = true
        buttonStackView.heightAnchor.constraintEqualToAnchor(constant: 0, identifier: ConstraintIdentifier.buttonsView.rawValue)?.isActive = true

        buttonsBackground.leadingAnchor.constraint(equalTo: buttonStackView.leadingAnchor).isActive = true
        buttonsBackground.trailingAnchor.constraint(equalTo: buttonStackView.trailingAnchor).isActive = true
        buttonsBackground.topAnchor.constraint(equalTo: buttonStackView.topAnchor, constant: -1).isActive = true
        buttonsBackground.bottomAnchor.constraint(equalTo: buttonStackView.bottomAnchor).isActive = true
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

public class InsetLabel: UILabel {

    var insets = UIEdgeInsets()

    convenience init(insets: UIEdgeInsets) {
        self.init(frame: CGRect.zero)
        self.insets = insets
    }

    convenience init(dx: CGFloat, dy: CGFloat) {
        let insets = UIEdgeInsets(top: dy, left: dx, bottom: dy, right: dx)
        self.init(insets: insets)
    }

    override public func drawText(in rect: CGRect) {
        super.drawText(in: self.frame.inset(by: insets))
    }

    override public var intrinsicContentSize: CGSize  {
        var size = super.intrinsicContentSize
        size.width += insets.left + insets.right
        size.height += insets.top + insets.bottom
        return size
    }
}
