//
//  ALKContextTitleViewModel.swift
//  ApplozicSwift
//
//  Created by Mukesh Thawani on 05/12/17.
//

import Foundation

public protocol ALKContextTitleDataType {
    var titleText: String {get}
    var subtitleText: String {get}
    var imageURL: URL? {get}
    var infoLabel1Text: String? {get}
    var infoLabel2Text: String? {get}
}

public protocol ALKContextTitleViewModelType {
    var contextViewData: ALKContextTitleDataType {get set}

    func getTitleImageURL() -> URL?
}

public class ALKContextTitleViewModel: ALKContextTitleViewModelType {

    public var contextViewData: ALKContextTitleDataType

    public init(data: ALKContextTitleDataType) {
        self.contextViewData = data
    }

    public func getTitleImageURL() -> URL? {
        guard let imageURL = contextViewData.imageURL else {
            return nil
        }
        return imageURL
    }
}
