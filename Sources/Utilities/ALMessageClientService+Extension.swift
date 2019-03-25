//
//  ALMessageClientService+Extension.swift
//  ApplozicSwift
//
//  Created by Shivam Pokhriyal on 25/03/19.
//

import Applozic

extension ALMessageClientService {

    private func getURLRequestForThumbnail(using blobKey: String ) -> NSMutableURLRequest? {
        guard let baseUrl = ALUserDefaultsHandler.getFILEURL() else { return nil }
        if ALApplozicSettings.isGoogleCloudServiceEnabled() {
            let theUrlString = "\(baseUrl)/files/url"
            let blobParamString = "key=\(blobKey)"
            return ALRequestHandler.createGETRequest(withUrlString: theUrlString, paramString: blobParamString)
        } else if ALApplozicSettings.isS3StorageServiceEnabled() {
            let theUrlString = "\(baseUrl)/rest/ws/file/url"
            let blobParamString = "key=\(blobKey)"
            return ALRequestHandler.createGETRequest(withUrlString: theUrlString, paramString: blobParamString)
        } else {
            return nil
        }
    }

    func getImageThumbnailUrl(using blobKey: String,
                              and url: String,
                              with completion: @escaping (String?, Error?) -> ()) {
        guard let urlRequest = getURLRequestForThumbnail(using: blobKey) else {
            completion(url, nil)
            return
        }
        ALResponseHandler.processRequest(urlRequest, andTag: "THUMBNAIL DOWNLOAD URL", withCompletionHandler: { json, error in
            guard error == nil, let url = json as? String else {
                completion(nil, error)
                return
            }
            completion(url, nil)
        })
    }

}
