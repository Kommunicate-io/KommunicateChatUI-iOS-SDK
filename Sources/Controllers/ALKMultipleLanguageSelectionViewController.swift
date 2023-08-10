//
//  ALKMultipleLanguageSelectionViewController.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by sathyan elangovan on 13/03/23.
//

import Foundation
import KommunicateCore_iOS_SDK
import UIKit

class ALKMultipleLanguageSelectionViewController : UIViewController {
    
    private var configuration: ALKConfiguration
    private var languages : [String] = []
    public var languageSelected: ((KMLanguage) -> Void)?
    public var closeButtonTapped: (() -> Void)?

    var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 16) ?? UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor(red: 96, green: 94, blue: 94)
        label.text = "Select a language"
        return label
    }()

    open var closeButton: UIButton = {
        let button = UIButton(type: .custom)
        var image = UIImage(named: "icon_close_white", in: Bundle.km, compatibleWith: nil)
        button.contentMode = .scaleAspectFit
        image = image?.imageFlippedForRightToLeftLayoutDirection()
        image = image?.withRenderingMode(.alwaysTemplate)
        button.tintColor = UIColor.gray
        button.setImage(image, for: .normal)
        return button
    }()

    lazy var bottomSheetTransitionDelegate = KMBottomSheetTransitionDelegate()

    private lazy var bottomConstraint: NSLayoutConstraint = {
        var bottomAnchor = view.bottomAnchor
        if #available(iOS 11, *) {
            bottomAnchor = view.safeAreaLayoutGuide.bottomAnchor
        }
        let constraint = languageStackView.bottomAnchor.constraint(
            lessThanOrEqualTo: bottomAnchor,
            constant: -15
        )
        return constraint
    }()
    
    private let languageStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.distribution = .fill
        stackView.axis = .vertical
        stackView.spacing = 2
        return stackView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            // Always adopt a light interface style.
            overrideUserInterfaceStyle = .light
        }
        closeButton.addTarget(self, action: #selector(closeButtonAction(_:)), for: .touchUpInside)
        setupViews()
    }
    
    @objc func closeButtonAction(_: UIButton) {
        closeButtonTapped?()
    }
    
    public required init(config: ALKConfiguration) {
        self.configuration = config
        if let languageArray = Array(config.languagesForSpeechToText.map({$0.name}).sorted()) as? [String] {
            languages = languageArray
        }
        super.init(nibName: nil, bundle: nil)
        self.transitioningDelegate = self.bottomSheetTransitionDelegate
        self.modalPresentationStyle = .custom
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        languageStackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
        
        for item in self.languages {
            let view = KMLanguageView(title: item,languageList: configuration.languagesForSpeechToText)
            view.languageTapped = { [weak self] language in
                guard let weakSelf = self else {
                    return
                }
                weakSelf.languageSelected?(language)
            }
            languageStackView.addArrangedSubview(view)
        }
        
        view.addViewsForAutolayout(views: [titleLabel,closeButton,languageStackView])
        titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
       
        closeButton.imageView?.tintColor = UIColor.black
        closeButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor).isActive = true
        closeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 30.0).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 30.0).isActive = true

        languageStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16).isActive = true
        languageStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        languageStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        bottomConstraint.isActive = true

        view.backgroundColor = .white
        view.layer.cornerRadius = 8
    }
}
