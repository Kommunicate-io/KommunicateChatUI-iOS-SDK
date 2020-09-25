import Foundation
import Kingfisher

class ALKLinkView: UIView, Localizable {
    enum CommonPadding {
        enum View {
            static let height: CGFloat = 90
        }

        enum PreviewImageView {
            static let top: CGFloat = 5
            static let leading: CGFloat = 5
            static let bottom: CGFloat = 5
            static let width: CGFloat = 80
        }

        enum TitleLabel {
            static let top: CGFloat = 5
            static let leading: CGFloat = 5
            static let trailing: CGFloat = 5
        }

        enum DescriptionLabel {
            static let top: CGFloat = 2
            static let leading: CGFloat = 5
            static let trailing: CGFloat = 5
        }
    }

    var isViewCellVisible: ((_ identifier: String) -> Bool)?

    var localizedStringFileName: String!

    func setLocalizedStringFileName(_ localizedStringFileName: String) {
        self.localizedStringFileName = localizedStringFileName
    }

    let loadingIndicator = ALKLoadingIndicator(frame: .zero, color: UIColor.gray)

    var titleLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.textColor = UIColor(red: 20, green: 19, blue: 19)
        label.font = UIFont.font(.medium(size: 18))
        label.numberOfLines = 2
        return label
    }()

    var frontView: ALKTappableView = {
        let view = ALKTappableView()
        view.isUserInteractionEnabled = true
        view.backgroundColor = .clear
        return view
    }()

    var descriptionLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.numberOfLines = 3
        label.textColor = UIColor(red: 121, green: 116, blue: 116)
        label.font = UIFont.font(.light(size: 14))
        return label
    }()

    let previewImageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect.zero)
        imageView.image = UIImage(named: "default_image", in: Bundle.applozic, compatibleWith: nil)
        imageView.backgroundColor = .clear
        return imageView
    }()

    init() {
        super.init(frame: .zero)
        setupConstraintAndView()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupConstraintAndView() {
        addViewsForAutolayout(views: [titleLabel, descriptionLabel, previewImageView, loadingIndicator, frontView])
        isUserInteractionEnabled = true
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.lightGray.cgColor
        clipsToBounds = true
        bringSubviewToFront(frontView)

        frontView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        frontView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        frontView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        frontView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        previewImageView.topAnchor.constraint(equalTo: topAnchor, constant: CommonPadding.PreviewImageView.top).isActive = true
        previewImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: CommonPadding.PreviewImageView.leading).isActive = true
        previewImageView.widthAnchor.constraint(equalToConstant: CommonPadding.PreviewImageView.width).isActive = true
        previewImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -CommonPadding.PreviewImageView.bottom).isActive = true

        titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: CommonPadding.TitleLabel.top).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: previewImageView.trailingAnchor, constant: CommonPadding.TitleLabel.leading).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -CommonPadding.TitleLabel.trailing).isActive = true

        descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: CommonPadding.DescriptionLabel.top).isActive = true
        descriptionLabel.leadingAnchor.constraint(equalTo: previewImageView.trailingAnchor, constant: CommonPadding.DescriptionLabel.leading).isActive = true
        descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant:
            -CommonPadding.DescriptionLabel.trailing).isActive = true

        descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor).isActive = true

        loadingIndicator.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        loadingIndicator.topAnchor.constraint(equalTo: topAnchor).isActive = true
        loadingIndicator.leadingAnchor.constraint(equalTo: previewImageView.leadingAnchor).isActive = true
        loadingIndicator.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }

    func update(url: String?, identifier: String) {
        loadingIndicator.startLoading(localizationFileName: localizedStringFileName)
        hideViews(true)
        guard let linkUrl = url else {
            loadingIndicator.stopLoading()
            hideViews(false)
            return
        }
        guard let cachelinkPreviewMeta = LinkURLCache.getLink(for: linkUrl) else {
            let linkview = ALKLinkPreviewManager()
            linkview.makePreview(from: linkUrl, identifier: identifier) { [weak self] result in
                guard let weakSelf = self, let isViewCellVisible = weakSelf.isViewCellVisible, isViewCellVisible(identifier) else { return }
                switch result {
                case let .success(linkPreviewMeta):
                    weakSelf.updateView(linkPreviewMeta: linkPreviewMeta)
                case .failure:
                    weakSelf.updateFailedStatusInView()
                    weakSelf.loadingIndicator.stopLoading()
                }
            }
            return
        }
        updateView(linkPreviewMeta: cachelinkPreviewMeta)
    }

    func hideViews(_ isHide: Bool) {
        previewImageView.isHidden = isHide
        titleLabel.isHidden = isHide
        descriptionLabel.isHidden = isHide
    }

    class func height() -> CGFloat {
        return ALKLinkView.CommonPadding.View.height + ALKLinkView.CommonPadding.PreviewImageView.top
    }

    func updateView(linkPreviewMeta: LinkPreviewMeta) {
        let placeHolder = UIImage(named: "default_image", in: Bundle.applozic, compatibleWith: nil)

        if let stringURL = linkPreviewMeta.image ?? linkPreviewMeta.icon, let url = URL(string: stringURL) {
            let resource = ImageResource(downloadURL: url, cacheKey: url.absoluteString)
            previewImageView.kf.setImage(with: resource, placeholder: placeHolder)
        } else {
            previewImageView.image = placeHolder
        }

        titleLabel.text = linkPreviewMeta.title
        descriptionLabel.text = linkPreviewMeta.description ?? linkPreviewMeta.getBaseURl(url: linkPreviewMeta.url.absoluteString)
        hideViews(false)
        loadingIndicator.stopLoading()
    }

    func updateFailedStatusInView() {
        hideViews(false)
        titleLabel.text = localizedString(forKey: "FailedToLoadLink", withDefaultValue: SystemMessage.Information.FailedToLoadLink, fileName: localizedStringFileName)
    }
}
