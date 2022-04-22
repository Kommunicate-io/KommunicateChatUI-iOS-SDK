//
//  KMCellConfiguration.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by sathyan elangovan on 22/04/22.
//

import Foundation

public struct KMCellConfiguration {
    public static let shared = KMCellConfiguration()
    /// if true then incoming messsage's sender name will be hidden on conversation
    public var hideSenderName: Bool = false
    
    private init(){
        print("KmCellConfiguration instantiated")
    }
    
}
