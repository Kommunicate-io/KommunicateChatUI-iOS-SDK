//
//  ApplozicSwiftMemberUITests.swift
//  ApplozicSwiftDemoUITests
//
//  Created by Archit on 18/02/20.
//  Copyright © 2020 Applozic. All rights reserved.
//

import XCTest

class ApplozicSwiftMemberUITests: XCTestCase {
    enum GroupData {
        static let groupMember1 = "GroupMember1"
        static let groupMember2 = "GroupMember2"
        static let groupMember3 = "GroupMember3"
        static let typeText = "Hello Applozic"
        static let fillUserId = "TestUserId"
        static let fillPassword = "TestUserPassword"
    }

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        addUIInterruptionMonitor(withDescription: AppPermission.AlertMessage.accessNotificationInApplication) { (alerts) -> Bool in
            if alerts.buttons[AppPermission.AlertButton.allow].exists {
                alerts.buttons[AppPermission.AlertButton.allow].tap()
            }
            return true
        }
        XCUIApplication().launch()
        guard !XCUIApplication().scrollViews.otherElements.buttons[InAppButton.LaunchScreen.getStarted].exists else {
            login()
            return
        }
    }

    func testMakeGroupAdminInGroup() {
        let groupName = "DemoGroupForMakeGroupAdmin"
        let app = beforeStartTest_CreateAGroup_And_EnterInConversation(groupName: groupName)
        app.navigationBars[AppScreen.myChatScreen].staticTexts[groupName].tap()
        let path = Bundle(for: ApplozicSwiftGroupSendMessageUITest.self).url(forResource: "Info", withExtension: "plist")
        let dict = NSDictionary(contentsOf: path!) as? [String: Any]
        guard let member2Name = dict?[GroupData.groupMember2] as? String
        else {
            XCTFail("Name of member 2 is not found info Plist")
            return
        }
        app.collectionViews.staticTexts[member2Name].tap()
        let elementsQuery = app.sheets.firstMatch
        let editButton = elementsQuery.buttons[InAppButton.EditGroup.makeGroupAdmin]
        waitFor(object: editButton) { $0.isHittable }
        editButton.tap()
        let saveChangesButton = app.buttons[InAppButton.EditGroup.save]
        waitFor(object: saveChangesButton) { $0.isHittable }
        saveChangesButton.tap()
        sleep(1)
        let isGroupDeleted = deleteAGroup_FromConversationList(app: app) // leave the group and delete group
        XCTAssertTrue(isGroupDeleted, "Failed to delete group DemoGroupForMakeGroupAdmin")
    }

    func testRemoveMemberFromGroup() {
        let groupName = "DemoGroupForRemoveMember"
        let app = beforeStartTest_CreateAGroup_And_EnterInConversation(groupName: groupName)
        app.navigationBars[AppScreen.myChatScreen].staticTexts[groupName].tap()
        let path = Bundle(for: ApplozicSwiftGroupSendMessageUITest.self).url(forResource: "Info", withExtension: "plist")
        let dict = NSDictionary(contentsOf: path!) as? [String: Any]
        guard let member2Name = dict?[GroupData.groupMember2] as? String else {
            XCTFail("Name of member 2 is not found info Plist")
            return
        }
        app.collectionViews.staticTexts[member2Name].tap()
        let elementsQuery = XCUIApplication().sheets.scrollViews.otherElements
        let removeUserButton = elementsQuery.buttons[InAppButton.EditGroup.removeUser]
        waitFor(object: removeUserButton) { $0.isHittable }
        removeUserButton.tap()
        let removeButton = elementsQuery.buttons[InAppButton.EditGroup.remove]
        waitFor(object: removeButton) { $0.isHittable }
        removeButton.tap()
        let saveChangesButton = app.buttons[InAppButton.EditGroup.save]
        waitFor(object: saveChangesButton) { $0.isHittable }
        saveChangesButton.tap()
        sleep(1)
        let isGroupDeleted = deleteAGroup_FromConversationList(app: app) // leave the group and delete group
        XCTAssertTrue(isGroupDeleted, "Failed to delete group DemoGroupForRemoveMember")
    }

    func testAddMemberInGroup() {
        let groupName = "DemoGroupForAddMember"
        let app = beforeStartTest_CreateAGroup_And_EnterInConversation(groupName: groupName)
        app.navigationBars[AppScreen.myChatScreen].staticTexts[groupName].tap()
        let path = Bundle(for: ApplozicSwiftGroupSendMessageUITest.self).url(forResource: "Info", withExtension: "plist")
        let dict = NSDictionary(contentsOf: path!) as? [String: Any]
        guard let member3Name = dict?[GroupData.groupMember3] as? String else {
            XCTFail("Name of member 2 is not found info Plist")
            return
        }
        let addParticipant = app.collectionViews.staticTexts[InAppButton.CreatingGroup.addParticipant]
        waitFor(object: addParticipant) { $0.isHittable }
        addParticipant.tap()
        let selectParticipantTableView = app.tables[AppScreen.selectParticipantView]
        waitFor(object: selectParticipantTableView) { $0.isHittable }
        selectParticipantTableView.staticTexts[member3Name].tap()
        let inviteButton = app.buttons[InAppButton.CreatingGroup.invite]
        waitFor(object: inviteButton) { $0.isHittable }
        inviteButton.tap()
        sleep(1)
        let isGroupDeleted = deleteAGroup_FromConversationList(app: app) // leave the group and delete group
        XCTAssertTrue(isGroupDeleted, "Failed to delete group DemoGroupForAddMember")
    }

    private func login() {
        let path = Bundle(for: ApplozicSwiftGroupSendMessageUITest.self).url(forResource: "Info", withExtension: "plist")
        let dict = NSDictionary(contentsOf: path!) as? [String: Any]
        let userId = dict?[GroupData.fillUserId]
        let password = dict?[GroupData.fillPassword]
        XCUIApplication().tap()
        let elementsQuery = XCUIApplication().scrollViews.otherElements
        let userIdTextField = elementsQuery.textFields[AppTextFeild.userId]
        userIdTextField.tap()
        userIdTextField.typeText(userId as! String)
        let passwordSecureTextField = elementsQuery.secureTextFields[AppTextFeild.password]
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText(password as! String)
        elementsQuery.buttons[InAppButton.LaunchScreen.getStarted].tap()
    }

    private func beforeStartTest_CreateAGroup_And_EnterInConversation(groupName: String) -> (XCUIApplication) {
        let app = XCUIApplication()
        let path = Bundle(for: ApplozicSwiftGroupSendMessageUITest.self).url(forResource: "Info", withExtension: "plist")
        let dict = NSDictionary(contentsOf: path!) as? [String: Any]
        let launchChat = app.buttons[InAppButton.LaunchScreen.launchChat]
        waitFor(object: launchChat) { $0.isHittable }
        app.buttons[InAppButton.LaunchScreen.launchChat].tap()
        let newChat = app.buttons[InAppButton.CreatingGroup.newChat]
        waitFor(object: newChat) { $0.isHittable }
        app.navigationBars[AppScreen.myChatScreen].buttons[InAppButton.CreatingGroup.newChat].tap()
        let createGroup = app.tables.staticTexts[InAppButton.CreatingGroup.createGroup]
        waitFor(object: createGroup) { $0.isHittable }
        createGroup.tap()
        let typeGroupNameTextField = app.textFields[AppTextFeild.typeGroupName]
        waitFor(object: typeGroupNameTextField) { $0.isHittable }
        typeGroupNameTextField.tap()
        typeGroupNameTextField.typeText(groupName)
        let addParticipant = app.collectionViews.staticTexts[InAppButton.CreatingGroup.addParticipant]
        waitFor(object: addParticipant) { $0.isHittable }
        addParticipant.tap()
        let selectParticipantTableView = app.tables[AppScreen.selectParticipantView]
        waitFor(object: selectParticipantTableView) { $0.isHittable }
        selectParticipantTableView.staticTexts[dict?[GroupData.groupMember1] as! String].tap()
        selectParticipantTableView.staticTexts[dict?[GroupData.groupMember2] as! String].tap()
        app.buttons[InAppButton.CreatingGroup.invite].tap()
        return app
    }

    private func deleteAGroup_FromConversationList(app: XCUIApplication) -> Bool {
        let back = app.navigationBars[AppScreen.myChatScreen].buttons[InAppButton.ConversationScreen.back]
        waitFor(object: back) { $0.isHittable }
        back.tap()
        let outerChatScreenTableView = app.tables[AppScreen.conversationList]
        if outerChatScreenTableView.cells.allElementsBoundByIndex.isEmpty {
            return false
        }
        outerChatScreenTableView.cells.allElementsBoundByIndex.first?.swipeRight()
        let swippableleave = app.buttons[InAppButton.ConversationScreen.swippableDelete]
        waitFor(object: swippableleave) { $0.isHittable }
        outerChatScreenTableView.buttons[InAppButton.ConversationScreen.swippableDelete].tap()
        let leave = app.alerts.scrollViews.otherElements.buttons[InAppButton.CreatingGroup.leave]
        waitFor(object: leave) { $0.isHittable }
        leave.tap()
        if outerChatScreenTableView.cells.allElementsBoundByIndex.isEmpty {
            return false
        }
        sleep(5)
        outerChatScreenTableView.cells.allElementsBoundByIndex.first?.swipeRight()
        let swippableDelete2 = app.buttons[InAppButton.ConversationScreen.swippableDelete]
        waitFor(object: swippableDelete2) { $0.isHittable }
        outerChatScreenTableView.buttons[InAppButton.ConversationScreen.swippableDelete].tap()
        let remove = app.alerts.scrollViews.otherElements.buttons[InAppButton.CreatingGroup.remove]
        waitFor(object: remove) { $0.isHittable }
        remove.tap()
        return true
    }
}
