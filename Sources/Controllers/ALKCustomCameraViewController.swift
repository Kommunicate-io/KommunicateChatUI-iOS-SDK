//
//  ALKCustomCameraViewController.swift
//
//
//  Created by Mukesh Thawani on 04/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import UIKit
import AVFoundation
import Photos


enum ALKCameraPhotoType {
    case NoCropOption
    case CropOption
}

enum ALKCameraType {
    case Front
    case Back
}

var camera = ALKCameraType.Back

protocol ALKCustomCameraProtocol {
    func customCameraDidTakePicture(cropedImage: UIImage)
}

final class ALKCustomCameraViewController: ALKBaseViewController, AVCapturePhotoCaptureDelegate, Localizable {

    //delegate
    var customCamDelegate: ALKCustomCameraProtocol!
    var camera = ALKCameraType.Back

    //photo library
    var asset: PHAsset!
    var allPhotos: PHFetchResult<PHAsset>!
    var selectedImage: UIImage!
    var cameraMode: ALKCameraPhotoType = .NoCropOption
    let option = PHImageRequestOptions()

    var cameraOutput: Any? = {
        if #available(iOS 10.0, *) {
            return AVCapturePhotoOutput()
        }
        return nil
    }()

    @IBOutlet private var previewView: UIView!
    @IBOutlet private var btnCapture: UIButton!
    @IBOutlet private var previewGallery: UICollectionView!
    @IBOutlet private var btnSwitchCam: UIButton!

    private var captureSession = AVCaptureSession()
    private let stillImageOutput = AVCaptureStillImageOutput()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    // If we find a device we'll store it here for later use
    private var captureDevice: AVCaptureDevice?
    private var captureDeviceInput: AVCaptureDeviceInput?
    fileprivate var isUserControlEnable = true
    
    fileprivate lazy var localizedStringFileName: String = configuration.localizedStringFileName

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = localizedString(forKey: "Camera", withDefaultValue: SystemMessage.LabelName.Camera, fileName: localizedStringFileName)
        btnSwitchCam.isHidden = true
        checkPhotoLibraryPermission()
        reloadCamera()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupNavigation()
        setupView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        //ask for permission
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch authStatus {
        case .denied:
            // ask for permissions
            
            let camNotAvailable = localizedString(forKey: "CamNotAvaiable", withDefaultValue: SystemMessage.Warning.CamNotAvaiable, fileName: localizedStringFileName)
            let pleaseAllowCamera = localizedString(forKey: "PleaseAllowCamera", withDefaultValue: SystemMessage.Camera.PleaseAllowCamera, fileName: localizedStringFileName)
            let alertController = UIAlertController(title: camNotAvailable, message: pleaseAllowCamera, preferredStyle: .alert)
            let settingsTitle = localizedString(forKey: "Settings", withDefaultValue: SystemMessage.LabelName.Settings, fileName: localizedStringFileName)
            let settingsAction = UIAlertAction(title: settingsTitle, style: .default) { (_) -> Void in
                guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                    return
                }
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                            //
                        })
                    } else {
                        // Fallback on earlier versions
                        UIApplication.shared.openURL(settingsUrl)
                    }
                }
            }
            alertController.addAction(settingsAction)
            let cancelTitle = localizedString(forKey: "Cancel", withDefaultValue: SystemMessage.LabelName.Cancel, fileName: localizedStringFileName)
            let cancelAction = UIAlertAction(title: cancelTitle, style: .default, handler: nil)
            alertController.addAction(cancelAction)
            present(alertController, animated: true, completion: nil)
        default: ()
        }

    }

    static func makeInstanceWith(delegate: ALKCustomCameraProtocol, and configuration: ALKConfiguration) -> ALKBaseNavigationViewController? {
        let storyboard = UIStoryboard.name(storyboard: UIStoryboard.Storyboard.camera, bundle: Bundle.applozic)
        guard
            let vc = storyboard.instantiateViewController(withIdentifier: "CustomCameraNavigationController")
                as? ALKBaseNavigationViewController,
            let cameraVC = vc.viewControllers.first as? ALKCustomCameraViewController else { return nil }
        cameraVC.setCustomCamDelegate(camMode: .NoCropOption, camDelegate: delegate)
        cameraVC.configuration = configuration
        return vc
    }

    func capturePhoto() {

        if #available(iOS 10.0, *) {

            let cameraOutput = self.cameraOutput as? AVCapturePhotoOutput
            if let connection = cameraOutput?.connection(with: AVMediaType.video) {

                if connection.isVideoOrientationSupported,
                    let orientation = AVCaptureVideoOrientation(orientation: UIDevice.current.orientation) {
                    connection.videoOrientation = orientation
                }

                let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecJPEG])

                if (connection.isActive) {
                    cameraOutput?.capturePhoto(with: settings, delegate: self)
                    //connection is active
                } else {
                    //connection is not active
                    //try to change self.captureSession.sessionPreset,
                    //or change videoDevice.activeFormat
                }

            }

        }

    }


    @available(iOS 10.0, *)
    public func photoOutput(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?,
        resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Swift.Error?) {

        if let error = error { print(error) }

        else if let buffer = photoSampleBuffer, let data = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: buffer, previewPhotoSampleBuffer: nil),

            let image = UIImage(data: data) {
            self.selectedImage = image
            switch self.cameraMode {
            case .CropOption:
                self.performSegue(withIdentifier: "goToCropImageView", sender: nil)
            default:
                self.performSegue(withIdentifier: "pushToALKCustomCameraPreviewViewController", sender: nil)
            }
        }

    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }


    override func viewDidLayoutSubviews()
    {
        //set frame
        self.previewLayer?.frame = self.previewView.frame
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: - Set protocol and Observer
    func setCustomCamDelegate(camMode: ALKCameraPhotoType, camDelegate: ALKCustomCameraProtocol)
    {
        self.cameraMode = camMode
        self.customCamDelegate = camDelegate
    }

    //MARK: - UI control
    private func setupNavigation() {
        
        let title = localizedString(forKey: "Camera", withDefaultValue: SystemMessage.LabelName.Camera, fileName: localizedStringFileName)
        self.navigationItem.title = title
        self.navigationController?.navigationBar.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.tintColor = UIColor.black
        guard let navVC = self.navigationController else { return }
        navVC.navigationBar.shadowImage = UIImage()
        navVC.navigationBar.isTranslucent = true
        var backImage = UIImage.init(named: "icon_back", in: Bundle.applozic, compatibleWith: nil)
        backImage = backImage?.imageFlippedForRightToLeftLayoutDirection()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: backImage, style: .plain, target: self, action: #selector(dismissCameraPress(_:)))
    }

    private func setupView() {
        btnCapture.imageView?.tintColor = UIColor.white
        btnSwitchCam.imageView?.tintColor = UIColor.white
    }

    private func reloadCamera()
    {
        //stop previous capture session
        captureSession.stopRunning()
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.removeFromSuperlayer()
        self.previewLayer?.removeFromSuperlayer()

        // Do any additional setup after loading the view.
        captureSession.sessionPreset = AVCaptureSession.Preset.high

        let devices = AVCaptureDevice.devices()
        for device in devices {
            // Make sure this particular device supports video
            if (device.hasMediaType(AVMediaType.video)) {
                if(camera == .Back)
                {
                    if(device.position == AVCaptureDevice.Position.back) {
                        captureDevice = device
                        if captureDevice != nil {
                            checkCameraPermission()
                        }
                    }
                }
                else
                {
                    if(device.position == AVCaptureDevice.Position.front) {
                        captureDevice = device
                        if captureDevice != nil {
                            checkCameraPermission()
                        }
                    }
                }
            }
        }
    }

    private func checkPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            self.getAllImage(completion: { [weak self] (isGrant) in
                guard let weakSelf = self else { return }
                weakSelf.createScrollGallery(isGrant: isGrant)
            })
            break
            //handle authorized status
        case .denied, .restricted:
            break
            //handle denied status
        case .notDetermined:
            // ask for permissions
            PHPhotoLibrary.requestAuthorization() { status in
                switch status {
                case .authorized:
                    self.getAllImage(completion: { [weak self] (isGrant) in
                        guard let weakSelf = self else { return }
                        weakSelf.createScrollGallery(isGrant: isGrant)
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

    private func checkCameraPermission()
    {
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch authStatus {
        case .authorized:
            btnSwitchCam.isHidden = false
            beginSession()
        case .denied:
            // ask for permissions

            let camNotAvailable = localizedString(forKey: "CamNotAvaiable", withDefaultValue: SystemMessage.Warning.CamNotAvaiable, fileName: localizedStringFileName)
            let pleaseAllowCamera = localizedString(forKey: "PleaseAllowCamera", withDefaultValue: SystemMessage.Camera.PleaseAllowCamera, fileName: localizedStringFileName)

            let alertController = UIAlertController (title: camNotAvailable, message: pleaseAllowCamera, preferredStyle: .alert)
            let settingsTitle = localizedString(forKey: "Settings", withDefaultValue: SystemMessage.LabelName.Settings, fileName: localizedStringFileName)
            let settingsAction = UIAlertAction(title: settingsTitle, style: .default) { (_) -> Void in
                guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                    return
                }

                if UIApplication.shared.canOpenURL(settingsUrl) {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                            //
                        })
                    } else {
                        // Fallback on earlier versions
                        UIApplication.shared.openURL(settingsUrl)
                    }
                }
            }
            alertController.addAction(settingsAction)
            let cancelTitle = localizedString(forKey: "Cancel", withDefaultValue: SystemMessage.LabelName.Cancel, fileName: localizedStringFileName)
            let cancelAction = UIAlertAction(title: cancelTitle, style: .default, handler: nil)
            alertController.addAction(cancelAction)
            present(alertController, animated: true, completion: nil)
        case .notDetermined:
            // ask for permissions
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { [weak self] (isGrant) in
                guard let weakSelf = self else { return }
                if isGrant {
                    DispatchQueue.main.async {
                        weakSelf.btnSwitchCam.isHidden = false
                    }
                }
            })
            self.beginSession()
        default: ()
        }
    }

    @IBAction private func actionCameraCapture(_ sender: AnyObject) {
        saveToCamera()
    }

    private func beginSession() {

        do {
            if let captureDevice = captureDevice {
                let captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice)
                self.captureSession.addInput(captureDeviceInput)
                if #available(iOS 10.0, *) {
                    let cameraOutput = self.cameraOutput as? AVCapturePhotoOutput
                    cameraOutput?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecJPEG])], completionHandler: nil)

                    if self.captureSession.canAddOutput(cameraOutput!) {
                        self.captureSession.addOutput(cameraOutput!)
                    }
                } else {
                    stillImageOutput.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]

                    if captureSession.canAddOutput(stillImageOutput) {
                        captureSession.addOutput(stillImageOutput)
                    }
                }

            } else { return }
        }
        catch let error {
            print("Error while adding camera input: \(error)")
        }

        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)

        //orientation of video
        let statusBarOrientation = UIApplication.shared.statusBarOrientation
        var initialVideoOrientation = AVCaptureVideoOrientation.portrait
        if (statusBarOrientation != UIInterfaceOrientation.unknown) {
            initialVideoOrientation = AVCaptureVideoOrientation(rawValue: statusBarOrientation.rawValue)!
        }

        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewLayer.connection?.videoOrientation = initialVideoOrientation
        self.previewLayer = previewLayer
        //add camera view
        self.previewView.layer.addSublayer(previewLayer)
        captureSession.startRunning()
    }

    private func saveToCamera() {

        if isUserControlEnable {

            isUserControlEnable = false

            if #available(iOS 10.0, *) {

                self.capturePhoto()

            } else {
                if let videoConnection = stillImageOutput.connection(with: AVMediaType.video) {

                    if videoConnection.isVideoOrientationSupported,
                        let orientation = AVCaptureVideoOrientation(orientation: UIDevice.current.orientation) {
                        videoConnection.videoOrientation = orientation
                    }

                    stillImageOutput.captureStillImageAsynchronously(from: videoConnection, completionHandler: { (CMSampleBuffer, Error) in
                        if let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(CMSampleBuffer!) {

                            if let cameraImage = UIImage(data: imageData) {
                                self.selectedImage = cameraImage
                                switch self.cameraMode {
                                case .CropOption:
                                    self.performSegue(withIdentifier: "goToCropImageView", sender: nil)
                                default:
                                    self.performSegue(withIdentifier: "pushToALKCustomCameraPreviewViewController", sender: nil)
                                }
                            }
                        }
                    })
                }
            }

            enableCameraControl(inSec: 1)
        }
    }

    private func convertCIImageToCGImage(inputImage: CIImage) -> CGImage! {
        let context = CIContext(options: nil)
        return context.createCGImage(inputImage, from: inputImage.extent)
    }

    @IBAction private func switchCamPress(_ sender: Any) {

        if isUserControlEnable {
            isUserControlEnable = false

            if(camera == .Back)
            {
                camera = .Front
            }
            else
            {
                camera = .Back
            }

            let devices = AVCaptureDevice.devices()
            for device in devices {
                if (device.hasMediaType(AVMediaType.video)) {

                    let newCamera: AVCaptureDevice?
                    if(camera == .Front) {
                        newCamera = self.cameraWithPosition(position: AVCaptureDevice.Position.front)
                    } else {
                        newCamera = self.cameraWithPosition(position: AVCaptureDevice.Position.back)
                    }

                    guard let newCam = newCamera else { return }

                    let currentCameraInput: AVCaptureInput = captureSession.inputs[0]
                    captureSession.removeInput(currentCameraInput)

                    do {
                        try captureSession.addInput(AVCaptureDeviceInput(device: newCam))

                        if #available(iOS 10.0, *) {
                            let cameraOutput = self.cameraOutput as? AVCapturePhotoOutput

                            cameraOutput?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecJPEG])], completionHandler: nil)

                            if self.captureSession.canAddOutput(cameraOutput!) {
                                self.captureSession.addOutput(cameraOutput!)
                            }

                        } else {
                            stillImageOutput.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]

                            if captureSession.canAddOutput(stillImageOutput) {
                                captureSession.addOutput(stillImageOutput)
                            }
                        }

                    }
                    catch let error {
                        print("Error while adding camera input: \(error)")
                    }
                    captureSession.commitConfiguration()

                    enableCameraControl(inSec: 1)
                    break
                }
            }
        }
    }

    private func cameraWithPosition(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let devices = AVCaptureDevice.devices()
        for device in devices {
            if((device as AnyObject).position == position) {
                return device
            }
        }
        return AVCaptureDevice(uniqueID: "")
    }


    @IBAction private func dismissCameraPress(_ sender: Any) {
        self.navigationController?.dismiss(animated: false, completion: nil)
    }

    private func enableCameraControl(inSec: Double)
    {
        let disT: DispatchTime = DispatchTime.now() + inSec
        DispatchQueue.main.asyncAfter(deadline: disT, execute: {
            self.isUserControlEnable = true
        })
    }

    //MARK: - Access to gallery images
    private func getAllImage(completion: (_ success: Bool) -> Void) {
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.includeHiddenAssets = false
        allPhotosOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        allPhotos = PHAsset.fetchAssets(with: allPhotosOptions)
        (allPhotos != nil) ? completion(true) : completion(false)
    }

    private func createScrollGallery(isGrant: Bool) {
        if isGrant
            {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                    self.previewGallery.reloadData()
                })
        }

    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var destination = segue.destination
        if let topViewController = (destination as? UINavigationController)?.topViewController {
            destination = topViewController
        }

        if let cropView = destination as? ALKCustomCropImageViewController {
            cropView.configuration = configuration
            cropView.setSelectedImage(pickImage: self.selectedImage, camDelegate: customCamDelegate)

        } else if let customCameraPreviewVC = destination as? ALKCustomCameraPreviewViewController {
            customCameraPreviewVC.configuration = configuration
            customCameraPreviewVC.setSelectedImage(pickImage: self.selectedImage, camDelegate: customCamDelegate)
        }
    }
}

