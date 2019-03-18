//
//  ALKFileUtils.swift
//  ApplozicSwift
//
//  Created by Sunil on 14/03/19.
//

import Foundation

class ALKFileUtils: NSObject{

    func getFileName(viewModel: ALKMessageViewModel) -> String {
        guard let fileName = viewModel.fileMetaInfo?.name else {
            return  (viewModel.filePath! as NSString).lastPathComponent as String
        }
        return fileName
    }

    public func getFileSize(viewModel: ALKMessageViewModel) -> String? {

        guard  let fileName = viewModel.filePath else {
            return viewModel.fileMetaInfo?.getTheSize()
        }

        let filePath = self.getDocumentDirectory(fileName: fileName).path

        guard  let size = try? FileManager.default.attributesOfItem(atPath:filePath )[FileAttributeKey.size], let fileSize = size as? UInt64
            else {
                return ""
        }
        var floatSize = Float(fileSize / 1024)
        if floatSize < 1023 {
            return String(format: "%.1f KB", floatSize)
        }

        floatSize = floatSize / 1024
        if floatSize < 1023 {
            return String(format: "%.1f MB", floatSize)
        }

        floatSize = floatSize / 1024
        return String(format: "%.1f GB", floatSize)
    }

    func getFileExtenion(viewModel: ALKMessageViewModel) -> String {

        guard let fileName = viewModel.filePath else {
            guard let name =  viewModel.fileMetaInfo?.name,let pathExtension = URL(string: name)?.pathExtension else {
                return ""
            }
            return pathExtension
        }

       return self.getDocumentDirectory(fileName: fileName).pathExtension
    }

    func getDocumentDirectory(fileName:String) -> URL {
        let docDirPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docDirPath.appendingPathComponent(fileName)
    }

    func isSupportedFileType(viewModel: ALKMessageViewModel) -> Bool{
        guard (viewModel.filePath) != nil else {
                return false
        }

        let pathExtension = self.getDocumentDirectory(fileName: viewModel.filePath ?? "").pathExtension
        let fileTypes = ["docx", "pdf", "doc", "java", "js","txt","html","xlsx","xls"]
        return  fileTypes.contains(pathExtension)
    }

}
