//
//  KMCustomCaptionViewController.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by Abhijeet Ranjan on 28/12/23.
//

import UIKit
import Photos
import MobileCoreServices

protocol KMCustomUploadCaptionDelegate: AnyObject {
    func filesSelectedWithCaption(images: [UIImage], gifs: [String], videos: [String], caption: String)
}

class KMCustomCaptionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITextFieldDelegate, Localizable {

    // MARK: - Properties

    var bottomConstraint: NSLayoutConstraint!
    var collectionView: UICollectionView!
    var captionBar: UITextField!
    var stackView: UIStackView!
    var cancelButton: UIButton!
    var doneButton: UIButton!
    var dividerView: UIView!
    var selectedImages = [UIImage]()
    var selectedGifs = [String]()
    var selectedVideos = [String]()
    var selectedFiles = [IndexPath]()
    var configuration: ALKConfiguration
    private lazy var localizedStringFileName: String = configuration.localizedStringFileName
    fileprivate let indicatorSize = ALKActivityIndicator.Size(width: 50, height: 50)
    fileprivate lazy var activityIndicator = ALKActivityIndicator(frame: .zero, backgroundColor: .lightGray, indicatorColor: .white, size: indicatorSize)
    weak var delegate: KMCustomUploadCaptionDelegate?

    // MARK: - Initialization

    init(images: [UIImage], gifs: [String], videos: [String], configuration: ALKConfiguration) {
        self.selectedImages = images
        self.selectedGifs = gifs
        self.selectedVideos = videos
        self.configuration = configuration
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        registerForKeyboardNotifications()
        setupTapGestureRecognizer()
        captionBar.delegate = self
        
        view.addViewsForAutolayout(views: [activityIndicator])
        view.bringSubviewToFront(activityIndicator)
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        activityIndicator.widthAnchor.constraint(equalToConstant: indicatorSize.width).isActive = true
        activityIndicator.heightAnchor.constraint(equalToConstant: indicatorSize.height).isActive = true
    }

    // MARK: - UI Setup

    private func setupUI() {
        view.backgroundColor = .white
        setupCollectionView()
        setupCaptionBar()
        setupBottomButtons()
        setTitle()
    }

    private func setTitle() {
        guard !configuration.hideNavigationBarOnChat else {
            navigationController?.setNavigationBarHidden(true, animated: true)
            return
        }

        if navigationController?.viewControllers.first != self || navigationController?.viewControllers.first?.isKind(of: ALKConversationViewController.self) == true {
            navigationItem.leftBarButtonItem = backBarButtonItem()
        }

        if configuration.hideNavigationBarBottomLine {
            navigationController?.navigationBar.hideBottomHairline()
        }

        title = localizedString(forKey: "PhotosTitle", withDefaultValue: SystemMessage.LabelName.Photos, fileName: localizedStringFileName)
    }

    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = -10
        layout.minimumLineSpacing = 20
        let itemWidth = (view.bounds.width - 4 * layout.minimumInteritemSpacing) / 2.5
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            collectionView.heightAnchor.constraint(lessThanOrEqualToConstant: 500),
        ])
    }

    private func setupCaptionBar() {
        captionBar = UITextField()
        captionBar.placeholder = "Add caption.."
        captionBar.borderStyle = .roundedRect
        captionBar.layer.cornerRadius = 5
        captionBar.layer.masksToBounds = true
        captionBar.layer.shadowColor = UIColor.black.cgColor
        captionBar.layer.shadowOffset = CGSize(width: 0, height: 2)
        captionBar.layer.shadowOpacity = 0.2
        captionBar.layer.shadowRadius = 2
        captionBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(captionBar)

        NSLayoutConstraint.activate([
            captionBar.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 20),
            captionBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            captionBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            captionBar.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    private func setupTapGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        view.addGestureRecognizer(tapGesture)
    }

    private func setupBottomButtons() {
        stackView = UIStackView()
        stackView.backgroundColor = .gray
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)

        cancelButton = createButton(title: "CANCEL", action: #selector(cancelAction))
        doneButton = createButton(title: " SEND ", action: #selector(doneAction))

        dividerView = UIView()
        dividerView.backgroundColor = .white
        dividerView.translatesAutoresizingMaskIntoConstraints = false

        stackView.addArrangedSubview(cancelButton)
        stackView.addArrangedSubview(dividerView)
        stackView.addArrangedSubview(doneButton)

        bottomConstraint = stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            bottomConstraint,
            stackView.heightAnchor.constraint(equalToConstant: 50),
            captionBar.bottomAnchor.constraint(equalTo: stackView.topAnchor, constant: -50),

            dividerView.widthAnchor.constraint(equalToConstant: 1),
            dividerView.topAnchor.constraint(equalTo: stackView.topAnchor, constant: 5),
            dividerView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: -5),
            dividerView.centerYAnchor.constraint(equalTo: stackView.centerYAnchor),
            dividerView.centerXAnchor.constraint(equalTo: stackView.centerXAnchor),
        ])
    }

    // MARK: - Button Actions

    @objc private func cancelAction() {
        navigationController?.dismiss(animated: true, completion: nil)
    }

    @objc private func doneAction() {
        self.activityIndicator.startAnimating()
        let caption = captionBar.text ?? ""
        delegate?.filesSelectedWithCaption(images: selectedImages, gifs: selectedGifs, videos: selectedVideos, caption: caption)
        navigationController?.dismiss(animated: true, completion: nil)
        self.activityIndicator.stopAnimating()

    }

    // MARK: - Helper Methods

    private func createButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    // MARK: - Gesture Recognizer

    @objc private func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }

    // MARK: - Keyboard Handling

    private func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            UIView.animate(withDuration: 0.3) {
                self.bottomConstraint.constant = -keyboardSize.height - 20
                self.view.layoutIfNeeded()
            }
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.bottomConstraint.constant = -20
            self.view.layoutIfNeeded()
        }
    }

    // MARK: - UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedImages.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        let imageView = UIImageView(image: selectedImages[indexPath.item])
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor)
        ])

        return cell
    }

    // MARK: - UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Handle selection if needed
    }

    // MARK: - Navigation

    private func backBarButtonItem() -> UIBarButtonItem {
        var backImage = UIImage(named: "icon_back", in: Bundle.km, compatibleWith: nil)
        backImage = backImage?.imageFlippedForRightToLeftLayoutDirection()
        let backButton = UIBarButtonItem(
            image: backImage,
            style: .plain,
            target: self,
            action: #selector(backTapped)
        )
        backButton.accessibilityIdentifier = "conversationBackButton"
        return backButton
    }

    @objc private func backTapped() {
        _ = navigationController?.popViewController(animated: true)
    }
}
