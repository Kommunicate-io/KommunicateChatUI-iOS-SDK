//
//  KMChatContextTitleViewModel.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by Mukesh Thawani on 05/12/17.
//

import KommunicateCore_iOS_SDK

public protocol KMChatContextTitleDataType {
    var titleText: String { get }
    var subtitleText: String { get }
    var imageURL: URL? { get }
    var infoLabel1Text: String? { get }
    var infoLabel2Text: String? { get }
}

public protocol KMChatContextTitleViewModelType {
    var contextViewData: KMChatContextTitleDataType { get set }
    var getTitleImageURL: URL? { get }
    var getTitleText: String? { get }
    var getSubtitleText: String? { get }
    var getFirstKeyValuePairText: String? { get }
    var getSecondKeyValuePairText: String? { get }
}

open class KMChatContextTitleViewModel: KMChatContextTitleViewModelType {
    public var contextViewData: KMChatContextTitleDataType

    public var getTitleImageURL: URL? {
        guard let imageURL = contextViewData.imageURL else {
            return nil
        }
        return imageURL
    }

    public var getTitleText: String? {
        return contextViewData.titleText
    }

    public var getSubtitleText: String? {
        return contextViewData.subtitleText
    }

    public var getFirstKeyValuePairText: String? {
        return contextViewData.infoLabel1Text
    }

    public var getSecondKeyValuePairText: String? {
        return contextViewData.infoLabel2Text
    }

    public init(data: KMChatContextTitleDataType) {
        contextViewData = data
    }
}
