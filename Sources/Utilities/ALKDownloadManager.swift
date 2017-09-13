//
//  ALKDownloadManager.swift
//  ApplozicSwift
//
//  Created by Mukesh Thawani on 04/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import Foundation
import Applozic

protocol ALKDownloadManagerDelegate: class {
    func dataUpdated(countCompletion: Int64)
    func dataFinished(path: String)
    func dataUploaded(responseDictionary: Any?)
}

class ALKDownloadManager: NSObject {
    static let shared = ALKDownloadManager()
    weak var delegate: ALKDownloadManagerDelegate?

    var length: Int64 = 0
    var buffer:NSMutableData = NSMutableData()
    var session:URLSession?
    var messageModel: ALKMessageViewModel?
    
    func downloadAndSaveAudio(message: ALMessage, completion: @escaping (_ path: String?) ->()) {
        let urlStr = String(format: "%@/rest/ws/aws/file/%@",ALUserDefaultsHandler.getFILEURL(),message.fileMeta.blobKey)
        let componentsArray = message.fileMeta.name.components(separatedBy: ".")
        let fileExtension = componentsArray.last
        let filePath = String(format: "%@_local.%@", message.key, fileExtension!)
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent(filePath)
        guard NSData(contentsOfFile: fileURL.path) == nil else {
            completion(filePath)
            return
        }
        guard let url = URL(string: urlStr) else {
            completion(nil)
            return
        }
        URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in

            if error == nil, let _ = response?.url?.path, let data = data, let _ = self.save(data: data, to: fileURL){
                completion(filePath)
            } else {
                print(error ?? "")
                completion(nil)
            }
        }).resume()
    }

    func uploadImage(message: ALMessage, uploadURL: String, completion:@escaping (_ response: Any?)->()) {
        let docDirPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        guard let imageFilePath = message.imageFilePath else { return }
        let filePath = docDirPath.appendingPathComponent(imageFilePath)
        
        guard var request = ALRequestHandler.createPOSTRequest(withUrlString: uploadURL, paramString: nil) as URLRequest? else { return }
        if FileManager.default.fileExists(atPath: filePath.path) {
            
            let boundary = "------ApplogicBoundary4QuqLuM1cE5lMwCy"
            let contentType = String(format: "multipart/form-data; boundary=%@", boundary)
            request.setValue(contentType, forHTTPHeaderField: "Content-Type")
            var body = Data()

            _ = [String: String]()

            let fileParamConstant = "files[]"
            let imageData = NSData(contentsOfFile: filePath.path)
            
            if let data = imageData as Data? {
                print("data present")
                body.append(String(format: "--%@\r\n", boundary).data(using: .utf8)!)
                body.append(String(format: "Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", fileParamConstant,message.fileMeta.name).data(using: .utf8)!)
                body.append(String(format: "Content-Type:%@\r\n\r\n", message.fileMeta.contentType).data(using: .utf8)!)
                body.append(data)
                body.append(String(format: "\r\n").data(using: .utf8)!)
            }
            
            body.append(String(format: "--%@--\r\n", boundary).data(using: .utf8)!)
            request.httpBody = body
            request.url = URL(string: uploadURL)
            
            let task = URLSession.shared.dataTask(with: request) {
                data, response, error in
                do {
                    let responseDictionary = try JSONSerialization.jsonObject(with: data!)
                    print("success == \(responseDictionary)")
                    completion(responseDictionary)
                } catch {
                    print(error)
                    
                    let responseString = String(data: data!, encoding: .utf8)
                    print("responseString = \(responseString)")
                    completion(nil)
                }
            }
            task.resume()
        }
    }

    func upload(image: UIImage, uploadURL: URL, completion: @escaping (_ imageLink: Data?)->()) {

        guard var request = ALRequestHandler.createPOSTRequest(withUrlString: uploadURL.path, paramString: nil) as URLRequest? else { return }
//        if FileManager.default.fileExists(atPath: filePath.path) {

        let boundary = "------ApplogicBoundary4QuqLuM1cE5lMwCy"
        let contentType = String(format: "multipart/form-data; boundary=%@", boundary)
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        var body = Data()

//            let parameters = [String: String]()

        let fileParamConstant = "file"
        let imageData = UIImagePNGRepresentation(image)

        if let data = imageData as Data? {
            print("data present")
            body.append(String(format: "--%@\r\n", boundary).data(using: .utf8)!)
            body.append(String(format: "Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", fileParamConstant,"imge_123_profile").data(using: .utf8)!)
            body.append(String(format: "Content-Type:%@\r\n\r\n", "image/jpeg").data(using: .utf8)!)
            body.append(data)
            body.append(String(format: "\r\n").data(using: .utf8)!)
        }

        body.append(String(format: "--%@--\r\n", boundary).data(using: .utf8)!)
        request.httpBody = body
        request.url = uploadURL

        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            if error == nil {
                completion(data)
            } else {
                completion(nil)
            }
        }
        task.resume()
    }

    func downloadVideo(message: ALKMessageViewModel) ->() {
        self.messageModel = message
        guard let fileMeta = message.fileMetaInfo else { return }
        let urlStr = String(format: "%@/rest/ws/aws/file/%@",ALUserDefaultsHandler.getFILEURL(),fileMeta.blobKey)

        let componentsArray = fileMeta.name.components(separatedBy: ".")
        let fileExtension = componentsArray.last
        let filePath = String(format: "%@_local.%@", message.identifier, fileExtension!)
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

        if NSData(contentsOfFile: (documentsURL.appendingPathComponent(filePath)).path) != nil {
            delegate?.dataFinished(path: filePath)
        } else {
            let configuration = URLSessionConfiguration.default
            session = URLSession(configuration: configuration, delegate:self, delegateQueue: nil)
            let dataTask = session?.dataTask(with: URLRequest(url: URL(string: urlStr)!))
            dataTask?.resume()
        }
    }

    func uploadVideo(message: ALMessage, databaseObj: DB_FileMetaInfo, uploadURL: String) {
        let docDirPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let timeStamp = message.imageFilePath
        let filePath = docDirPath.appendingPathComponent(timeStamp!)

        guard var request = ALRequestHandler.createPOSTRequest(withUrlString: uploadURL, paramString: nil) as URLRequest? else { return }
        if FileManager.default.fileExists(atPath: filePath.path) {

            let boundary = "------ApplogicBoundary4QuqLuM1cE5lMwCy"
            let contentType = String(format: "multipart/form-data; boundary=%@", boundary)
            request.setValue(contentType, forHTTPHeaderField: "Content-Type")
            var body = Data()

            let parameters = [String: String]()

            let fileParamConstant = "files[]"
            let imageData = NSData(contentsOfFile: filePath.path)

            if let data = imageData as Data? {
                print("data present")
                body.append(String(format: "--%@\r\n", boundary).data(using: .utf8)!)
                body.append(String(format: "Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", fileParamConstant,message.fileMeta.name).data(using: .utf8)!)
                body.append(String(format: "Content-Type:%@\r\n\r\n", message.fileMeta.contentType).data(using: .utf8)!)
                body.append(data)
                body.append(String(format: "\r\n").data(using: .utf8)!)
            }

            body.append(String(format: "--%@--\r\n", boundary).data(using: .utf8)!)
            request.httpBody = body
            request.url = URL(string: uploadURL)
            let configuration = URLSessionConfiguration.default
            session = URLSession(configuration: configuration, delegate:self, delegateQueue: nil)
            let dataTask = session?.dataTask(with: request)
            dataTask?.resume()
        }
    }

    private func save(data: Data,to url: URL) -> String? {
        do {
            try data.write(to: url)
            return url.path
        } catch let error {
            print(error)
            return nil
        }
    }
}

