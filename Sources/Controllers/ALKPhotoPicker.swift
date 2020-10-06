//
//  ALKPhotoPicker.swift
//  ApplozicSwift
//
//  Created by Mukesh on 06/10/20.
//

import Foundation
import PhotosUI

//protocol ALKPhotoPickerDelegate: AnyObject {
//    func documentSelected(at url: URL, fileName: String)
//}

class ALKPhotoPicker: NSObject {
    weak var delegate: ALKDocumentManagerDelegate?

    @available(iOS 14, *)
    func showPicker(from controller: UIViewController) {
        let photoLibrary = PHPhotoLibrary.shared()
        let configuration = PHPickerConfiguration(photoLibrary: photoLibrary)
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        controller.present(picker, animated: true)
    }
}

extension ALKPhotoPicker: PHPickerViewControllerDelegate {
    @available(iOS 14, *)
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        let identifiers = results.compactMap(\.assetIdentifier)
        let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: identifiers, options: nil)

        // TODO: Do something with the fetch result if you have Photos Library access
    }
}
