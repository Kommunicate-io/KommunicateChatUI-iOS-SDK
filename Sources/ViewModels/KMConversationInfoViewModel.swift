//
//  KMConversationInfoViewModel.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by sathyan elangovan on 16/03/23.
//

import Foundation

class KMConversationInfoViewModel {
    
    var infoContent: String
    var leadingImage: UIImage
    var trailingImage: UIImage
    var backgroundColor: UIColor
    var contentColor: UIColor
    var contentFont: Font
    
    init(infoContent: String, leadingImage: UIImage, trailingImage: UIImage, backgroundColor: UIColor, contentColor: UIColor, contentFont: Font) {
        self.infoContent = infoContent
        self.leadingImage = leadingImage
        self.trailingImage = trailingImage
        self.backgroundColor = backgroundColor
        self.contentColor = contentColor
        self.contentFont = contentFont
    }
}
