//
//  KMChatFormViewModelItem.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by Mukesh on 08/07/20.
//

import Foundation

enum FormViewModelItemType {
    case text
    case textarea
    case password
    case singleselect
    case multiselect
    case date
    case time
    case dateTimeLocal
    case dropdown
}

protocol FormViewModelItem {
    var type: FormViewModelItemType { get }
    var sectionTitle: String { get }
    var rowCount: Int { get }
}

extension FormViewModelItem {
    var rowCount: Int {
        return 1
    }

    var sectionTitle: String {
        return ""
    }
}

class FormViewModelSingleselectItem: FormViewModelItem {
    typealias Option = KMFormTemplate.Option
    var type: FormViewModelItemType {
        return .singleselect
    }

    var title: String
    var name: String
    var options: [Option]
    var sectionTitle: String {
        return title
    }

    var selectedValue: String?
    var rowCount: Int {
        return options.count
    }

    init(name: String, title: String, options: [Option]) {
        self.name = name
        self.title = title
        self.options = options
    }
}

class FormViewModelMultiselectItem: FormViewModelItem {
    typealias Option = KMFormTemplate.Option
    var type: FormViewModelItemType {
        return .multiselect
    }

    var title: String
    var name: String
    var options: [Option]
    var sectionTitle: String {
        return title
    }

    var rowCount: Int {
        return options.count
    }

    init(name: String, title: String, options: [Option]) {
        self.name = name
        self.title = title
        self.options = options
    }
}

class FormViewModelTextItem: FormViewModelItem {
    typealias Validation = KMFormTemplate.Validation
    var type: FormViewModelItemType {
        return .text
    }

    let label: String
    let placeholder: String?
    let validation: Validation?

    init(label: String,
         placeholder: String?,
         validation: Validation?) {
        self.label = label
        self.placeholder = placeholder
        self.validation = validation
    }
}

class FormViewModelTextAreaItem: FormViewModelItem {
    typealias Validation = KMFormTemplate.Validation
    var type: FormViewModelItemType {
        return .textarea
    }

    let title: String
    let placeholder: String?
    let validation: Validation?

    init(title: String,
         placeholder: String?,
         validation: Validation?) {
        self.title = title
        self.placeholder = placeholder
        self.validation = validation
    }
}

class FormViewModelPasswordItem: FormViewModelItem {
    var type: FormViewModelItemType {
        return .password
    }

    let label: String
    let placeholder: String?

    init(label: String, placeholder: String?) {
        self.label = label
        self.placeholder = placeholder
    }
}

class FormViewModelDateItem: FormViewModelItem {
    var type: FormViewModelItemType {
        return .date
    }

    let label: String
    init(label: String) {
        self.label = label
    }
}

class FormViewModelDateTimeLocalItem: FormViewModelItem {
    var type: FormViewModelItemType {
        return .dateTimeLocal
    }

    let label: String
    init(label: String) {
        self.label = label
    }
}

class FormViewModelTimeItem: FormViewModelItem {
    var type: FormViewModelItemType {
        return .time
    }

    let label: String
    init(label: String) {
        self.label = label
    }
}

class FormViewModelDropdownItem: FormViewModelItem {
    typealias Option = KMFormTemplate.Option
    typealias Validation = KMFormTemplate.Validation

    var type: FormViewModelItemType {
        return .dropdown
    }
    
    let title: String
    let name: String
    var options: [Option]
    let validation: Validation?

    init(title: String, name: String, options: [Option], validation: Validation?) {
        self.title = title
        self.name = name
        self.options = options
        self.validation = validation
    }
    
}

extension KMFormTemplate {
    var viewModeItems: [FormViewModelItem] {
        var items: [FormViewModelItem] = []
        elements.forEach { element in
            switch element.contentType {
            case .text:
                guard let elementData = element.data,
                      let label = elementData.label,
                      let placeHolder = elementData.placeholder else { return }
                items.append(FormViewModelTextItem(
                    label: label,
                    placeholder: placeHolder,
                    validation: elementData.validation
                ))
            case .textarea:
                guard let elementData = element.data,
                      let title = elementData.title,
                      let placeHolder = elementData.placeholder else { return }
                items.append(FormViewModelTextAreaItem(
                    title: title,
                    placeholder: placeHolder,
                    validation: elementData.validation
                ))
            case .password:
                guard let elementData = element.data,
                      let label = elementData.label,
                      let placeHolder = elementData.placeholder else { return }
                items.append(FormViewModelPasswordItem(
                    label: label,
                    placeholder: placeHolder
                ))
            case .singleSelect:
                guard let elementData = element.data,
                      let title = elementData.title,
                      let options = elementData.options,
                      let name = elementData.name else { return }
                items.append(FormViewModelSingleselectItem(name: name,
                                                           title: title,
                                                           options: options))
            case .multiselect:
                if let elementData = element.data,
                   let title = elementData.title,
                   let options = elementData.options,
                   let name = elementData.name {
                    items.append(FormViewModelMultiselectItem(name: name,
                                                              title: title,
                                                              options: options))
                } else if let title = element.title,
                          let options = element.options,
                          let name = element.name {
                    items.append(FormViewModelMultiselectItem(name: name,
                                                              title: title,
                                                              options: options))
                } else { return }
            case .time:
                guard let elementData = element.data,
                      let label = elementData.label else { return }
                items.append(FormViewModelTimeItem(label: label))
            case .date:
                guard let elementData = element.data,
                      let label = elementData.label else { return }
                items.append(FormViewModelDateItem(label: label))
            case .dateTimeLocal:
                guard let elementData = element.data,
                      let label = elementData.label else { return }
                items.append(FormViewModelDateTimeLocalItem(label: label))
            case .dropdown:
                guard let elementData = element.data,
                    let title = elementData.title,
                    let options = elementData.options,
                        let name = elementData.name else { return }
                items.append(FormViewModelDropdownItem(title: title, name: name, options: options, validation: elementData.validation))
            default:
                print("\(element.contentType) form template type is not part of the form list view")
            }
        }
        return items
    }

    var submitButtonTitle: String? {
        if let submitButton = elements
            .filter({ $0.contentType == .submit })
            .first, let submitButtonData = submitButton.data,
           let buttonName = submitButtonData.name {
            return buttonName
        } else if let submitButton = elements
            .filter({ $0.contentType == .submit })
            .first, let buttonName = submitButton.label {
            return buttonName
        } else {
            return nil
        }
    }
}
