//
//  WebViewController.swift
//  ApplozicSwift
//
//  Created by Shivam Pokhriyal on 15/01/19.
//

import Foundation
import WebKit

class WebViewController: UIViewController {

    var webView: WKWebView = WKWebView()
    var htmlString: String
    var url: URL

    init(htmlString: String, url: URL) {
        self.htmlString = htmlString
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        webView.loadHTMLString(htmlString, baseURL: url)
    }
}
