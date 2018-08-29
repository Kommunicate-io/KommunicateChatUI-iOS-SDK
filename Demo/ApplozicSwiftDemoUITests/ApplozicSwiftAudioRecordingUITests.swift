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
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()
        
        //First Login.
        guard !XCUIApplication().scrollViews.otherElements.buttons["Get Started"].exists else{
            login()
            return
        }
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testAudioRecordButton_SendVoice(){
        let groupTitle = "TestAudioRecord_SendVoice"
        sleep(2) //Proper time to load screen
        let (app, chatbar, button) = beforeTest_createNewGroup(title: groupTitle)
        sleep(2) //This is important so that screen can load before testing
        XCTAssertTrue(chatbar.exists)
        XCTAssertTrue(button.exists)
        // Create group message
        XCTAssertEqual(app.tables.cells.count, 1)
        button.press(forDuration: 2.5)
        XCTAssertEqual(app.tables.cells.element(boundBy: 1).identifier, "audioCell") // check if message is audio
        XCTAssertEqual(app.tables.cells.count, 2)
        button.press(forDuration: 5.5)
        XCTAssertEqual(app.tables.cells.element(boundBy: 2).identifier, "audioCell") // check if message is audio
        XCTAssertEqual(app.tables.cells.count, 3)
        button.press(forDuration: 1.3)
        XCTAssertEqual(app.tables.cells.element(boundBy: 3).identifier, "audioCell") // check if message is audio
        XCTAssertEqual(app.tables.cells.count, 4)
        afterTest_deleteNewlyCreatedGroup(app: app, title: groupTitle)
    }
    
    func testAudioRecordButton_SendVoiceWithSwipe() {
        let groupTitle = "TestAudioRecord_SendVoiceWithSwipe"
        sleep(2) //Proper time to load screen
        let (app, chatbar, button) = beforeTest_createNewGroup(title: groupTitle)
        sleep(2) //This is important so that screen can load before testing
        XCTAssertTrue(chatbar.exists)
        XCTAssertTrue(button.exists)
        //create group message
        XCTAssertEqual(app.tables.cells.count, 1)
        let startPoint = button.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
        var finishPoint = chatbar.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0))
        startPoint.press(forDuration: 5.3, thenDragTo: finishPoint)
        XCTAssertEqual(app.tables.cells.element(boundBy: 1).identifier, "audioCell") // check if message is audio
        XCTAssertEqual(app.tables.cells.count, 2)
        finishPoint = chatbar.coordinate(withNormalizedOffset: CGVector(dx: 0.8, dy: 0))
        startPoint.press(forDuration: 4.3, thenDragTo: finishPoint)
        XCTAssertEqual(app.tables.cells.element(boundBy: 2).identifier, "audioCell") // check if message is audio
        XCTAssertEqual(app.tables.cells.count, 3)
        afterTest_deleteNewlyCreatedGroup(app: app, title: groupTitle)
    }
    
    func testAudioRecordButton_ShouldNotSendRecordingOfLessThanOneSecond() {
        let groupTitle = "TestAudioRecord_DoNotSendVoiceOfLessThanOneSecond"
        sleep(2) //Proper time to load screen
        let (app, _, button) = beforeTest_createNewGroup(title: groupTitle)
        sleep(2) //This is important so that screen can load before testing
        XCTAssertEqual(app.tables.cells.count, 1)
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
        XCTAssertEqual(app.tables.cells.count, 1)
        afterTest_deleteNewlyCreatedGroup(app: app, title: groupTitle)
    }
    
    func testAudioRecordButton_SwipeLeftShouldCancelRecording(){
        let groupTitle = "TestAudioRecord_SwipeLeftToCancelRecording"
        sleep(2) //Proper time to load screen
        let (app, chatbar, button) = beforeTest_createNewGroup(title: groupTitle)
        sleep(2) //This is important so that screen can load before testing
        XCTAssertTrue(chatbar.exists)
        XCTAssertTrue(button.exists)
        //create group message
        XCTAssertEqual(app.tables.cells.count, 1)
        let startPoint = button.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
        var finishPoint = chatbar.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
        startPoint.press(forDuration: 2, thenDragTo: finishPoint)
        XCTAssertEqual(app.tables.cells.count, 1)
        //This is important otherwise drag will work unexpectedly.
        startPoint.press(forDuration: 1)
        finishPoint = chatbar.coordinate(withNormalizedOffset: CGVector(dx: 0.1, dy: 0))
        startPoint.press(forDuration: 2, thenDragTo: finishPoint)
        XCTAssertEqual(app.tables.cells.count, 1)
        afterTest_deleteNewlyCreatedGroup(app: app, title: groupTitle)
    }
    
    func testAudioRecordButton_SwipeUpShouldCancelRecording() {
        let groupTitle = "TestAudioRecord_SwipeUpToCancelRecording"
        sleep(2) //Proper time to load screen
        let (app, chatbar, button) = beforeTest_createNewGroup(title: groupTitle)
        sleep(2) //This is important so that screen can load before testing
        XCTAssertTrue(chatbar.exists)
        XCTAssertTrue(button.exists)
        //create group message
        XCTAssertEqual(app.tables.cells.count, 1)
        let startPoint = button.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0)) // center of element
        let finishPoint = app.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
        startPoint.press(forDuration: 5, thenDragTo: finishPoint)
        XCTAssertEqual(app.tables.cells.count, 1)
        afterTest_deleteNewlyCreatedGroup(app: app, title: groupTitle)
        
    }
    
    private func login() {
        
        let path = Bundle(for: ApplozicSwiftAudioRecordingUITest.self).url(forResource: "Info", withExtension: "plist")
        let dict = NSDictionary(contentsOf: path!) as? [String: Any]
        let userId = dict!["TestUserId"]
        let password = dict!["TestUserPassword"]
        
        let elementsQuery = XCUIApplication().scrollViews.otherElements
        let userIdTextField = elementsQuery.textFields["User id"]
        userIdTextField.tap()
        userIdTextField.typeText(userId as! String)
        let passwordSecureTextField = elementsQuery.secureTextFields["Password"]
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText(password as! String) 
        elementsQuery.buttons["Get Started"].tap()
    }
    
    private func beforeTest_createNewGroup(title: String) -> (XCUIApplication, XCUIElement, XCUIElement){
        let app = XCUIApplication()
        app.buttons["Launch Chat"].tap()
        app.navigationBars["My Chats"].buttons["fill 214"].tap()
        app.tables.staticTexts["Create Group"].tap()
        let groupNameTextField = app.textFields["Type group name"]
        groupNameTextField.tap()
        groupNameTextField.typeText(title)
        
        app.collectionViews.buttons["icon add people 1"].tap()
        let searchField = app.searchFields["Search"]
        searchField.tap()
        searchField.typeText("user2ToTestAudioRecord")
        
        app.tables["SelectParticipantTableView"].cells.allElementsBoundByIndex.first?.tap()
        app.tables.staticTexts["user2ToTestAudioRecord"].tap()
        app.buttons["InviteButton"].tap()
        
        let chatbar = app.otherElements["chatBar"]
        let button = app.buttons["MicButton"]
        
        return (app, chatbar, button)
    }
    
    private func afterTest_deleteNewlyCreatedGroup(app: XCUIApplication, title: String){
        let backButton = app.navigationBars[title].buttons["icon back"]
        backButton.tap()
        let outerChatScreen = app.tables["OuterChatScreenTableView"]
        outerChatScreen.cells.allElementsBoundByIndex.first?.swipeRight()
        outerChatScreen/*@START_MENU_TOKEN@*/.buttons["icon delete white"]/*[[".cells.buttons[\"icon delete white\"]",".buttons[\"icon delete white\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.alerts.buttons["Remove"].tap()
        sleep(5) // This is to ensure that group is deleted before closing the app
    }
    
    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
}
