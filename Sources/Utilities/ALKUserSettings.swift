//
//  ALKUserSettings.swift
//  ApplozicSwift
//
//  Created by apple on 18/12/18.
//

import Foundation

public class ALKUserSettings : NSObject{
    
    static let MESSAGE_METADATA = "MESSAGE_METADATA"
    
    public static func setMessageMetaData(_ dictionary: NSMutableDictionary) {
        UserDefaults.standard.set(dictionary, forKey: ALKUserSettings.MESSAGE_METADATA)
        UserDefaults.standard.synchronize()
    }
    
    public static func getMessageMetaData() -> NSDictionary? {
        guard let dictionary = UserDefaults.standard.object(forKey: ALKUserSettings.MESSAGE_METADATA) else {
            return nil
        }
        return dictionary as? NSDictionary
    }
    
}
