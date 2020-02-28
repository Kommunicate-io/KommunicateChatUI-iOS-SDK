//
//  ApplozicSwiftAudioRecordingUITests.swift
//  ApplozicSwiftDemoUITests
//
//  Created by Shivam Pokhriyal on 29/08/18.
//  Copyright © 2018 Applozic. All rights reserved.
//

import XCTest

class ApplozicSwiftAudioRecordingUITest: XCTestCase {
    override func setUp() {
        super.setUp()

        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // This is important to ensure that the notification permission popup is handled when the app launches for the first time.
        addUIInterruptionMonitor(withDescription: "“ApplozicSwiftDemo” Would Like to Send You Notifications") { (alerts) -> Bool in
            if alerts.buttons["Allow"].exists {
                alerts.buttons["Allow"].tap()
            }
            return true
        }

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        sleep(5)

        // First Login.
        guard !XCUIApplication().scrollViews.otherElements.buttons["Get Started"].exists else {
            login()
            return
        }

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testAudioRecordButton_SendVoice() {
        sleep(2) // Proper time to load screen
        let (app, chatbar, button) = beforeTest_EnterConversation()
        sleep(2) // This is important so that screen can load before testing
        XCTAssertTrue(chatbar.exists)
        XCTAssertTrue(button.exists)

        // This will handle microphone permission in new xcode
        button.press(forDuration: 0.5)
        addUIInterruptionMonitor(withDescription: "“ApplozicSwiftDemo” Would Like to Access the Microphone") { (alerts) -> Bool in
            if alerts.buttons["OK"].exists {
                alerts.buttons["OK"].tap()
            }
            return true
        }
        app.tap()

        let numberOfCells = app.tables.cells.count
        button.press(forDuration: 2.5)
        XCTAssertEqual(app.tables.cells.element(boundBy: numberOfCells).identifier, "audioCell") // check if message is audio
        XCTAssertEqual(app.tables.cells.count, numberOfCells + 1)
        button.press(forDuration: 5.5)
        XCTAssertEqual(app.tables.cells.element(boundBy: numberOfCells + 1).identifier, "audioCell") // check if message is audio
        XCTAssertEqual(app.tables.cells.count, numberOfCells + 2)
        button.press(forDuration: 1.3)
        XCTAssertEqual(app.tables.cells.element(boundBy: numberOfCells + 2).identifier, "audioCell") // check if message is audio
        XCTAssertEqual(app.tables.cells.count, numberOfCells + 3)
        afterTest_DeleteConversation(app: app)
    }

    func testAudioRecordButton_SendVoiceWithSwipe() {
        sleep(2) // Proper time to load screen
        let (app, chatbar, button) = beforeTest_EnterConversation()
        sleep(2) // This is important so that screen can load before testing
        XCTAssertTrue(chatbar.exists)
        XCTAssertTrue(button.exists)

        let numberOfCells = app.tables.cells.count
        let startPoint = button.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
        var finishPoint = chatbar.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0))
        startPoint.press(forDuration: 5.3, thenDragTo: finishPoint)
        XCTAssertEqual(app.tables.cells.element(boundBy: numberOfCells).identifier, "audioCell") // check if message is audio
        XCTAssertEqual(app.tables.cells.count, numberOfCells + 1)
        finishPoint = chatbar.coordinate(withNormalizedOffset: CGVector(dx: 0.8, dy: 0))
        startPoint.press(forDuration: 4.3, thenDragTo: finishPoint)
        XCTAssertEqual(app.tables.cells.element(boundBy: numberOfCells + 1).identifier, "audioCell") // check if message is audio
        XCTAssertEqual(app.tables.cells.count, numberOfCells + 2)
        afterTest_DeleteConversation(app: app)
    }

    func testAudioRecordButton_ShouldNotSendRecordingOfLessThanOneSecond() {
        sleep(2) // Proper time to load screen
        let (app, _, button) = beforeTest_EnterConversation()
        sleep(2) // This is important so that screen can load before testing

        let numberOfCells = app.tables.cells.count
        button.press(forDuration: 0.0)
        button.press(forDuration: 0.1)
        button.press(forDuration: 0.2)
        button.press(forDuration: 0.3)
        button.press(forDuration: 0.4)
        button.press(forDuration: 0.5)
        button.press(forDuration: 0.6)
        button.press(forDuration: 0.7)
        button.press(forDuration: 0.8)
        button.press(forDuration: 0.9)
        XCTAssertEqual(app.tables.cells.count, numberOfCells)
        afterTest_DeleteConversation(app: app)
    }

    func testAudioRecordButton_SwipeLeftShouldCancelRecording() {
        sleep(2) // Proper time to load screen
        let (app, chatbar, button) = beforeTest_EnterConversation()
        sleep(2) // This is important so that screen can load before testing
        XCTAssertTrue(chatbar.exists)
        XCTAssertTrue(button.exists)

        let numberOfCells = app.tables.cells.count
        let startPoint = button.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
        var finishPoint = chatbar.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
        startPoint.press(forDuration: 2, thenDragTo: finishPoint)
        XCTAssertEqual(app.tables.cells.count, numberOfCells)
        // This is important otherwise drag will work unexpectedly.
        startPoint.press(forDuration: 1)
        finishPoint = chatbar.coordinate(withNormalizedOffset: CGVector(dx: 0.1, dy: 0))
        startPoint.press(forDuration: 2, thenDragTo: finishPoint)
        XCTAssertEqual(app.tables.cells.count, numberOfCells)
        afterTest_DeleteConversation(app: app)
    }

    func testAudioRecordButton_SwipeUpShouldCancelRecording() {
        sleep(2) // Proper time to load screen
        let (app, chatbar, button) = beforeTest_EnterConversation()
        sleep(2) // This is important so that screen can load before testing
        XCTAssertTrue(chatbar.exists)
        XCTAssertTrue(button.exists)

        let numberOfCells = app.tables.cells.count
        let startPoint = button.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0)) // center of element
        let finishPoint = app.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
        startPoint.press(forDuration: 5, thenDragTo: finishPoint)
        XCTAssertEqual(app.tables.cells.count, numberOfCells)
        afterTest_DeleteConversation(app: app)
    }

    private func login() {
        let path = Bundle(for: ApplozicSwiftAudioRecordingUITest.self).url(forResource: "Info", withExtension: "plist")
        let dict = NSDictionary(contentsOf: path!) as? [String: Any]
        let userId = dict?["TestUserId"]
        let password = dict?["TestUserPassword"]
        XCUIApplication().tap()
        let elementsQuery = XCUIApplication().scrollViews.otherElements
        let userIdTextField = elementsQuery.textFields["User id"]
        userIdTextField.tap()
        userIdTextField.typeText(userId as! String)
        let passwordSecureTextField = elementsQuery.secureTextFields["Password"]
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText(password as! String)
        elementsQuery.buttons["Get Started"].tap()
    }

    private func beforeTest_EnterConversation() -> (XCUIApplication, XCUIElement, XCUIElement) {
        let app = XCUIApplication()
        let path = Bundle(for: ApplozicSwiftAudioRecordingUITest.self).url(forResource: "Info", withExtension: "plist")
        let dict = NSDictionary(contentsOf: path!) as? [String: Any]
        app.buttons["Launch Chat"].tap()
        sleep(2)
        app.navigationBars["My Chats"].buttons["fill 214"].tap()
        sleep(3)
        let searchField = app.searchFields["Search"]
        searchField.tap()
        searchField.typeText(dict?["GroupMember1"] as! String)
        sleep(1)
        if app.tables.cells.count == 1 {
            var emptyString = String()
            let stringValue = searchField.value as! String
            for _ in stringValue {
                emptyString += XCUIKeyboardKey.delete.rawValue
            }
            searchField.typeText(emptyString)
        }
        app.tables.cells.allElementsBoundByIndex[1].tap()

        let chatbar = app.otherElements["chatBar"]
        let button = app.buttons["MicButton"]

        return (app, chatbar, button)
    }

    private func afterTest_DeleteConversation(app: XCUIApplication) {
        let backButton = app.buttons["conversationBackButton"]
        backButton.tap()
        let outerChatScreen = app.tables["OuterChatScreenTableView"]

        if outerChatScreen.cells.count == 1 {
            // No Conversation to be deleted Because message wasn't sent
            return
        }

        outerChatScreen.cells.allElementsBoundByIndex.first?.swipeRight()
        outerChatScreen.buttons["SwippableDeleteIcon"].tap()
        app.alerts.buttons["Remove"].tap()
        sleep(5) // This is to ensure that Conversation is deleted before closing the app
    }

    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}
