//
//  FormTemplate.swift
//  ApplozicSwift
//
//  Created by Mukesh on 08/07/20.
//

import Foundation

struct FormTemplate: Decodable {
    let elements: [Element]

    struct Element: Decodable {
        let type: String
        let data: Details?
    }

    struct Details: Decodable {
        let label, placeholder, name, value, title, type: String?
        let action: Action?
        let options: [Option]?
        let validation: Validation?
    }

    struct Option: Decodable {
        let label, value: String
    }

    struct Action: Decodable {
        let formAction, message, requestType: String?,postFormDataAsMessage: String?
    }

    struct Validation: Decodable {
        let regex, errorText: String?
    }
}

extension FormTemplate {
    init(payload: [[String: Any]]) throws {
        let json = try JSONSerialization.data(withJSONObject: payload)
        let elements = try JSONDecoder().decode([FormTemplate.Element].self, from: json)
        self = FormTemplate(elements: elements)
    }
}

extension FormTemplate.Element {
    enum ContentType: String {
        case text
        case password
        case multiselect = "checkbox"
        case singleSelect = "radio"
        case hidden
        case submit
        case date
        case time
        case dateTimeLocal = "datetime-local"
        case unknown
    }

    var contentType: ContentType {
        return ContentType(rawValue: type) ?? .unknown
    }
}
