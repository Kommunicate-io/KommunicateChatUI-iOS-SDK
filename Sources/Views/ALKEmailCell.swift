//
//  ALKEmailCell.swift
//  ApplozicSwift
//
//  Created by apple on 24/12/18.
//

import Foundation
import UIKit
import Kingfisher
import WebKit

open class ALKFriendEmailCell: UITableViewCell {

    struct Padding {
        struct NameLabel{
            static let top: CGFloat =  6
            static let leading: CGFloat =  57
            static let trailing: CGFloat =  57
            static let height: CGFloat =  16
        }

        struct EmailLabel{
            static let top: CGFloat =  10
            static let leading: CGFloat =  3
            static let height: CGFloat =  16
        }

        struct RepliedImageView{
            static let top: CGFloat =  14
            static let leading: CGFloat =  57
            static let width: CGFloat = 20
            static let height: CGFloat =  11
        }

        struct AvatarImageView{
            static let top: CGFloat =  18
            static let leading: CGFloat =  9
            static let width: CGFloat =  37
            static let height: CGFloat =  37
        }

        struct WKWebView {
            static let top: CGFloat =  0
            static let trailing: CGFloat =  50
            static let leading: CGFloat =  10
            static let height: CGFloat =  60 // Default height..
        }

        struct EmailUIView{
            static let top: CGFloat =  5
            static let trailing: CGFloat =  50
            static let leading: CGFloat =  10
            static let height: CGFloat =  20
        }
        struct TimeLabel {
            static let top: CGFloat =  1
            static let trailing: CGFloat =  10
            static let width: CGFloat =  50
            static let height: CGFloat =  37
        }
    }

    struct ConstraintIdentifier {
        static  let wkWebViewHeight = "WkWebViewHeight"
    }

    // MARK: - Properties

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


    fileprivate var emailImage: UIImageView = {
        let sv = UIImageView()
        sv.image = UIImage(named: "alk_replied_icon", in: Bundle.applozic, compatibleWith: nil)
        sv.isUserInteractionEnabled = false
        sv.contentMode = .center
        return sv
    }()

    private var emailLabel: UILabel = {
        let label = UILabel()
        label.text = "via email"
        label.numberOfLines = 1
        label.font = UIFont(name: "Helvetica", size: 12)
        label.isOpaque = true
        return label
    }()

    fileprivate var repliedEmailUIView: UIView = {
        let view = UIView(frame: CGRect.zero)
        view.backgroundColor = UIColor.white
        view.isUserInteractionEnabled = true
        return view
    }()

    fileprivate var wkWebView: WKWebView!

    fileprivate var timeLabel: UILabel = {
        let timeLabel = UILabel()
        timeLabel.isOpaque = true
        return timeLabel
    }()

    fileprivate var activityIndicator = UIActivityIndicatorView(style: .gray)

    // MARK: - Initializer

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupWebView()
        setupConstraints()
        setupStyle()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Internal methods

    func setWebViewDelegate(delegate : WKNavigationDelegate, index: IndexPath) {
        wkWebView.navigationDelegate = delegate
        wkWebView.tag = index.row
    }

    func update(viewModel: ALKMessageViewModel) {
        activityIndicator.startAnimating()
        if(viewModel.message != nil){
            wkWebView.loadHTMLString(viewModel.message ?? "", baseURL:nil)
        }

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
        guard let height = height else {
            return
        }
        activityIndicator.stopAnimating()
        wkWebView.constraint(withIdentifier:ConstraintIdentifier.wkWebViewHeight)?.constant = height
    }

    class func rowHeight(viewModel: ALKMessageViewModel, contentHeights: Dictionary<String,CGFloat>) ->  CGFloat {
        var totalHeight: CGFloat = 0
        totalHeight += Padding.NameLabel.height + Padding.NameLabel.top  /// Name height
        totalHeight += Padding.EmailUIView.height + Padding.EmailUIView.top  /// Email heading height
        totalHeight += Padding.TimeLabel.height + Padding.TimeLabel.top  /// time height

        guard let height = contentHeights[viewModel.identifier] else {
            return Padding.WKWebView.height + totalHeight;
        }

        totalHeight += height + Padding.WKWebView.top
        return totalHeight
    }

    // MARK: - Private helper methods