extension ALKDownloadManager: URLSessionDataDelegate  {

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Swift.Void) {
        completionHandler(URLSession.ResponseDisposition.allow)
    }


    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        if messageModel != nil {
            buffer.append(data)
            DispatchQueue.main.async {
                self.delegate?.dataUpdated(countCompletion: Int64(self.buffer.length))
            }
        } else {
            guard let response = dataTask.response as? HTTPURLResponse, response.statusCode == 200 else {
                NSLog("UPLOAD ERROR: %@", dataTask.error.debugDescription)
                return
            }
            do {
                let responseDictionary = try JSONSerialization.jsonObject(with: data)
                print("success == \(responseDictionary)")

                DispatchQueue.main.async {
                    self.delegate?.dataUploaded(responseDictionary: responseDictionary)
                }
            } catch {
                print(error)
                let responseString = String(data: data, encoding: .utf8)
                print("responseString = \(responseString)")

                DispatchQueue.main.async {
                    self.delegate?.dataUploaded(responseDictionary: nil)
                }
            }   
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if messageModel == nil {
//            guard error == nil else {
//                DispatchQueue.main.async {
//                self.delegate?.dataUploaded(responseDictionary: nil)
//                }
//                return
//            }
//            guard let response = task.response as? HTTPURLResponse, response.statusCode == 200 else { return }

        }  else {

            guard error == nil else {
                DispatchQueue.main.async {
                    self.delegate?.dataFinished(path: "")
                }
                return
            }
            guard let fileMeta = messageModel?.fileMetaInfo else { return }
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let componentsArray = fileMeta.name.components(separatedBy: ".")
            let fileExtension = componentsArray.last
            let filePath = String(format: "%@_local.%@", (messageModel?.identifier)!, fileExtension!)
            let path = documentsURL.appendingPathComponent(filePath).path
            buffer.write(toFile: path, atomically: true)
            DispatchQueue.main.async {
                self.delegate?.dataFinished(path: filePath)
            }
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        length += totalBytesSent
        DispatchQueue.main.async {
            self.delegate?.dataUpdated(countCompletion: self.length)
        }
    }
}
