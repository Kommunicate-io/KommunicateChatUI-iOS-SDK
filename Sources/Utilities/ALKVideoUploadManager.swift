//
//  ALKUploadManager.swift
//  ApplozicSwift
//
//  Created by Sunil on 12/05/21.
//

import ApplozicCore
import Foundation

class ALKVideoUploadManager: NSObject {
    weak var uploadDelegate: ALKHTTPManagerUploadDelegate?
    var uploadTask: ALKUploadTask?
    var session: URLSession?
    var uploadCompleted: ((_ responseDict: Any?, _ task: ALKUploadTask) -> Void)?

    enum Constants {
        static let paramForS3Storage = "file"
        static let paramForDefaultStorage = "files[]"
    }

    func uploadVideo(alMessage: ALMessage) {
        let messageService = ALMessageDBService()
        let responseHandler = ALResponseHandler()
        guard let dbMessage = messageService.getMessageByKey("key", value: alMessage.key) as? DB_Message else {
            return
        }
        let clientService = ALMessageClientService()
        // If already thumbnail is uploaded we will directly upload the video else will upload thumbnail on success will upload the video.
        if let thumbnailUrl = dbMessage.fileMetaInfo.thumbnailUrl,
           !thumbnailUrl.isEmpty
        {
            clientService.sendPhoto(forUserInfo: alMessage.dictionary(), withCompletion: {
                urlStr, error in
                guard error == nil, let urlStr = urlStr,
                      let url = URL(string: urlStr),
                      let fileName = alMessage.fileMeta.name,
                      let contentType = alMessage.fileMeta.contentType,
                      let filePath = alMessage.imageFilePath else { return }

                let task = ALKUploadTask(url: url, fileName: fileName)
                task.identifier = alMessage.key
                task.contentType = contentType
                task.filePath = filePath

                let downloadManager = ALKHTTPManager()
                downloadManager.uploadDelegate = self.uploadDelegate
                downloadManager.uploadAttachment(task: task)
                downloadManager.uploadCompleted = self.uploadCompleted
            })

        } else {
            clientService.sendPhoto(forUserInfo: alMessage.dictionary(), withCompletion: {
                urlStr, error in
                guard error == nil,
                      let urlStr = urlStr,
                      let url = URL(string: urlStr)
                else {
                    print("Error in uploading thumbnail image %@", error.debugDescription)
                    return
                }

                let fileUtills = ALKFileUtils()
                let docsFilePath = fileUtills.getDocumentDirectory(fileName: alMessage.imageFilePath)
                let thumbnailImage = fileUtills.getThumbnail(filePath: docsFilePath)
                guard let image = thumbnailImage,
                      let path = fileUtills.saveImageToDocDirectory(image: image)
                else {
                    return
                }
                let filePath = URL(fileURLWithPath: path)

                let task = ALKUploadTask(url: url, fileName: alMessage.fileMeta.name)
                task.identifier = alMessage.identifier
                task.contentType = alMessage.fileMeta.contentType
                task.filePath = alMessage.imageFilePath
                task.thumbnailPath = filePath.lastPathComponent
                self.uploadTask = task

                guard let postURLRequest = ALRequestHandler.createPOSTRequest(withUrlString: task.url?.description, paramString: nil) as NSMutableURLRequest? else { return }

                responseHandler.authenticateRequest(postURLRequest) { [weak self] urlRequest, error in
                    guard let weakSelf = self,
                          error == nil,
                          var request = urlRequest as URLRequest?
                    else {
                        print("Failed to upload the attachment")
                        return
                    }

                    if FileManager.default.fileExists(atPath: filePath.path) {
                        request = weakSelf.getURLRequestWithFilePath(path: filePath.path, request: request)
                        let configuration = URLSessionConfiguration.default
                        weakSelf.session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
                        let dataTask = weakSelf.session?.dataTask(with: request)
                        dataTask?.resume()
                    }
                }

            })
        }

        print("Video content type: ", alMessage.fileMeta.contentType ?? "")
        print("Video file path: ", alMessage.imageFilePath ?? "")
    }

