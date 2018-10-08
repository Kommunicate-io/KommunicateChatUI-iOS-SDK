//
//  CustomPickerView.swift
//  ApplozicSwift
//
//  Created by Mukesh Thawani on 14/07/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import UIKit
import Photos

protocol ALKCustomPickerDelegate: class {
    func filesSelected(images: [UIImage], videos: [String])
}

class ALKCustomPickerViewController: ALKBaseViewController, Localizable {
    //photo library
    var asset: PHAsset!
    var allPhotos: PHFetchResult<PHAsset>!
    var selectedImage:UIImage!
    var cameraMode:ALKCameraPhotoType = .NoCropOption
    let option = PHImageRequestOptions()
    var selectedRows = [Int]()
    var selectedImages = [Int: UIImage]()
    var selectedVideos = [Int: String]()

    @IBOutlet weak var doneButton: UIBarButtonItem!
    weak var delegate: ALKCustomPickerDelegate?

    @IBOutlet weak var previewGallery: UICollectionView!


    override func viewDidLoad() {
        super.viewDidLoad()

        doneButton.title = localizedString(forKey: "DoneButton", withDefaultValue: SystemMessage.ButtonName.Done, config: configuration)
        self.title = localizedString(forKey: "PhotosTitle", withDefaultValue: SystemMessage.LabelName.Photos, config: configuration)
        checkPhotoLibraryPermission()
        previewGallery.delegate = self
        previewGallery.dataSource = self
        previewGallery.allowsMultipleSelection = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigation()

    }

    static func makeInstanceWith(delegate: ALKCustomPickerDelegate, and configuration: ALKConfiguration) -> ALKBaseNavigationViewController? {
        let storyboard = UIStoryboard.name(storyboard: UIStoryboard.Storyboard.picker, bundle: Bundle.applozic)
        guard
            let vc = storyboard.instantiateViewController(withIdentifier: "CustomPickerNavigationViewController")
                as? ALKBaseNavigationViewController,
            let cameraVC = vc.viewControllers.first as? ALKCustomPickerViewController else { return nil }
        cameraVC.delegate = delegate
        cameraVC.configuration = configuration
        return vc
    }

    //MARK: - UI control
    private func setupNavigation() {
        self.navigationController?.title = title
        self.navigationController?.navigationBar.backgroundColor = UIColor.white
        guard let navVC = self.navigationController else {return}
        navVC.navigationBar.shadowImage = UIImage()
        navVC.navigationBar.isTranslucent = true
        var backImage = UIImage.init(named: "icon_back", in: Bundle.applozic, compatibleWith: nil)
        backImage = backImage?.imageFlippedForRightToLeftLayoutDirection()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: backImage, style: .plain, target: self , action: #selector(dismissAction(_:)))
        self.navigationController?.navigationBar.tintColor = UIColor.black

    }

