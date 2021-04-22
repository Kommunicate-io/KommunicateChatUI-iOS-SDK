//
//  ALKGroupDescriptionController.swift
//  ApplozicSwift
//
//  Created by Sunil on 14/04/21.
//

import Foundation
import UIKit

protocol ALKGroupDescriptionDelegate: AnyObject {
    func onGroupDescriptionSave(description: String)
}

// MARK: Group description ViewController

class ALKGroupDescriptionController: ALKBaseViewController, Localizable {
    // MARK: - Variables and Types

    enum ConstraintIdentifier {
        static let descriptionTextViewHeight = "descriptionTextViewHeight"
    }

    enum CharacterLimit {
        static let hard = 700
        static let soft = 650
    }

    enum Padding {
        enum DescriptionTextView {
            static let top: CGFloat = 30.0
            static let left: CGFloat = 0.0
            static let right: CGFloat = 0.0
            static let minHeight: CGFloat = 60.0
            static let maxHeight: CGFloat = 350.0
        }

        enum RemainingStackView {
            static let top: CGFloat = 0.0
            static let left: CGFloat = 0.0
            static let right: CGFloat = 0.0
            static let height: CGFloat = 30.0
        }
    }

    let channelKey: NSNumber
    let isFromGroupCreate: Bool
    var groupDescriptionViewModel: ALKGroupDescriptionViewModel?
    weak var delegate: ALKGroupDescriptionDelegate?
    var groupDescriptionHeaderTitle: String?
    var groupDescriptionPlaceHolder: String?
    var remaingCharactersLabelText: String?

    fileprivate let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)

    private let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.textColor = UIColor.black
        textView.isScrollEnabled = true
        textView.setFont(Font.normal(size: 14).font())
        textView.delaysContentTouches = false
        textView.backgroundColor = .white
        return textView
    }()

    private let remainingLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.black
        label.numberOfLines = 1
        label.textAlignment = .center
        label.setFont(Font.normal(size: 14).font())
        label.backgroundColor = .clear
        return label
    }()

    private lazy var stackViewForLabel: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [self.remainingLabel])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        return stackView
    }()

    init(channelKey: NSNumber,
         configuration: ALKConfiguration,
         isFromGroupCreate: Bool)
    {
        self.channelKey = channelKey
        self.isFromGroupCreate = isFromGroupCreate
        super.init(configuration: configuration)
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public required init(configuration _: ALKConfiguration) {
        fatalError("init(configuration:) has not been implemented")
    }

    override func viewDidLoad() {
        setupNaaviagtion()
        setupView()

        groupDescriptionHeaderTitle = localizedString(forKey: "GroupDescriptionHeaderTitle", withDefaultValue: SystemMessage.LabelName.GroupDescription, fileName: configuration.localizedStringFileName)

        groupDescriptionPlaceHolder = localizedString(forKey: "AddGroupDescriptionPlaceHolder", withDefaultValue: SystemMessage.LabelName.AddGroupDescriptionPlaceHolder, fileName: configuration.localizedStringFileName)

        remaingCharactersLabelText = localizedString(forKey: "RemainingCharactersInfo", withDefaultValue: SystemMessage.LabelName.RemainingCharactersInfo, fileName: configuration.localizedStringFileName)

        groupDescriptionViewModel = ALKGroupDescriptionViewModel(channelKey: channelKey)
        update(groupDescriptionViewModel: groupDescriptionViewModel)
    }

    @objc func saveButtonAction() {
        let existingGroupDescriptionText = groupDescriptionViewModel?.groupDescription()

        let trimmedDescriptionText = descriptionTextView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

        guard existingGroupDescriptionText != trimmedDescriptionText,
              descriptionTextView.textColor != UIColor.lightGray
        else {
            // If the text is same will pop the view controller
            popViewController()
            return
        }

        // Send the call back to group create screen for adding description while creating a group
        if delegate != nil, isFromGroupCreate {
            delegate?.onGroupDescriptionSave(description: trimmedDescriptionText)
            popViewController()
            return
        }

        startLoadingIndicator()
        groupDescriptionViewModel?.updateGroupDescription(description: trimmedDescriptionText, completion: { resultType in
            self.stopLoadingIndicator()
            self.view.endEditing(true)
            switch resultType {
            case let .success(status):
                print("Updated the group description: ", status)
                self.popViewController()
            case let .failure(error):
                print("Failed to update the group description : %@", error.localizedDescription)
                self.popViewController()
            }
        })
    }

    func popViewController() {
        navigationController?.popViewController(animated: true)
    }

    func update(groupDescriptionViewModel: ALKGroupDescriptionViewModel?) {
        guard let viewModel = groupDescriptionViewModel,
              let descriptionText = viewModel.groupDescription(),
              !descriptionText.trim().isEmpty
        else {
            descriptionTextView.text = groupDescriptionPlaceHolder
            descriptionTextView.textColor = UIColor.lightGray
            descriptionTextView.constraint(withIdentifier: ConstraintIdentifier.descriptionTextViewHeight)?.constant = Padding.DescriptionTextView.minHeight
            return
        }
        descriptionTextView.text = descriptionText
        textViewDidChange(descriptionTextView)
    }

    // MARK: Private methods

    private func setupNaaviagtion() {
        let groupDescriptionTitle = localizedString(forKey: "GroupDescriptionVCTitle", withDefaultValue: SystemMessage.NavbarTitle.groupDescriptionVCTitle, fileName: configuration.localizedStringFileName)

        title = groupDescriptionTitle
        let saveButtonTitleText = localizedString(forKey: "SaveButtonTitle", withDefaultValue: SystemMessage.ButtonName.Save, fileName: configuration.localizedStringFileName)
        let saveButonItem = UIBarButtonItem(title: saveButtonTitleText, style: .plain, target: self, action: #selector(saveButtonAction))
        navigationItem.rightBarButtonItem = saveButonItem
    }

    private func setupView() {
        view.addViewsForAutolayout(views: [descriptionTextView, stackViewForLabel])
        view.backgroundColor = UIColor(red: 245 / 255.0, green: 245 / 255.0, blue: 245 / 255.0, alpha: 1.0)

        activityIndicator.center = CGPoint(x: view.bounds.size.width / 2,
                                           y: view.bounds.size.height / 2)
        activityIndicator.color = UIColor.gray
        view.addSubview(activityIndicator)
        view.bringSubviewToFront(activityIndicator)

        descriptionTextView.layer.borderColor = UIColor.gray.cgColor
        descriptionTextView.layer.borderWidth = 0.2

        descriptionTextView.delegate = self

        descriptionTextView.topAnchor.constraint(equalTo: view.topAnchor, constant: Padding.DescriptionTextView.top).isActive = true
        descriptionTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                     constant: Padding.DescriptionTextView.left).isActive = true
        descriptionTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Padding.DescriptionTextView.right).isActive = true
        descriptionTextView.heightAnchor.constraintEqualToAnchor(
            constant: 0, identifier: ConstraintIdentifier.descriptionTextViewHeight
        ).isActive = true

        stackViewForLabel.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: Padding.RemainingStackView.top).isActive = true
        stackViewForLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Padding.RemainingStackView.right).isActive = true
        stackViewForLabel.heightAnchor.constraint(equalToConstant: Padding.RemainingStackView.height).isActive = true
        stackViewForLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Padding.RemainingStackView.left).isActive = true
    }

    private func startLoadingIndicator() {
        activityIndicator.startAnimating()
        view.isUserInteractionEnabled = false
    }

    private func stopLoadingIndicator() {
        activityIndicator.stopAnimating()
        view.isUserInteractionEnabled = true
    }
}

