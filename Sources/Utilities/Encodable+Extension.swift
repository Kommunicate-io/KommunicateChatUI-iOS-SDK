//
//  Encodable+Extension.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by Shivam Pokhriyal on 09/10/19.
//

import Foundation

extension Encodable {
    var dictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
}
