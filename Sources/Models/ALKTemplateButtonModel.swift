//
//  ALKTemplateButtonModel.swift
//  ApplozicSwift
//
//  Created by Mukesh Thawani on 27/12/17.
//

import Foundation

public class ALKTemplateButtonModel: NSObject {

    // Should be a unique identifier
    var identifier: String

    // Text to display
    var text: String

    // If true then the template will be shown
    // irrespective of the message type of last message
    var showInAllCases: Bool = true

    var onlyShowWhenLastMessageIsText: Bool = false
    var onlyShowWhenLastMessageIsImage: Bool = false
    var onlyShowWhenLastMessageIsVideo: Bool = false

    var sendMessageOnSelection: Bool = true

    public init(identifier: String, text: String) {
        self.identifier = identifier
        self.text = text
    }
}

extension ALKTemplateButtonModel {
    public convenience init?(json: [String: Any]) {
        guard let identifier = json["identifier"] as? String,
            let text = json["text"] as? String
            else {
                return nil
        }
        self.init(identifier: identifier, text: text)
    }
}
