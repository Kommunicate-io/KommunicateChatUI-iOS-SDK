//
//  KMFormTemplate.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by Mukesh on 08/07/20.
//

import Foundation

struct KMFormTemplate: Decodable {
    var elements: [Element]

    struct Element: Decodable {
        let type: String
        let data: Details?
        let options: [Option]?
        let title, name, label, value, placeholder: String?
        let formAction, message, requestType, postFormDataAsMessage: String?
        var postBackToKommunicate: Bool?
        var metadata: [String: String]?
    }

    struct Details: Decodable {
        let label, placeholder, name, value, title, type: String?
        let action: Action?
        let options: [Option]?
        let validation: Validation?
    }

    struct Option: Decodable {
        let label: String
        let value: String?
        let selected, disabled: Bool?
    }

    struct Action: Decodable {
        let formAction, message, requestType: String?, postFormDataAsMessage: String?
        var metadata: [String: String]?
    }

    struct Validation: Decodable {
        let regex, errorText: String?
    }
}

extension KMFormTemplate {
    init(payload: [[String: Any]]) throws {
        let json = try JSONSerialization.data(withJSONObject: payload)
        let elements = try JSONDecoder().decode([KMFormTemplate.Element].self, from: json)
        self = KMFormTemplate(elements: elements)
    }
}

extension KMFormTemplate.Element {
    enum ContentType: String {
        case text
        case textarea
        case password
        case multiselect = "checkbox"
        case singleSelect = "radio"
        case hidden
        case submit
        case date
        case time
        case dateTimeLocal = "datetime-local"
        case dropdown
        case unknown
    }

    var contentType: ContentType {
        return ContentType(rawValue: type) ?? .unknown
    }
}
