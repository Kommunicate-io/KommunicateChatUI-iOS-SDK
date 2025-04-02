//
//  ALKFormDataCache.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by Sunil on 20/07/20.
//

import Foundation
/// `ALKFormDataCache`class will be used for form data cache
public class ALKFormDataCache {
    public static let shared = ALKFormDataCache()
    private let cache = NSCache<NSString, FormDataSubmit>()
    private let userDefaultsKeyPrefix = "KOMMUNICATE_FormDataCache_"

    private init() {
        cache.name = "FormDataCache"
    }

    func set(_ formDataSubmit: FormDataSubmit, for key: String) {
        let cacheKey = key as NSString
        cache.setObject(formDataSubmit, forKey: cacheKey)
        
        // Persist to UserDefaults
        if let encodedData = try? JSONEncoder().encode(formDataSubmit) {
            UserDefaults.standard.set(encodedData, forKey: userDefaultsKeyPrefix + key)
        }
    }

    func getFormData(for key: String) -> FormDataSubmit? {
        let cacheKey = key as NSString
        
        // Check in-memory cache first
        if let cachedData = cache.object(forKey: cacheKey) {
            return cachedData
        }
        
        // Fetch from UserDefaults
        if let savedData = UserDefaults.standard.data(forKey: userDefaultsKeyPrefix + key),
           let decodedData = try? JSONDecoder().decode(FormDataSubmit.self, from: savedData) {
            cache.setObject(decodedData, forKey: cacheKey) // Store in cache for faster access next time
            return decodedData
        }
        
        return nil
    }

    func getFormDataWithDefaultObject(for key: String) -> FormDataSubmit {
        return getFormData(for: key) ?? FormDataSubmit()
    }
    
    /// Clears both in-memory and persistent cache
    public func clearCache() {
        cache.removeAllObjects() // Clear in-memory cache
            
        let userDefaults = UserDefaults.standard
        let allKeys = userDefaults.dictionaryRepresentation().keys
            
        // Remove only keys related to FormDataCache
        for key in allKeys where key.hasPrefix(userDefaultsKeyPrefix) {
            userDefaults.removeObject(forKey: key)
        }
            
        userDefaults.synchronize() // Ensure changes are applied
    }
}
