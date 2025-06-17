//
//  KMChatAPIRequest.swift
//
//
//  Created by Mukesh Thawani on 04/05/17.
//

// import Foundation
// import Alamofire
// import ObjectMapper

// enum KMChatAPIRequestType {
//    case get
//    case post
//    case delete
//    case put
//
//    func methodOfAlamofire() -> Alamofire.HTTPMethod {
//        switch self {
//            case .get: return Alamofire.HTTPMethod.get
//            case .post: return Alamofire.HTTPMethod.post
//            case .delete: return Alamofire.HTTPMethod.delete
//            case .put: return Alamofire.HTTPMethod.put
//        }
//    }
// }
//
// enum KMChatAPIParameterType {
//    case url
//    case urlEncodedInURL
//    case json
// }
//
// class KMChatAPIRequest {
//    // MARK: - Variables and Types
//    // MARK: Protected
//
//    var methodType: KMChatAPIRequestType = .get
//
//    var type: KMChatAPIRequestType {
//        return self.methodType
//    }
//
//    var paramsType: KMChatAPIParameterType {
//        switch self.type {
//        case .post, .put, .delete:
//            return .json
//
//        case .get:
//            return .url
//        }
//    }
//
//    var url: String {
//        return ""
//    }
//
//    var params: [String: Any]? {
//        return nil
//    }
//
//    var headers: [String: String]? {
//        return nil
//    }
//
//    var responseKeyPath: String {
//        return ""
//    }
// }
