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
    func unselectedFiles(index: Int)
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
    var selectedFiles = [IndexPath]()
    let option = PHImageRequestOptions()
    var configuration: KMChatConfiguration
    var allPhotos: PHFetchResult<PHAsset>!
    var savedPhotos = [PHAsset]()
        
    private lazy var localizedStringFileName: String = configuration.localizedStringFileName
    fileprivate let indicatorSize = KMChatActivityIndicator.Size(width: 50, height: 50)
    fileprivate lazy var activityIndicator = KMChatActivityIndicator(frame: .zero, backgroundColor: .lightGray, indicatorColor: .white, size: indicatorSize)
    weak var delegate: KMCustomUploadCaptionDelegate?

    // MARK: - Initialization

    init(configuration: KMChatConfiguration, selectedFiles: [IndexPath], allPhotos: PHFetchResult<PHAsset>) {
        self.configuration = configuration
        self.selectedFiles = selectedFiles
        self.allPhotos = allPhotos
        for index in selectedFiles {
            savedPhotos.append(allPhotos.object(at: index.item))
        }
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
        view.backgroundColor = UIColor.kmDynamicColor(light: UIColor.white, dark: UIColor.appBarDarkColor())
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

        if navigationController?.viewControllers.first != self || navigationController?.viewControllers.first?.isKind(of: KMChatConversationViewController.self) == true {
            navigationItem.leftBarButtonItem = backBarButtonItem()
        }

        if configuration.hideNavigationBarBottomLine {
            navigationController?.navigationBar.hideBottomHairline()
        }
        
        if #available(iOS 26.0, *) {
            navigationItem.rightBarButtonItems?.forEach {
                $0.hidesSharedBackground = true
            }
            navigationItem.leftBarButtonItems?.forEach {
                $0.hidesSharedBackground = true
            }
        }

        title = localizedString(forKey: "CaptionScreenTitle", withDefaultValue: SystemMessage.LabelName.CaptionScreen, fileName: localizedStringFileName)
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
        collectionView.register(KMImageCell.self, forCellWithReuseIdentifier: "ImageCell")
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            collectionView.heightAnchor.constraint(lessThanOrEqualToConstant: 500)
        ])
    }

    private func setupCaptionBar() {
        captionBar = UITextField()
        captionBar.placeholder = localizedString(forKey: "AttachmentCaptionHere", withDefaultValue: SystemMessage.Information.AttachmentCaptionHere, fileName: localizedStringFileName)
        captionBar.placeholderColor = UIColor.text(.gray9B)
        captionBar.borderStyle = .roundedRect
        captionBar.layer.masksToBounds = true
        captionBar.clipsToBounds = false
        captionBar.layer.shadowOpacity = 0.2
        captionBar.layer.shadowOffset = CGSize(width: 0, height: 1)
        captionBar.translatesAutoresizingMaskIntoConstraints = false
        if !UIColor.isKMDarkModeEnabled {
            captionBar.overrideUserInterfaceStyle = .light
        }
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
        stackView.backgroundColor = .lightGray
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)

        cancelButton = createButton(title: "CANCEL", action: #selector(cancelAction))
        doneButton = createButton(title: " SEND ", action: #selector(doneAction))
        
        cancelButton.tintColor = UIColor.kmDynamicColor(light: UIColor.white, dark: UIColor.appBarDarkColor())
        doneButton.tintColor = UIColor.kmDynamicColor(light: UIColor.white, dark: UIColor.appBarDarkColor())

        dividerView = UIView()
        dividerView.backgroundColor = UIColor.kmDynamicColor(light: UIColor.white, dark: UIColor.appBarDarkColor())
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
            captionBar.bottomAnchor.constraint(equalTo: stackView.topAnchor, constant: -20),

            dividerView.widthAnchor.constraint(equalToConstant: 1),
            dividerView.topAnchor.constraint(equalTo: stackView.topAnchor, constant: 5),
            dividerView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: -5),
            dividerView.centerYAnchor.constraint(equalTo: stackView.centerYAnchor),
            dividerView.centerXAnchor.constraint(equalTo: stackView.centerXAnchor)
        ])
    }

    // MARK: - Export Functions
    
    func export(_ completion: @escaping ((_ images: [UIImage], _ gifs: [String], _ videos: [String], _ error: Bool) -> Void)) {
        var selectedImages = [UIImage]()
        var selectedGifs = [String]()
        var selectedVideos = [String]()
        var error = false
        let group = DispatchGroup()

        DispatchQueue.global(qos: .background).async {
            for indexPath in self.selectedFiles {
                group.wait()
                group.enter()
                let asset = self.allPhotos.object(at: indexPath.item)
                if asset.mediaType == .video {
                    self.exportVideoAsset(asset) { video in
                        guard let video = video else {
                            error = true
                            group.leave()
                            return
                        }
                        selectedVideos.append(video)
                        group.leave()
                    }
                } else if asset.mediaType == .image {
                    if asset.isAnimatedGif {
                        self.exportGifAsset(asset) { gifPath in
                            if let gifPath = gifPath {
                                selectedGifs.append(gifPath)
                                print("GIF exported: \(gifPath)")
                            } else {
                                print("Failed to export GIF")
                            }
                            group.leave()
                        }
                    } else {
                        self.exportImageAsset(asset) { (image, success) in
                            if success {
                                if let image = image {
                                    selectedImages.append(image)
                                    print("Image exported: \(image.description)")
                                }
                            } else {
                                print("Failed to export image")
                            }
                            group.leave()
                        }
                    }
                }
            }
            group.wait()
            DispatchQueue.main.async {
                completion(selectedImages, selectedGifs, selectedVideos, error)
            }
        }
    }
        
    func exportImageAsset(_ asset: PHAsset, completion: @escaping ((_ image: UIImage?, _ isGif: Bool) -> Void)) {
        let options = PHImageRequestOptions()
        options.isSynchronous = false

        PHImageManager.default().requestImageDataAndOrientation(for: asset, options: options) { (data, _, _, _) in
            guard let imageData = data else {
                completion(nil, false)
                return
            }

        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, "gif" as CFString, nil)?.takeRetainedValue(),
                   UTTypeConformsTo(uti, kUTTypeGIF) {
                if let image = UIImage(data: imageData) {
                    completion(image, true)
                } else {
                    completion(nil, false)
                }
            } else {
                if let image = UIImage(data: imageData) {
                    completion(image, false)
                } else {
                    completion(nil, false)
                }
            }
        }
    }
        
    func exportVideoAsset(_ asset: PHAsset, _ completion: @escaping ((_ video: String?) -> Void)) {
        let filename = String(format: "VID-%f.mp4", Date().timeIntervalSince1970 * 1000)
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        var fileurl = URL(fileURLWithPath: documentsUrl.absoluteString).appendingPathComponent(filename)
        print("exporting video to ", fileurl)
        fileurl = fileurl.standardizedFileURL

        let options = PHVideoRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true

        // remove any existing file at that location
        do {
            try FileManager.default.removeItem(at: fileurl)
        } catch {
            // most likely, the file didn't exist.  Don't sweat it
        }

        PHImageManager.default().requestExportSession(forVideo: asset, options: options, exportPreset: AVAssetExportPresetHighestQuality) {
            (exportSession: AVAssetExportSession?, _) in
                if exportSession == nil {
                    print("COULD NOT CREATE EXPORT SESSION")
                    completion(nil)
                    return
                }

            exportSession!.outputURL = fileurl
            exportSession!.outputFileType = AVFileType.mp4 // file type encode goes here, you can change it for other types

            exportSession!.exportAsynchronously {
                switch exportSession!.status {
                    case .completed:
                        print("Video exported successfully")
                        completion(fileurl.path)
                    case .failed, .cancelled:
                        print("Error while selecting video \(String(describing: exportSession?.error))")
                        completion(nil)
                    default:
                        print("Video exporting status \(String(describing: exportSession?.status))")
                        completion(nil)
                }
            }
        }
    }
        
    func exportGifAsset(_ asset: PHAsset, completion: @escaping ((_ gifPath: String?) -> Void)) {
        let filename = String(format: "GIF-%f.gif", Date().timeIntervalSince1970 * 1000)
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsURL.appendingPathComponent(filename)

        let options = PHImageRequestOptions()
        options.isSynchronous = false

            PHImageManager.default().requestImageDataAndOrientation(for: asset, options: options) { (data, _, _, _) in
            guard let imageData = data else {
                completion(nil)
                return
            }

            let extensionOfFile =  NSURL(fileURLWithPath: fileURL.absoluteString).pathExtension
            
            if extensionOfFile == "gif" {
                do {
                    try imageData.write(to: fileURL)
                    print("GIF exported successfully")
                    completion(fileURL.path)
                } catch {
                    print("Error while saving GIF: \(error)")
                    completion(nil)
                }
            } else {
                print("Invalid GIF data")
                completion(nil)
            }
        }
    }
        
    // MARK: - Button Actions

    @objc private func cancelAction() {
        navigationController?.dismiss(animated: true, completion: nil)
    }

    @objc private func doneAction() {
        activityIndicator.startAnimating()
        let caption = captionBar.text ?? ""
        export { images, gifs, videos, error in
            self.activityIndicator.stopAnimating()
            if error {
                let alertTitle = self.localizedString(
                    forKey: "PhotoAlbumFailureTitle",
                    withDefaultValue: SystemMessage.PhotoAlbum.FailureTitle,
                    fileName: self.localizedStringFileName
                )
                let alertMessage = self.localizedString(
                    forKey: "VideoExportError",
                    withDefaultValue: SystemMessage.Warning.videoExportError,
                    fileName: self.localizedStringFileName
                )
                let buttonTitle = self.localizedString(
                    forKey: "OkMessage",
                    withDefaultValue: SystemMessage.ButtonName.ok,
                    fileName: self.localizedStringFileName
                )
                let alert = UIAlertController(
                    title: alertTitle,
                    message: alertMessage,
                    preferredStyle: UIAlertController.Style.alert
                )
                alert.addAction(UIAlertAction(title: buttonTitle, style: UIAlertAction.Style.default, handler: { _ in
                        self.delegate?.filesSelectedWithCaption(images: images, gifs: gifs, videos: videos, caption: caption)
                        self.navigationController?.dismiss(animated: true, completion: nil)
                }))
                self.present(alert, animated: true, completion: nil)
            } else {
                self.delegate?.filesSelectedWithCaption(images: images, gifs: gifs, videos: videos, caption: caption)
                self.navigationController?.dismiss(animated: true, completion: nil)
            }
        }
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

    // MARK: - Image Access
    
    private func getAllImage(completion: (_ success: Bool) -> Void) {
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.includeHiddenAssets = false

        let p1 = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        let p2 = NSPredicate(format: "mediaType = %d", PHAssetMediaType.video.rawValue)
        allPhotosOptions.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [p1, p2])
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        allPhotos = PHAsset.fetchAssets(with: allPhotosOptions)
        (allPhotos != nil) ? completion(true) : completion(false)
    }
    
    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return savedPhotos.count + 1
    }
        
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! KMImageCell
            
        if indexPath.item == savedPhotos.count {
            // Placeholder image (last cell)
            cell.imageView.image = UIImage()
            cell.deleteButton.isHidden = true
            cell.addButton.isHidden = false
            cell.backgroundColor = UIColor.gray.withAlphaComponent(0.1)
            cell.newAttachmentLabel.isHidden = false
            cell.addButton.addTarget(self, action: #selector(addButtonTapped(_: )), for: .touchUpInside)
        } else {
            let thumbnailSize = CGSize(width: 200, height: 200)
            cell.deleteButton.isHidden = false
            cell.addButton.isHidden = true
            cell.deleteButton.tag = indexPath.item
            cell.newAttachmentLabel.isHidden = true
            let asset = savedPhotos[indexPath.item]
            cell.deleteButton.addTarget(self, action: #selector(deleteButtonTapped(_:)), for: .touchUpInside)
            PHCachingImageManager.default().requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: option, resultHandler: { image, _ in
                cell.imageView.image = image
            })
        }
            
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
        
    @objc private func deleteButtonTapped(_ sender: UIButton) {
        let index = sender.tag
        delegate?.unselectedFiles(index: index)
        savedPhotos.remove(at: index)
        selectedFiles.remove(at: index)
        collectionView.reloadData()
    }
        
    @objc private func addButtonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
        
    @objc private func backTapped() {
        _ = navigationController?.popViewController(animated: true)
    }
}