extension ALKCustomCameraViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    // MARK: CollectionViewEnvironment
    private class CollectionViewEnvironment {
        struct Spacing {
            static let lineitem: CGFloat = 5.0
            static let interitem: CGFloat = 0.0
            static let inset: UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 6.0, bottom: 0.0, right: 6.0)
        }
    }

    // MARK: UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //grab all the images
        let asset = allPhotos.object(at: indexPath.item)
        PHCachingImageManager.default().requestImageData(for: asset, options: nil) { (imageData, _, _, _) in
            let image = UIImage(data: imageData!)
            self.selectedImage = image

            switch self.cameraMode {
            case .CropOption:
                self.performSegue(withIdentifier: "goToCropImageView", sender: nil)
            default:
                self.performSegue(withIdentifier: "pushToALKCustomCameraPreviewViewController", sender: nil)
            }
        }
    }

    // MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(allPhotos == nil)
        {
            return 0
        }
        else
        {
            return allPhotos.count//horizontal
        }

    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ALKPhotoCollectionCell", for: indexPath) as! ALKPhotoCollectionCell

        let asset = allPhotos.object(at: indexPath.item)
        let thumbnailSize: CGSize = CGSize(width: 200, height: 200)
        option.isSynchronous = true
        PHCachingImageManager.default().requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: option, resultHandler: { image, _ in
            cell.imgPreview.image = image
        })

        cell.imgPreview.backgroundColor = UIColor.white

        return cell
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1//the vertical side
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
