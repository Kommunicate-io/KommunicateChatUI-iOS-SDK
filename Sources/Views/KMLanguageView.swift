//
//  KMLanguageView.swift
//  KommunicateChatUI-iOS-SDKa
//
//  Created by sathyan elangovan on 10/08/23.
//

import Foundation
import UIKit
import KommunicateCore_iOS_SDK
#if canImport(RichMessageKit)
    import RichMessageKit
#endif

public class KMLanguageView: UIView {

    public enum Style {
        public static var dividerColor = UIColor.lightGray
        public static var minHeight: CGFloat = 35
        public static var padding = Padding(left: 14, right: 14, top: 4, bottom: 8)
        public static var selectedBackgroundColor = UIColor(hexString: "686464", alpha: 1)
        public static var selectedNameTextColor = UIColor(hexString: "ffffff", alpha: 1)
        public static var languageNameTextColor = UIColor(hexString: "29292a", alpha: 1)
        public static var languageNameFont = UIFont.systemFont(ofSize: 15)
        
        public enum LineStyle {
            public static var height = 1.0
            public static var top = 4.0
            public static var bottom = 2.0
        }
    }

    
    let title: String
    let maxWidth: CGFloat
    var languageObjectList : [KMLanguage]
    var languageTapped: ((KMLanguage) -> Void)?
    
    private let label = UILabel()
    
    private let lineView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor.lightGray
        return view
    }()
    

    public init(title: String, languageList: [KMLanguage], maxWidth: CGFloat = UIScreen.main.bounds.width) {
        self.title = title
        self.maxWidth = maxWidth
        self.languageObjectList = languageList
        super.init(frame: .zero)
        setupView()
        setupConstraint()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        label.text = title
        label.textColor = Style.languageNameTextColor
        label.font = Style.languageNameFont
        if let savedLanguageCode = ALApplozicSettings.getSelectedLanguageForSpeechToText(),
           let savedLanguage = languageObjectList.first(where: {$0.code == savedLanguageCode}), savedLanguage.name == title {
            label.setBackgroundColor(Style.selectedBackgroundColor)
            label.setTextColor(Style.selectedNameTextColor)
        }
    }

    private func setupConstraint() {
        addViewsForAutolayout(views: [label, lineView])

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Style.padding.left),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Style.padding.right),
            label.topAnchor.constraint(equalTo: topAnchor, constant: Style.padding.top),
            label.heightAnchor.constraint(equalToConstant: Style.minHeight),
            lineView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: Style.LineStyle.top),
            lineView.leadingAnchor.constraint(equalTo: label.leadingAnchor),
            lineView.trailingAnchor.constraint(equalTo: label.trailingAnchor),
            lineView.heightAnchor.constraint(equalToConstant: Style.LineStyle.height),
            lineView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Style.LineStyle.bottom)
            
        ])
        // Tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(languageTap))
        self.addGestureRecognizer(tapGesture)
    }
    
    
    @objc func languageTap() {
        if let selectedLanguage = languageObjectList.first(where: {$0.name == title}) {
            ALApplozicSettings.setSelectedLanguageForSpeechToText(selectedLanguage.code)
            languageTapped?(selectedLanguage)
        }
    }

}
