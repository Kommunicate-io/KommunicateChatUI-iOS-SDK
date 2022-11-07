//
//  RMCellConfiguration.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by sathyan elangovan on 22/06/22.
//

import Foundation

/// - NOTE: Customization for Rich Message  cells
public enum RMCellConfiguration {
    
    /// if true then incoming messsage's sender name will be hidden on conversation
    public static var hideSenderName = false
   
    /// To show custom bot name in conversation
    public static var customBotName = ""
    
    /// Bot's Id to be customized
    public static var customizedBotId = ""
}
