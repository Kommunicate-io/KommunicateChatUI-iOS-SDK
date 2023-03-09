//
//  ALKommunicateSettingsMock.swift
//
//  Created by Mukesh Thawani on 17/11/17.
//

import Foundation
import KommunicateCore_iOS_SDK

class ALKommunicateSettingsMock: ALApplozicSettings {
    static var filterContactStatus: Bool = false

    override static func getFilterContactsStatus() -> Bool {
        return filterContactStatus
    }
}
