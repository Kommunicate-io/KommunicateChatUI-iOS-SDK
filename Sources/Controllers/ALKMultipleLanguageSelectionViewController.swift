//
//  ALKMultipleLanguageSelectionViewController.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by sathyan elangovan on 13/03/23.
//

import Foundation
import KommunicateCore_iOS_SDK

class LanguageOptionsCell: UITableViewCell {}


class ALKMultipleLanguageSelectionViewController : UIViewController {
    
    var configuration: ALKConfiguration
    var selectedLanguage: String = ""
    var languages = ["one", "two", "three", "four"]
    
    
    public var submitButtonTapped: ((String) -> Void)?
    public var closeButtonTapped: (() -> Void)?

    var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue", size: 16) ?? UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor(red: 96, green: 94, blue: 94)
        label.text = "Select a Language"
        //label.backgroundColor = UIColor.gray
        return label
    }()

    let tableView: UITableView = {
        let table = UITableView(frame: .zero)
       table.translatesAutoresizingMaskIntoConstraints = false
       return table
    }()
    
    // language selection Button On left of the Chat Bar
    open var closeButton: UIButton = {
        let button = UIButton(type: .custom)
        var image = UIImage(named: "ic_close", in: Bundle.km, compatibleWith: nil)
        image = image?.imageFlippedForRightToLeftLayoutDirection()
        image = image?.withRenderingMode(.alwaysTemplate)
        button.imageView?.tintColor = UIColor.black
        button.setImage(image, for: .normal)
        return button
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
    
    private lazy var bottomConstraint: NSLayoutConstraint = {
        var bottomAnchor = view.bottomAnchor
        if #available(iOS 11, *) {
            bottomAnchor = view.safeAreaLayoutGuide.bottomAnchor
        }
        let constraint = tableView.bottomAnchor.constraint(
            lessThanOrEqualTo: bottomAnchor,
            constant: -100
        )
        return constraint
    }()
    
    
    public required init(config: ALKConfiguration) {
        self.configuration = config
        
        if let languageArray = Array(config.languagesForSpeechToText.values.sorted()) as? [String] {
            languages = languageArray
        }
        print("Pakka Lang dic \(config.languagesForSpeechToText) values \(languages)")
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    
    func setupViews() {
      
        view.addViewsForAutolayout(views: [titleLabel,closeButton,tableView])
        titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
       
        closeButton.imageView?.tintColor = UIColor.black
        closeButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor).isActive = true
        closeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 30.0).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 30.0).isActive = true

        tableView.topAnchor.constraint(equalTo: titleLabel.safeAreaLayoutGuide.bottomAnchor, constant: 16).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        bottomConstraint.isActive = true
        
//        transitioningDelegate = bottomSheetTransitionDelegate
//        modalPresentationStyle = .custom

       // modalPresentationStyle = .popover
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(LanguageOptionsCell.self, forCellReuseIdentifier: "languagecell")
    }

    
}
extension ALKMultipleLanguageSelectionViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("pakka101 cell")
        let cell = tableView.dequeueReusableCell(withIdentifier: "languagecell", for: indexPath)
        cell.textLabel?.text = languages[indexPath.row]
        if let savedLanguageCode = ALApplozicSettings.getSelectedLanguageForSpeechToText(), let savedLanguage = configuration.languagesForSpeechToText[savedLanguageCode], savedLanguage == languages[indexPath.row] {
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: . none)
        }
      
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Pakka table count")
        return languages.count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedLanguage = languages[indexPath.row]
        let selectedLanguageCode = configuration.languagesForSpeechToText.getKey(forValue: selectedLanguage)
        ALApplozicSettings.setSelectedLanguageForSpeechToText(selectedLanguageCode)
        submitButtonTapped?(selectedLanguageCode ?? "")
    }
    
    private func getLanguageCode(language: String) -> String? {
        return configuration.languagesForSpeechToText.getKey(forValue: language)
    }
   
}
extension Dictionary where Value: Equatable {
    func getKey(forValue val: Value) -> Key? {
        return first(where: { $1 == val })?.key
    }
}

