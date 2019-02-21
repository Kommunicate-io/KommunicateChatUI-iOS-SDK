//
//  CardTemplateModel.swift
//  ApplozicSwift
//
//  Created by Shivam Pokhriyal on 19/02/19.
//

import Foundation

public struct CardTemplateModel: Codable {
    public let title: String
    public let titleExt: String?
    public let subtitle: String
    public let description: String?
    public let header: Header?
    public let buttons: [Button]?

    public struct Header: Codable {
        public let imgSrc: String?
        public let overlayText: String?
    }

    public struct Button: Codable {
        public let name: String
        public let action: CardTemplateModel.Action
    }

    public struct Action: Codable {
        public let type: String
        public let payload: CardTemplateModel.Payload
    }

    public struct Payload: Codable {
        public let url: String?
        public let title: String?
        public let message: String?
        public let text: String?
        public let formAction: String?
        public let requestType: String?
        public let formData: CardTemplateModel.FormData?
    }

    public struct FormData: Codable {
        public let amount: String?
        public let description: String?
    }
}

public class Util {

    public func cardTemplate(from genericCard: ALKGenericCard) -> CardTemplateModel {
        let header = CardTemplateModel.Header(imgSrc: genericCard.imageUrl?.absoluteString, overlayText: genericCard.overlayText)

        var buttons: [CardTemplateModel.Button]?
        if let cardButtons = genericCard.buttons {
            buttons = [CardTemplateModel.Button]()
            for btn in cardButtons {
                let payload = CardTemplateModel.Payload(url: nil, title: btn.name, message: btn.action, text: btn.data, formAction: nil, requestType: nil, formData: nil)
                let action = CardTemplateModel.Action(type: "ALKGenericCard", payload: payload)
                let button = CardTemplateModel.Button(name: btn.name, action: action)
                buttons!.append(button)
            }
        }

        let template = CardTemplateModel(title: genericCard.title, titleExt: String(describing: genericCard.rating), subtitle: genericCard.subtitle, description: genericCard.description, header: header, buttons: buttons)
        return template
    }
}
