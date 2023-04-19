//
//  KMCellConfiguration.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by sathyan elangovan on 22/04/22.
//

import Foundation
/// - NOTE: Customization for message cells
public enum KMCellConfiguration {
    
    /// if true then incoming messsage's sender name will be hidden on conversation
    public static var hideSenderName = false
    
    public static var staticTopMessage: String = ""
    
    public static var staticTopIcon  = UIImage(named: "ic_lock", in: Bundle.km, compatibleWith: nil)
    
}
