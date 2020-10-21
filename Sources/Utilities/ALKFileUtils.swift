//
//  ALKFileUtils.swift
//  ApplozicSwift
//
//  Created by Sunil on 14/03/19.
//

import Applozic
import Foundation

class ALKFileUtils: NSObject {
    func getFileName(filePath: String?, fileMeta: ALFileMetaInfo?) -> String {
        guard let fileMetaInfo = fileMeta, let fileName = fileMetaInfo.name else {
            guard let localPathName = filePath else {
                return ""
            }
            return (localPathName as NSString).lastPathComponent as String
        }
        return fileName
    }

    func getFileSize(filePath: String?, fileMetaInfo: ALFileMetaInfo?) -> String? {
        guard let fileName = filePath else {
            return fileMetaInfo?.getTheSize()
        }

        let filePath = getDocumentDirectory(fileName: fileName).path

        guard let size = ((try? FileManager.default.attributesOfItem(atPath: filePath)[FileAttributeKey.size]) as Any??), let fileSize = size as? UInt64
        else {
            return ""
        }
        var floatSize = Float(fileSize / 1024)
        if floatSize < 1023 {
            return String(format: "%.1f KB", floatSize)
        }

        floatSize /= 1024
        if floatSize < 1023 {
            return String(format: "%.1f MB", floatSize)
        }

        floatSize /= 1024
        return String(format: "%.1f GB", floatSize)
    }

    func getFileExtenion(filePath: String?, fileMeta: ALFileMetaInfo?) -> String {
        guard let localPathName = filePath else {
            guard let fileMetaInfo = fileMeta, let name = fileMetaInfo.name, let pathExtension = URL(string: name)?.pathExtension else {
                return ""
            }
            return pathExtension
        }
        return getDocumentDirectory(fileName: localPathName).pathExtension
    }

    func getDocumentDirectory(fileName: String) -> URL {
        let docDirPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docDirPath.appendingPathComponent(fileName)
    }

    func getThumbnail(filePath: URL) -> UIImage? {
        do {
            let asset = AVURLAsset(url: filePath, options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            return UIImage(cgImage: cgImage)

        } catch {
            print("*** Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }

    func moveFileToDocuments(fileURL: URL) -> URL? {
        let fileName = fileURL.lastPathComponent
        let uniqueFileName = "\(Int(Date().timeIntervalSince1970 * 1000))-\(fileName)"
        let newFileURL = getDocumentDirectory(fileName: uniqueFileName)
        do {
            if FileManager.default.fileExists(atPath: newFileURL.path) {
                try FileManager.default.removeItem(atPath: newFileURL.path)
            }
            try FileManager.default.moveItem(atPath: fileURL.path, toPath: newFileURL.path)
            return newFileURL
        } catch {
            print("Failed to export video due to error: \(error)")
            return nil
        }
    }
}
