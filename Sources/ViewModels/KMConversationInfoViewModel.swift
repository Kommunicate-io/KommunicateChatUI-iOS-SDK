//
//  KMConversationInfoViewModel.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by sathyan elangovan on 16/03/23.
//

import Foundation
import UIKit

public class KMConversationInfoViewModel {
    
    var infoContent: String
    var leadingImage: UIImage
    var trailingImage: UIImage
    var backgroundColor: UIColor
    var contentColor: UIColor
    var contentFont: UIFont?
    var darkBackgroundColor: UIColor
    var contentDarkColor: UIColor
    
    public init(infoContent: String, leadingImage: UIImage, trailingImage: UIImage, backgroundColor: UIColor, contentColor: UIColor, contentFont: UIFont, darkBackgroundColor: UIColor = .clear, contentDarkColor: UIColor = .clear) {
        self.infoContent = infoContent
        self.leadingImage = leadingImage
        self.trailingImage = trailingImage
        self.backgroundColor = backgroundColor
        self.contentColor = contentColor
        self.contentFont = contentFont
        if darkBackgroundColor == UIColor.clear {
            self.darkBackgroundColor = backgroundColor
        } else {
            self.darkBackgroundColor = darkBackgroundColor
        }
        if contentDarkColor == UIColor.clear {
            self.contentDarkColor = contentColor
        } else {
            self.contentDarkColor = contentDarkColor
        }
    }
}
