//
//  KMConversationInfoViewModel.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by sathyan elangovan on 16/03/23.
//

import Foundation

public class KMConversationInfoViewModel {
    
    var infoContent: String
    var leadingImage: UIImage
    var trailingImage: UIImage
    var backgroundColor: UIColor
    var contentColor: UIColor
    var contentFont: UIFont?
    
   public init(infoContent: String, leadingImage: UIImage, trailingImage: UIImage, backgroundColor: UIColor, contentColor: UIColor, contentFont: UIFont) {
        self.infoContent = infoContent
        self.leadingImage = leadingImage
        self.trailingImage = trailingImage
        self.backgroundColor = backgroundColor
        self.contentColor = contentColor
        self.contentFont = contentFont
    }
}