    private func checkPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            self.getAllImage(completion: { [weak self] (isGrant) in
                guard let weakSelf = self else {return}
                weakSelf.createScrollGallery(isGrant:isGrant)
            })
            break
        //handle authorized status
        case .denied, .restricted :
            break
        //handle denied status
        case .notDetermined:
            // ask for permissions
            PHPhotoLibrary.requestAuthorization() { status in
                switch status {
                case .authorized:
                    self.getAllImage(completion: {[weak self] (isGrant) in
                        guard let weakSelf = self else {return}
                        weakSelf.createScrollGallery(isGrant:isGrant)
                    })
                    break
                // as above
                case .denied, .restricted:
                    break
                default: break
                    //whatever
                }
            }
        }
    }

    //MARK: - Access to gallery images
    private func getAllImage(completion: (_ success: Bool) -> Void) {
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.includeHiddenAssets = false

        let p1 = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        let p2 = NSPredicate(format: "mediaType = %d", PHAssetMediaType.video.rawValue)
        allPhotosOptions.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [p1, p2])
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        allPhotos = PHAsset.fetchAssets(with: allPhotosOptions)
        (allPhotos != nil) ? completion(true) :  completion(false)
    }

    private func createScrollGallery(isGrant:Bool) {
        if isGrant
        {
            self.selectedRows = Array(repeating: 0, count: (self.allPhotos != nil) ? self.allPhotos.count:0)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                self.previewGallery.reloadData()
            })
        }

    }

    func exportVideoAsset(indexPath: IndexPath, _ asset: PHAsset) {
        let filename = String(format: "VID-%f.mp4", Date().timeIntervalSince1970*1000)
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        let filePath = documentsUrl.absoluteString.appending(filename)
        guard var fileurl = URL(string: filePath) else { return }
        print("exporting video to ", fileurl)
        fileurl = fileurl.standardizedFileURL


        let options = PHVideoRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true

        // remove any existing file at that location
        do {
            try FileManager.default.removeItem(at: fileurl)
        }
        catch {
            // most likely, the file didn't exist.  Don't sweat it
        }

        PHImageManager.default().requestExportSession(forVideo: asset, options: options, exportPreset: AVAssetExportPresetHighestQuality) {
            (exportSession: AVAssetExportSession?, _) in

            if exportSession == nil {
                print("COULD NOT CREATE EXPORT SESSION")
                return
            }

            exportSession!.outputURL = fileurl
            exportSession!.outputFileType = AVFileType.mp4 //file type encode goes here, you can change it for other types

            print("GOT EXPORT SESSION")
            exportSession!.exportAsynchronously() {
                print("EXPORT DONE")
                self.selectedVideos[indexPath.row] = fileurl.path
            }

            print("progress: \(exportSession!.progress)")
            print("error: \(String(describing: exportSession?.error))")
            print("status: \(exportSession!.status.rawValue)")
        }
    }

    @IBAction func doneButtonAction(_ sender: UIBarButtonItem) {

        let videos = Array(selectedVideos.values)
        let images = Array(selectedImages.values)
        delegate?.filesSelected(images: images, videos: videos)
        self.navigationController?.dismiss(animated: false, completion: nil)

    }


    @IBAction func dismissAction(_ sender: UIBarButtonItem) {
        self.navigationController?.dismiss(animated: false, completion: nil)
    }
}

extension ALKCustomPickerViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    // MARK: CollectionViewEnvironment
    private class CollectionViewEnvironment {
        struct Spacing {
            static let lineitem: CGFloat = 5.0
            static let interitem: CGFloat = 0.0
            static let inset: UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 3.0, bottom: 0.0, right: 3.0)
        }
    }

    // MARK: UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //grab all the images
        let asset = allPhotos.object(at: indexPath.item)
        if selectedRows[indexPath.row] == 1 {
            selectedRows[indexPath.row] = 0
            if asset.mediaType == .video {
                selectedVideos.removeValue(forKey: indexPath.row)
            } else {
                selectedImages.removeValue(forKey: indexPath.row)
            }
        } else {
            selectedRows[indexPath.row] = 1
            if asset.mediaType == .video {
                exportVideoAsset(indexPath: indexPath, asset)
            } else {
                PHCachingImageManager.default().requestImageData(for: asset, options:nil) { (imageData, _, _, _) in
                    let image = UIImage(data: imageData!)
                    self.selectedImages[indexPath.row] = image
                }
            }
        }

        previewGallery.reloadItems(at: [indexPath])
    }

    // MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(allPhotos == nil)
        {
            return 0
        }
        else
        {
            return allPhotos.count
        }

    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ALKPhotoCollectionCell", for: indexPath) as! ALKPhotoCollectionCell
        
//        cell.selectedIcon.isHidden = true
        cell.videoIcon.isHidden = true
        cell.selectedIcon.isHidden = true
        if selectedRows[indexPath.row] == 1 {
            cell.selectedIcon.isHidden = false
        }

        let asset = allPhotos.object(at: indexPath.item)
        if asset.mediaType == .video {
            cell.videoIcon.isHidden = false
        }
        let thumbnailSize:CGSize = CGSize(width: 200, height: 200)
        option.isSynchronous = true
        PHCachingImageManager.default().requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: option, resultHandler: { image, _ in
            cell.imgPreview.image = image
        })

        cell.imgPreview.backgroundColor = UIColor.white

        return cell
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CollectionViewEnvironment.Spacing.lineitem
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return CollectionViewEnvironment.Spacing.interitem
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return CollectionViewEnvironment.Spacing.inset
    }
}


