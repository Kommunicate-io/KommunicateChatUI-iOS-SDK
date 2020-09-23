//
//  ALKDocumentManager.swift
//  ApplozicSwift
//
//  Created by Mukesh on 06/08/20.
//

import MobileCoreServices
import UIKit

protocol ALKDocumentManagerDelegate: AnyObject {
    func documentSelected(at url: URL, fileName: String)
}

class ALKDocumentManager: NSObject {
    weak var delegate: ALKDocumentManagerDelegate?

    func showPicker(from controller: UIViewController) {
        let types = [
            kUTTypeText as String,
            kUTTypePresentation as String,
            kUTTypeSpreadsheet as String,
            kUTTypePDF as String,
            "com.microsoft.word.doc",
            "com.microsoft.excel.xls",
        ]
        let importMenu = UIDocumentPickerViewController(documentTypes: types, in: .import)
        importMenu.delegate = self
        importMenu.modalPresentationStyle = .formSheet
        controller.present(importMenu, animated: true)
    }
}

extension ALKDocumentManager: UIDocumentPickerDelegate, UINavigationControllerDelegate {
    func documentPicker(_: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        print("Documents selected: \(urls.description)")
        let url = urls[0]
        let isSecuredURL = url.startAccessingSecurityScopedResource() == true
        let coordinator = NSFileCoordinator()
        var error: NSError?
        coordinator.coordinate(
            readingItemAt: url,
            options: [NSFileCoordinator.ReadingOptions.forUploading],
            error: &error
        ) { readableFileURL in
            let fileName = readableFileURL.lastPathComponent
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let uniqueFileName = "\(Int(Date().timeIntervalSince1970 * 1000))-\(fileName)"
            let newFileURL = documentsURL.appendingPathComponent(uniqueFileName)
            do {
                if FileManager.default.fileExists(atPath: newFileURL.path) {
                    try FileManager.default.removeItem(atPath: newFileURL.path)
                }
                try FileManager.default.moveItem(atPath: readableFileURL.path, toPath: newFileURL.path)
            } catch {
                print(error)
            }
            if isSecuredURL {
                url.stopAccessingSecurityScopedResource()
            }
            delegate?.documentSelected(at: newFileURL, fileName: fileName)
        }
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
