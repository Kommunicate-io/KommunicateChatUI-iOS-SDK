//
//  ALApplozicSettingsMock.swift
//  ApplozicSwiftDemoTests
//
//  Created by Mukesh Thawani on 17/11/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import Foundation
import KommunicateCore_iOS_SDK

class ALApplozicSettingsMock: ALApplozicSettings {
    static var filterContactStatus: Bool = false

    override static func getFilterContactsStatus() -> Bool {
        return filterContactStatus
    }
}
