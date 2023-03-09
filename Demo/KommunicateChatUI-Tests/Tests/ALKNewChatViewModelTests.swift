//
//  ALKNewChatViewModelTests.swift
//
//  Created by Mukesh Thawani on 16/11/17.
//

import XCTest
@testable import KommunicateChatUI_iOS_SDK

class ALKNewChatViewModelTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }

    func testContactsFetch() {
        let newChatVM = ALKNewChatViewModel(localizedStringFileName: ALKConfiguration().localizedStringFileName)
        let settingsMock = ALKommunicateSettingsMock.self
        let userServiceMock = ALUserServiceMock()

        settingsMock.filterContactStatus = false
        newChatVM.alSettings = settingsMock
        newChatVM.getContacts(userService: userServiceMock, completion: {
            XCTAssertFalse(userServiceMock.getListOfUsersMethodCalled)
        })
    }

    func testAllRegisteredContactsFetch() {
        let newChatVM = ALKNewChatViewModel(localizedStringFileName: ALKConfiguration().localizedStringFileName)
        let settingsMock = ALKommunicateSettingsMock.self
        let userServiceMock = ALUserServiceMock()

        settingsMock.filterContactStatus = true
        newChatVM.alSettings = settingsMock
        newChatVM.getContacts(userService: userServiceMock, completion: {
            XCTAssertTrue(userServiceMock.getListOfUsersMethodCalled)
        })
    }
}
