//
//  ALKPhotoPicker.swift
//  ApplozicSwift
//
//  Created by Mukesh on 06/10/20.
//

import Foundation
import PhotosUI

protocol ALKPhotoPickerDelegate: AnyObject {
    func photosSelected()
}

class ALKPhotoPicker: NSObject {
    static var SelectionLimit = 10
    weak var delegate: ALKPhotoPickerDelegate?

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
}

extension ALKPhotoPicker: PHPickerViewControllerDelegate {
    @available(iOS 14, *)
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.displayIPActivityAlert()
        for result in results {
            let provider = result.itemProvider
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, error in
                    if let error = error {
                        print("Failed to export image due to error: \(error)")
                    } else if let image = image {
                        print("Image exported: \(String(describing: image.description))")
                    }
                }
            } else {
                provider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { url, error in
                    if let error = error {
                        print("Failed to export video due to error: \(error)")
                    } else if let url = url {
                        print("Video exported: \(url.description)")
                        DispatchQueue.main.async {
                            picker.dismissIPActivityAlert {
                                picker.dismiss(animated: true)
                            }
                        }
                    }
                }
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
