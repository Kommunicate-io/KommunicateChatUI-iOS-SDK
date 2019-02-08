//
//  ALKEmailCell.swift
//  ApplozicSwift
//
//  Created by apple on 24/12/18.
//

import Foundation
import UIKit
import Kingfisher
import Applozic
import WebKit


open class ALKFriendEmailCell: UITableViewCell{

    struct Padding {
        struct NameLabel{
            static let top: CGFloat =  6
            static let leading: CGFloat =  57
            static let trailing: CGFloat =  57
            static let height: CGFloat =  16
        }

        struct EmailLabel{
            static let top: CGFloat =  3
            static let leading: CGFloat =  3
            static let height: CGFloat =  13
        }

        struct RepliedImageView{
            static let top: CGFloat =  4
            static let leading: CGFloat =  2
            static let width: CGFloat = 20
            static let height: CGFloat =  13
        }

        struct AvatarImageView{
            static let top: CGFloat =  18
            static let leading: CGFloat =  9
            static let width: CGFloat =  37
            static let height: CGFloat =  37
        }

        struct WKWebView {
            static let top: CGFloat =  5
            static let trailing: CGFloat =  10
            static let leading: CGFloat =  10
            static let height: CGFloat =  0
        }

        struct TimeLabel {
            static let top: CGFloat =  2
            static let trailing: CGFloat =  10
            static let width: CGFloat =  50
            static let height: CGFloat =  37
        }
    }

    struct ConstraintIdentifier {
        static  let wkWebViewHeight = "WkWebViewHeight"
    }

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

    public var wkWebView: WKWebView = {

        let viewportScriptString = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); meta.setAttribute('initial-scale', '1.0'); meta.setAttribute('maximum-scale', '1.0'); meta.setAttribute('minimum-scale', '1.0'); meta.setAttribute('user-scalable', 'yes'); document.getElementsByTagName('head')[0].appendChild(meta); var body = document.getElementsByTagName('body')[0]; body.style.wordBreak = 'break-word';"
        let disableCalloutScriptString = "document.documentElement.style.webkitTouchCallout='none';"

        let viewportScript = WKUserScript(source: viewportScriptString, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        let disableCalloutScript = WKUserScript(source: disableCalloutScriptString, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        //  Initialize a user content controller
        let controller = WKUserContentController()
        // Add scripts
        controller.addUserScript(viewportScript)
        controller.addUserScript(disableCalloutScript)
        // Initialize a configuration and set controller
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.userContentController = controller

        let  wkWebView = WKWebView(frame: .zero, configuration: webConfiguration)
        wkWebView.translatesAutoresizingMaskIntoConstraints = false
        wkWebView.backgroundColor = UIColor.clear
        wkWebView.allowsBackForwardNavigationGestures = false
        wkWebView.contentMode = .scaleAspectFit
        wkWebView.scrollView.isScrollEnabled = true

        wkWebView.scrollView.showsVerticalScrollIndicator = true
        wkWebView.scrollView.showsHorizontalScrollIndicator = true
        wkWebView.scrollView.bounces = false
        return wkWebView
    }()


    fileprivate var timeLabel: UILabel = {
        let timeLabel = UILabel()
        timeLabel.isOpaque = true
        return timeLabel
    }()

    open func setWebViewDelegate(delegate : WKNavigationDelegate, index: IndexPath) {
        wkWebView.navigationDelegate = delegate
        wkWebView.tag = index.row
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupStyle()
    }

    func setupStyle() {
        timeLabel.setStyle(ALKMessageStyle.time)
        nameLabel.setStyle(ALKMessageStyle.displayName)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupViews() {

        contentView.backgroundColor = UIColor.clear
        contentView.addViewsForAutolayout(views: [avatarImageView,emailImage,emailLabel,nameLabel,wkWebView,timeLabel])

        emailImage.topAnchor.constraint(equalTo: contentView.topAnchor,constant: Padding.RepliedImageView.top).isActive = true
        emailImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Padding.RepliedImageView.leading).isActive = true
        emailImage.heightAnchor.constraint(equalToConstant:  Padding.RepliedImageView.height).isActive = true
        emailImage.widthAnchor.constraint(equalToConstant:  Padding.RepliedImageView.width).isActive = true

        emailLabel.topAnchor.constraint(equalTo: contentView.topAnchor,constant:  Padding.RepliedImageView.top).isActive = true
        emailLabel.leadingAnchor.constraint(equalTo: emailImage.trailingAnchor, constant: Padding.RepliedImageView.leading).isActive = true
        emailLabel.heightAnchor.constraint(equalToConstant: Padding.RepliedImageView.height).isActive = true
        emailLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor).isActive = true

        nameLabel.topAnchor.constraint(equalTo: emailImage.bottomAnchor, constant: Padding.NameLabel.top).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Padding.NameLabel.leading).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Padding.NameLabel.trailing).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: Padding.NameLabel.height).isActive = true

        avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Padding.AvatarImageView.top).isActive = true

        avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Padding.AvatarImageView.leading).isActive = true
        avatarImageView.heightAnchor.constraint(equalToConstant: Padding.AvatarImageView.height).isActive = true
        avatarImageView.widthAnchor.constraint(equalToConstant: Padding.AvatarImageView.width ).isActive = true

        wkWebView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: Padding.WKWebView.top).isActive = true

        wkWebView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Padding.WKWebView.trailing).isActive = true

        wkWebView.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: Padding.WKWebView.leading).isActive = true
        wkWebView.heightAnchor.constraintEqualToAnchor(constant: Padding.WKWebView.height, identifier: ConstraintIdentifier.wkWebViewHeight).isActive = true

        timeLabel.topAnchor.constraint(equalTo: wkWebView.bottomAnchor, constant: Padding.TimeLabel.top).isActive = true
        timeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Padding.TimeLabel.trailing).isActive = true
        timeLabel.heightAnchor.constraint(equalToConstant: Padding.TimeLabel.height).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: Padding.TimeLabel.width).isActive = true

    }


    func update(viewModel: ALKMessageViewModel) {


        if(viewModel.message != nil){
            wkWebView.loadHTMLString(viewModel.message ?? "", baseURL:nil)
        }

        let placeHolder = UIImage(named: "placeholder", in: Bundle.applozic, compatibleWith: nil)

        if let url = viewModel.avatarURL {
            let resource = ImageResource(downloadURL: url, cacheKey: url.absoluteString)
            self.avatarImageView.kf.setImage(with: resource, placeholder: placeHolder, options: nil, progressBlock: nil, completionHandler: nil)
        } else {
            self.avatarImageView.image = placeHolder
        }

        nameLabel.text = viewModel.displayName
        timeLabel.text = viewModel.time

    }

    func updateHeightConstraints( height : CGFloat) {
        wkWebView.constraint(withIdentifier:ConstraintIdentifier.wkWebViewHeight)?.constant = height
    }

    class func rowHeight(viewModel: ALKMessageViewModel, contentHeights: Dictionary<String,CGFloat> ) ->  CGFloat {
        guard let height = contentHeights[viewModel.identifier] else {
            return 0;
        }
        return height + 13+16+37+10; //Name,time label
    }

}

