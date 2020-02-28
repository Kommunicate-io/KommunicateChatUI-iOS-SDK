//
//  ALKNewChatViewModelTests.swift
//  ApplozicSwiftDemoTests
//
//  Created by Mukesh Thawani on 16/11/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import XCTest
@testable import ApplozicSwift

class ALKNewChatViewModelTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }

    func testContactsFetch() {
        let newChatVM = ALKNewChatViewModel(localizedStringFileName: ALKConfiguration().localizedStringFileName)
        let settingsMock = ALApplozicSettingsMock.self
        let userServiceMock = ALUserServiceMock()

        settingsMock.filterContactStatus = false
        newChatVM.applozicSettings = settingsMock
        newChatVM.getContacts(userService: userServiceMock, completion: {
            XCTAssertFalse(userServiceMock.getListOfUsersMethodCalled)
        })
    }

    func testAllRegisteredContactsFetch() {
        let newChatVM = ALKNewChatViewModel(localizedStringFileName: ALKConfiguration().localizedStringFileName)
        let settingsMock = ALApplozicSettingsMock.self
        let userServiceMock = ALUserServiceMock()

        settingsMock.filterContactStatus = true
        newChatVM.applozicSettings = settingsMock
        newChatVM.getContacts(userService: userServiceMock, completion: {
            XCTAssertTrue(userServiceMock.getListOfUsersMethodCalled)
        })
    }
}
