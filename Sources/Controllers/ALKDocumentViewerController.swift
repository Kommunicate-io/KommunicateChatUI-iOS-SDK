//
//  ALKDocumentViewerController.swift
//  ApplozicSwift
//
//  Created by apple on 13/03/19.
//

import Foundation
import WebKit

class ALKDocumentViewerController : UIViewController,WKNavigationDelegate{
    
    var webView: WKWebView = WKWebView()
    var fileName: String = ""
    var filePath: String = ""
    var fileUrl : URL = URL(fileURLWithPath: "")

    let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)

    required init(){
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = self
        view = webView
        self.fileUrl = ALKFileUtils().getDocumentDirectory(fileName: filePath)
        activityIndicator.startAnimating()
        webView.loadFileURL(self.fileUrl, allowingReadAccessTo: self.fileUrl)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.rightBarButtonItem =  UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(self.showShare(_:)))

        self.title =  fileName
        activityIndicator.center = CGPoint(x: view.bounds.size.width/2, y: view.bounds.size.height/2)
        activityIndicator.color = UIColor.gray
        view.addSubview(activityIndicator)
        self.view.bringSubviewToFront(activityIndicator)
      }

    @objc func showShare(_ sender: Any?)  {
        let vc = UIActivityViewController(activityItems: [fileUrl], applicationActivities: [])
        self.present(vc, animated: true)
    }


    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator.stopAnimating()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
    }

}