// MARK: UITextViewDelegate

extension ALKGroupDescriptionController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == nil || textView.text.isEmpty {
            textView.text = groupDescriptionPlaceHolder
            textView.textColor = UIColor.lightGray
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText newText: String) -> Bool {
        return textView.text.count + (newText.count - range.length) <= CharacterLimit.hard
    }

    func textViewDidChange(_ textView: UITextView) {
        guard let remaingCharactersText = remaingCharactersLabelText else {
            return
        }
        if textView.text.count >= CharacterLimit.soft {
            remainingLabel.isHidden = false
            let formatedRemainingText = String(format: remaingCharactersText, String(CharacterLimit.hard - textView.text.count))
            remainingLabel.text = formatedRemainingText
        } else {
            remainingLabel.isHidden = true
        }

        let size = CGSize(width: view.frame.width, height: .greatestFiniteMagnitude)
        let estimatedSize = textView.sizeThatFits(size)
        var height: CGFloat = 0
        if estimatedSize.height <= Padding.DescriptionTextView.minHeight {
            height = Padding.DescriptionTextView.minHeight
        } else if estimatedSize.height >= Padding.DescriptionTextView.maxHeight {
            height = Padding.DescriptionTextView.maxHeight
        } else {
            height = estimatedSize.height
        }

        DispatchQueue.main.async { [weak self] in
            guard let weakSelf = self else { return }
            weakSelf.descriptionTextView.constraint(withIdentifier: ConstraintIdentifier.descriptionTextViewHeight)?.constant = height
            UIView.animate(withDuration: 0.5) {
                weakSelf.descriptionTextView.layoutIfNeeded()
            }
        }
    }
}
