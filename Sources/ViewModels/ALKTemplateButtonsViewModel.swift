//
//  ALKTemplateButtonsViewModel.swift
//  ApplozicSwift
//
//  Created by Mukesh Thawani on 27/12/17.
//

import Foundation
import Applozic

open class ALKTemplateButtonsViewModel: NSObject {


    //TODO: Create a model where we can parse and map the objects present in json to real object.
    // We should not use string based API

    public init(json: Dictionary<String, String>) {
        // Use json to get the data to display and settings like when to display.

    }

    open func updateLast(message: ALMessage) {
        // Use last message to check the message type and to see if it's receiver's or sender's message
    }
}