class KMImageCell: UICollectionViewCell {
    
    let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "trash.square.fill"), for: .normal)
        button.tintColor = .gray
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true
        return button
    }()
    
    let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = UIColor.kmDynamicColor(light: UIColor.white, dark: UIColor.systemGray2)
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        button.isUserInteractionEnabled = true
        return button
    }()
    
    let transparentBar: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let newAttachmentLabel: UIView = {
        let label = UILabel()
        label.text = "New Attachment"
        label.font = .systemFont(ofSize: 14)
        label.textColor =  UIColor.kmDynamicColor(light: UIColor.text(.white), dark: UIColor.text(.grayCC))
        label.isHidden = true
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraint()
    }
    
    private func setupConstraint() {
        
        contentView.addSubview(imageView)
        contentView.addSubview(addButton)
        addViewsForAutolayout(views: [transparentBar, newAttachmentLabel, deleteButton])
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            transparentBar.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
            transparentBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            transparentBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            transparentBar.heightAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 0.25),
            
            deleteButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            deleteButton.widthAnchor.constraint(equalToConstant: 35),
            deleteButton.heightAnchor.constraint(equalToConstant: 35),
            
            newAttachmentLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            newAttachmentLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -25),
            
            addButton.topAnchor.constraint(equalTo: imageView.topAnchor),
            addButton.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
            addButton.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
            addButton.leadingAnchor.constraint(equalTo: imageView.leadingAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
