//
//  ALKPhotoPicker.swift
//  ApplozicSwift
//
//  Created by Mukesh on 06/10/20.
//

import Foundation
import PhotosUI

class ALKPhotoPicker: NSObject, Localizable {
    weak var delegate: ALKCustomPickerDelegate?

    private var localizationFileName: String
    private var selectionLimit: Int
    private var loadingTitle: String = ""

    init(localizationFileName: String, selectionLimit: Int) {
        self.localizationFileName = localizationFileName
        self.selectionLimit = selectionLimit
        super.init()
        loadingTitle = localizedString(
            forKey: "ExportLoadingIndicatorText",
            withDefaultValue: SystemMessage.Information.ExportLoadingIndicatorText,
            fileName: localizationFileName
        )
    }

    @available(iOS 14, *)
    func openGallery(from controller: UIViewController) {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = selectionLimit
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
                        } else if let url = url, let newURL = ALKFileUtils().moveFileToDocuments(fileURL: url) {
                            selectedVideosPath.append(newURL.path)
                            print("Video exported: \(newURL.description)")
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
        guard !results.isEmpty else {
            picker.dismiss(animated: true)
            return
        }
        picker.displayIPActivityAlert(title: loadingTitle)
        export(results: results) { images, videos in
            picker.dismissIPActivityAlert {
                picker.dismiss(animated: true)
                self.delegate?.filesSelected(images: images, videos: videos)
            }
        }
    }
}
