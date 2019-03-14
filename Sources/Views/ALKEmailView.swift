//
//  ALKEmailCell.swift
//  ApplozicSwift
//
//  Created by Shivam Pokhriyal on 13/03/19.
//

import Foundation
import WebKit

class ALKEmailView: UIView {

    struct Height {
        static let emailView: CGFloat = 20
        static let webView: CGFloat = 60
    }

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

    fileprivate var wkWebView: WKWebView!

    fileprivate var activityIndicator = UIActivityIndicatorView(style: .gray)

    fileprivate lazy var webViewHeight = wkWebView.heightAnchor.constraint(equalToConstant: Height.webView)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupWebView()
        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setWebViewDelegate(delegate : WKNavigationDelegate, tag: Int) {
        wkWebView.navigationDelegate = delegate
        wkWebView.tag = tag
    }

    func loadWebView(with message: String) {
        activityIndicator.startAnimating()
        wkWebView.loadHTMLString(message, baseURL:nil)
    }

    func updateHeight(_ height: CGFloat?) {
        guard let height = height else {
            return
        }
        activityIndicator.stopAnimating()
        webViewHeight.constant = height
    }

    class func rowHeight(_ webViewHeight: CGFloat?) -> CGFloat {
        guard let webViewHeight = webViewHeight else {
            return Height.emailView + Height.webView
        }
        return Height.emailView + webViewHeight
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
        self.backgroundColor = .white
        self.addViewsForAutolayout(views: [emailImage, emailLabel ,wkWebView, activityIndicator])

        emailImage.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        emailImage.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        emailImage.heightAnchor.constraint(equalToConstant: Height.emailView).isActive = true
        emailImage.widthAnchor.constraint(equalToConstant: Height.emailView).isActive = true

        emailLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        emailLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        emailLabel.leadingAnchor.constraint(equalTo: emailImage.trailingAnchor).isActive = true
        emailLabel.heightAnchor.constraint(equalToConstant: Height.emailView).isActive = true

        wkWebView.topAnchor.constraint(equalTo: emailImage.bottomAnchor).isActive = true
        wkWebView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        wkWebView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        webViewHeight.isActive = true

        activityIndicator.centerXAnchor.constraint(equalTo: wkWebView.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: wkWebView.centerYAnchor).isActive = true
    }

}