    func getURLRequestWithFilePath(path: String, request: URLRequest) -> URLRequest {
        var urlRequest = request
        let boundary = "------ApplogicBoundary4QuqLuM1cE5lMwCy"
        let contentType = String(format: "multipart/form-data; boundary=%@", boundary)
        urlRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
        var body = Data()
        let fileParamConstant = ALApplozicSettings.isS3StorageServiceEnabled() ? Constants.paramForS3Storage : Constants.paramForDefaultStorage
        let imageData = NSData(contentsOfFile: path)

        if let data = imageData as Data? {
            print("data present")
            body.append(String(format: "--%@\r\n", boundary).data(using: .utf8)!)
            body.append(String(format: "Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", fileParamConstant, uploadTask?.thumbnailPath ?? "").data(using: .utf8)!)
            body.append(String(format: "Content-Type:%@\r\n\r\n", "image/jpeg").data(using: .utf8)!)
            body.append(data)
            body.append(String(format: "\r\n").data(using: .utf8)!)
        }

        body.append(String(format: "--%@--\r\n", boundary).data(using: .utf8)!)
        urlRequest.httpBody = body
        urlRequest.url = uploadTask?.url
        return urlRequest
    }

    func updateImageFileMeta(messageKey: String?, responseDict: Any?) -> ALMessage? {
        guard let key = messageKey else {
            return nil
        }

        let messageService = ALMessageDBService()
        let alHandler = ALDBHandler.sharedInstance()
        guard let dbMessage = messageService.getMessageByKey("key", value: key) as? DB_Message,
              let message = messageService.createMessageEntity(dbMessage) else { return nil }

        guard let fileInfo = responseDict as? [String: Any] else { return nil }

        let newMessage = ALMessage()
        let imageFileMeta = ALFileMetaInfo()
        newMessage.fileMeta = imageFileMeta

        if ALApplozicSettings.isS3StorageServiceEnabled() {
            newMessage.fileMeta.populate(fileInfo)
        } else {
            guard let fileMeta = fileInfo["fileMeta"] as? [String: Any] else { return nil }
            newMessage.fileMeta.populate(fileMeta)
        }

        dbMessage.fileMetaInfo.thumbnailUrl = newMessage.fileMeta.thumbnailUrl
        dbMessage.fileMetaInfo.thumbnailBlobKeyString = newMessage.fileMeta.blobKey

        message.fileMeta.thumbnailUrl = newMessage.fileMeta.thumbnailUrl
        message.fileMeta.thumbnailBlobKey = newMessage.fileMeta.blobKey

        let error = alHandler?.saveContext()
        if error != nil {
            print("Not saved due to error \(String(describing: error))")
            return nil
        }
        return message
    }
}

extension ALKVideoUploadManager: URLSessionDataDelegate {
    func urlSession(_: URLSession, dataTask _: URLSessionDataTask, didReceive _: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Swift.Void) {
        completionHandler(URLSession.ResponseDisposition.allow)
    }

    func urlSession(_: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let response = dataTask.response as? HTTPURLResponse, response.statusCode == 200 else {
            print("UPLOAD ERROR: %@", dataTask.error.debugDescription)
            return
        }
        guard let uploadTask = self.uploadTask else { return }
        do {
            let responseDictionary = try JSONSerialization.jsonObject(with: data)
            print("success == \(responseDictionary)")

            DispatchQueue.main.async {
                uploadTask.completed = true
                let alMessage = self.updateImageFileMeta(messageKey: uploadTask.identifier, responseDict: responseDictionary)

                let clientService = ALMessageClientService()
                clientService.sendPhoto(forUserInfo: nil, withCompletion: {
                    urlStr, error in
                    guard error == nil, let urlStr = urlStr,
                          let url = URL(string: urlStr),
                          let fileName = alMessage?.fileMeta.name,
                          let contentType = alMessage?.fileMeta.contentType,
                          let filePath = alMessage?.imageFilePath else { return }

                    let task = ALKUploadTask(url: url, fileName: fileName)
                    task.identifier = alMessage?.key
                    task.contentType = contentType
                    task.filePath = filePath

                    let downloadManager = ALKHTTPManager()
                    downloadManager.uploadDelegate = self.uploadDelegate
                    downloadManager.uploadAttachment(task: task)
                    downloadManager.uploadCompleted = self.uploadCompleted
                })
            }
        } catch {
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(String(describing: responseString))")
            DispatchQueue.main.async {
                uploadTask.uploadError = error
                uploadTask.completed = true
                self.uploadCompleted?(nil, uploadTask)
                self.uploadDelegate?.dataUploadingFinished(task: uploadTask)
            }
        }
    }
}
