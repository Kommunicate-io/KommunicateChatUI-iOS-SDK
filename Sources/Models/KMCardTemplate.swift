//
//  KMCardTemplate.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by Shivam Pokhriyal on 19/02/19.
//

import Foundation

public struct KMCardTemplate: Codable {
    public let title: String?
    public let titleExt: String?
    public let subtitle: String?
    public let description: String?
    public let header: Header?
    public var buttons: [Button]?

    public struct Header: Codable {
        public let imgSrc: String?
        public let overlayText: String?
    }

    public struct Button: Codable {
        public let name: String
        public let action: KMCardTemplate.Action?
    }

    public struct Action: Codable {
        public let type: String
        public let payload: KMCardTemplate.Payload?
    }

    public struct Payload: Codable {
        public let url: String?
        public let title: String?
        public let message: String?
        public let text: String?
        public let updateLanguage: String?
        public let formAction: String?
        public let requestType: String?
        public let formData: KMCardTemplate.FormData?
    }

    public struct FormData: Codable {
        public let amount: String?
        public let description: String?
    }
}

public class Util {
    public func cardTemplate(from genericCard: ALKGenericCard) -> KMCardTemplate {
        let header = KMCardTemplate.Header(imgSrc: genericCard.imageUrl?.absoluteString, overlayText: genericCard.overlayText)

        var buttons: [KMCardTemplate.Button]?
        if let cardButtons = genericCard.buttons {
            buttons = [KMCardTemplate.Button]()
            for btn in cardButtons {
                let payload = KMCardTemplate.Payload(url: nil, title: btn.name, message: btn.action, text: btn.data, updateLanguage: nil, formAction: nil, requestType: nil, formData: nil)
                let action = KMCardTemplate.Action(type: "ALKGenericCard", payload: payload)
                let button = KMCardTemplate.Button(name: btn.name, action: action)
                buttons!.append(button)
            }
        }

        let template = KMCardTemplate(
            title: genericCard.title,
            titleExt: String(describing: genericCard.rating),
            subtitle: genericCard.subtitle,
            description: genericCard.description,
            header: header,
            buttons: buttons
        )
        return template
    }
}
