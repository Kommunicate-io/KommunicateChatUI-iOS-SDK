//
//  Localization.swift
//  ApplozicSwift
//
//  Created by Shivam Pokhriyal on 04/10/18.
//

import Foundation

class Localization {
    
    class func localizedString(forKey: String) -> String {
        // ApplozicSwift bundle
        let bundle = Bundle.applozic
        
        return NSLocalizedString(forKey, tableName: nil, bundle: bundle, value: "", comment: "")
    }
    
}
