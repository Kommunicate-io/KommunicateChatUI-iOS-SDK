//
//  ALKDownloadTask.swift
//  Applozic
//
//  Created by Mukesh Thawani on 08/11/17.
//

import Foundation

class ALKUploadTask {
    let url: URL?
    let completed: Bool = false
    internal var totalBytesUploaded: Int64 = 0
    internal var totalBytesExpectedToUpload: Int64 = 0

    internal var isUploading = false
    public var fileName: String?
    public var contentType: String?
    public var uploadError: Error?
    public var filePath: String?
    public var identifier: String?

    init(url: URL, fileName: String) {
        self.url = url
        self.fileName = fileName
    }
}