    private func webViewConfiguration() -> WKWebViewConfiguration {
        let viewportSource = """
            var meta = document.createElement('meta');
            meta.setAttribute('name', 'viewport');
            meta.setAttribute('content', 'width=device-width');
            meta.setAttribute('initial-scale', '1.0');
            meta.setAttribute('shrink-to-fit', 'no');
            document.getElementsByTagName('head')[0].appendChild(meta);
        """
        let viewportScript = WKUserScript(source: viewportSource, injectionTime: .atDocumentEnd, forMainFrameOnly: true)

        let disableCalloutSource = "document.documentElement.style.webkitTouchCallout='none';"

        let disableCalloutScript = WKUserScript(source: disableCalloutSource, injectionTime: .atDocumentEnd, forMainFrameOnly: true)

        /// Add script
        let controller = WKUserContentController()
        controller.addUserScript(viewportScript)
        controller.addUserScript(disableCalloutScript)

        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.userContentController = controller
        return webConfiguration
    }

    private func setupWebView() {
        wkWebView = WKWebView(frame: .zero, configuration: webViewConfiguration())
        wkWebView.translatesAutoresizingMaskIntoConstraints = false
        wkWebView.backgroundColor = UIColor.white
        wkWebView.allowsBackForwardNavigationGestures = false
        wkWebView.contentMode = .scaleAspectFit
        wkWebView.scrollView.isScrollEnabled = true
        wkWebView.scrollView.showsVerticalScrollIndicator = true
        wkWebView.scrollView.showsHorizontalScrollIndicator = true
        wkWebView.scrollView.bounces = false
    }

    private func setupConstraints() {
        repliedEmailUIView.addViewsForAutolayout(views: [emailImage,emailLabel])
        contentView.addViewsForAutolayout(views: [avatarImageView,repliedEmailUIView,emailImage,emailLabel,nameLabel,wkWebView,timeLabel, activityIndicator])

        nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Padding.NameLabel.top).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Padding.NameLabel.leading).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Padding.NameLabel.trailing).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: Padding.NameLabel.height).isActive = true

        repliedEmailUIView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: Padding.EmailUIView.top).isActive = true
        repliedEmailUIView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Padding.EmailUIView.trailing).isActive = true
        repliedEmailUIView.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: Padding.EmailUIView.leading).isActive = true
        repliedEmailUIView.heightAnchor.constraint(equalToConstant: Padding.EmailUIView.height).isActive = true

        emailImage.topAnchor.constraint(equalTo: nameLabel.bottomAnchor,constant: Padding.RepliedImageView.top).isActive = true
        emailImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Padding.RepliedImageView.leading).isActive = true
        emailImage.heightAnchor.constraint(equalToConstant:  Padding.RepliedImageView.height).isActive = true
        emailImage.widthAnchor.constraint(equalToConstant:  Padding.RepliedImageView.width).isActive = true

        emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor,constant:  Padding.EmailLabel.top).isActive = true
        emailLabel.leadingAnchor.constraint(equalTo: emailImage.trailingAnchor, constant: Padding.EmailLabel.leading).isActive = true
        emailLabel.heightAnchor.constraint(equalToConstant: Padding.EmailLabel.height).isActive = true
        emailLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor).isActive = true

        avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Padding.AvatarImageView.top).isActive = true
        avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Padding.AvatarImageView.leading).isActive = true
        avatarImageView.heightAnchor.constraint(equalToConstant: Padding.AvatarImageView.height).isActive = true
        avatarImageView.widthAnchor.constraint(equalToConstant: Padding.AvatarImageView.width ).isActive = true

        wkWebView.topAnchor.constraint(equalTo: repliedEmailUIView.bottomAnchor, constant: Padding.WKWebView.top).isActive = true
        wkWebView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Padding.WKWebView.trailing).isActive = true
        wkWebView.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: Padding.WKWebView.leading).isActive = true
        wkWebView.heightAnchor.constraintEqualToAnchor(constant: Padding.WKWebView.height, identifier: ConstraintIdentifier.wkWebViewHeight).isActive = true

        activityIndicator.centerXAnchor.constraint(equalTo: wkWebView.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: wkWebView.centerYAnchor).isActive = true

        timeLabel.topAnchor.constraint(equalTo: wkWebView.bottomAnchor, constant: Padding.TimeLabel.top).isActive = true
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

