//
//  ALKGenericListTests.swift
//  ApplozicSwiftDemoTests
//
//  Created by Mukesh Thawani on 20/04/18.
//  Copyright © 2018 Applozic. All rights reserved.
//

import XCTest
@testable import ApplozicSwift


class ALKGenericListTests: XCTestCase {

    let templateJsonData = "[{\"title\":\"Where is my cashback?\",\"message\":\"Where is my cashback? \"},{\"title\":\"Show me some offers \",\"message\":\"Show me some offers\"},{\"title\":\"Cancel my order \",\"message\":\"Cancel my order \"},{\"title\":\"I want to delete my account \",\"message\":\"I want to delete my account\"},{\"title\":\"Send money \",\"message\":\"Send money \"},{\"title\":\"Accept money \",\"message\":\"Accept money \"}]".data(using: .utf8)

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    func testJsonMapping() {
        let temp = try! JSONDecoder().decode([ALKGenericListTemplate].self, from: templateJsonData!)
        XCTAssertGreaterThanOrEqual(temp.count, 0)
        XCTAssertNotNil(temp.first)
        XCTAssertEqual(temp.first?.title, "Where is my cashback?")
    }

    func testModelToJson() {
        let list = ALKGenericListTemplate(title: "Check", message: "The big title")
        let jsonData = try! JSONEncoder().encode(list)
        let jsonString = String(bytes: jsonData, encoding: .utf8)
        XCTAssertNotNil(jsonString)
        XCTAssertFalse((jsonString?.isEmpty)!)

        // Comparing two json strings is not correct as position
        // of key-value pair can change. So decoding it to compare.
        let temp = try! JSONDecoder().decode(ALKGenericListTemplate.self, from: jsonData)
        XCTAssertEqual(temp.title, "Check")
    }
}
