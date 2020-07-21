//
//  ALKFormDataCache.swift
//  ApplozicSwift
//
//  Created by Sunil on 20/07/20.
//

import Foundation
/// `ALKFormDataCache`class will be used for form data cache
class ALKFormDataCache {
    static let shared = ALKFormDataCache()
    private let cache = NSCache<NSString, FormDataSubmit>()

    private init() {
        cache.name = "FormDataCache"
    }

    func set(_ formDataSubmit: FormDataSubmit, for key: String) {
        cache.setObject(formDataSubmit, forKey: key as NSString)
    }

    func getFormData(for key: String) -> FormDataSubmit? {
        guard let formDataSubmit = cache.object(forKey: key as NSString) else {
            return nil
        }
        return formDataSubmit
    }

    func getFormDataWithDefaultObject(for key: String) -> FormDataSubmit {
        guard let formDataSubmit = cache.object(forKey: key as NSString) else {
            return FormDataSubmit()
        }
        return formDataSubmit
    }
}
