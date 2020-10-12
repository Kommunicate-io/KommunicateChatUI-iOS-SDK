//
//  ALKPhotoPicker.swift
//  ApplozicSwift
//
//  Created by Mukesh on 06/10/20.
//

import Foundation
import PhotosUI

class ALKPhotoPicker: NSObject {
    static var SelectionLimit = 10
    weak var delegate: ALKCustomPickerDelegate?

    fileprivate let indicatorSize = ALKActivityIndicator.Size(width: 50, height: 50)
    fileprivate lazy var activityIndicator = ALKActivityIndicator(frame: .zero, backgroundColor: .lightGray, indicatorColor: .white, size: indicatorSize)

    @available(iOS 14, *)
    func openGallery(from controller: UIViewController) {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = ALKPhotoPicker.SelectionLimit
        configuration.filter = .any(of: [.images, .videos])
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        controller.present(picker, animated: true)
    }

    @available(iOS 14, *)
    private func export(
        results: [PHPickerResult],
        completion: @escaping (_ images: [UIImage], _ videos: [String]) -> Void
    ) {
        var selectedImages: [UIImage] = []
        var selectedVideosPath: [String] = []
        let exportGroup = DispatchGroup()
        DispatchQueue.global(qos: .userInitiated).async {
            for result in results {
                exportGroup.enter()
                let provider = result.itemProvider
                if provider.canLoadObject(ofClass: UIImage.self) {
                    provider.loadObject(ofClass: UIImage.self) { image, error in
                        if let error = error {
                            print("Failed to export image due to error: \(error)")
                        } else if let image = image as? UIImage {
                            print("Image exported: \(String(describing: image.description))")
                            selectedImages.append(image)
                        }
                        exportGroup.leave()
                    }
                } else {
                    provider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { url, error in
                        if let error = error {
                            print("Failed to export video due to error: \(error)")
                        } else if let url = url {
                            print("Video exported: \(url.description)")
                            let fileName = url.lastPathComponent
                            let uniqueFileName = "\(Int(Date().timeIntervalSince1970 * 1000))-\(fileName)"
                            let newFileURL = ALKFileUtils().getDocumentDirectory(fileName: uniqueFileName)
                            do {
                                if FileManager.default.fileExists(atPath: newFileURL.path) {
                                    try FileManager.default.removeItem(atPath: newFileURL.path)
                                }
                                try FileManager.default.moveItem(atPath: url.path, toPath: newFileURL.path)
                                selectedVideosPath.append(newFileURL.path)
                            } catch {
                                print("Failed to export video due to error: \(error)")
                            }
                        }
                        exportGroup.leave()
                    }
                }
            }
            exportGroup.wait()
            DispatchQueue.main.async {
                completion(selectedImages, selectedVideosPath)
            }
        }
    }
}

@available(iOS 14, *)
extension ALKPhotoPicker: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.displayIPActivityAlert()
        export(results: results) { images, videos in
            picker.dismissIPActivityAlert {
                picker.dismiss(animated: true)
                self.delegate?.filesSelected(images: images, videos: videos)
            }
        }
    }
}

extension UIAlertController {
    private struct ActivityIndicatorData {
        static var activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
    }

    func addActivityIndicator() {
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: 40,height: 40)
        ActivityIndicatorData.activityIndicator.color = UIColor.blue
        ActivityIndicatorData.activityIndicator.startAnimating()
        vc.view.addSubview(ActivityIndicatorData.activityIndicator)
        self.setValue(vc, forKey: "contentViewController")
    }

    func dismissActivityIndicator(_ completion: (() -> Void)?) {
        ActivityIndicatorData.activityIndicator.stopAnimating()
        self.dismiss(animated: false) {
            completion?()
        }
    }
}

extension UIViewController {
    private struct activityAlert {
        static var activityIndicatorAlert: UIAlertController?
    }

    func displayIPActivityAlert() {
        activityAlert.activityIndicatorAlert = UIAlertController(title: NSLocalizedString("Exporting...", comment: ""), message: nil , preferredStyle: UIAlertController.Style.alert)
        activityAlert.activityIndicatorAlert!.addActivityIndicator()
        var topController:UIViewController = UIApplication.shared.keyWindow!.rootViewController!
        while ((topController.presentedViewController) != nil) {
            topController = topController.presentedViewController!
        }
        topController.present(activityAlert.activityIndicatorAlert!, animated:true, completion:nil)
    }

    func dismissIPActivityAlert(completion: (() -> Void)?) {
        activityAlert.activityIndicatorAlert!.dismissActivityIndicator(completion)
        activityAlert.activityIndicatorAlert = nil
    }
}
