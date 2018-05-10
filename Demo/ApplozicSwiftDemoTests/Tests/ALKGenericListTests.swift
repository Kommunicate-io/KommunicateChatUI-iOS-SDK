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

    let templateJsonData = "{\"headerImage\":\"https://placeimg.com/640/480/tech\",\"headerText\":\"The big title\",\"elements\":[{\"title\":\"A new title\",\"description\":\"It's good. Very good.\",\"imageUrl\":\"https://placeimg.com/640/480/tech\",\"defaultActionType\":\"\",\"defaultActionUrl\":\"https://www.click.com\"},{\"title\":\"A new title\",\"description\":\"It's good. Very good.\",\"imageUrl\":\"https://placeimg.com/640/480/tech\",\"defaultActionType\":\"\",\"defaultActionUrl\":\"\"}],\"buttons\":[{\"type\":\"link\",\"title\":\"See more\",\"url\":\"https://www.click.com\"},{\"type\":\"post\",\"title\":\"Send message\",\"id\":\"12345\"},{\"type\":\"post\",\"title\":\"Send new message\",\"id\":\"123456\"}]}".data(using: .utf8)

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    func testJsonMapping() {
        let temp = try! JSONDecoder().decode(ALKGenericListTemplate.self, from: templateJsonData!)
        XCTAssertEqual(temp.headerText, "The big title")
        XCTAssertGreaterThanOrEqual(temp.elements.count, 0)
        XCTAssertNotNil(temp.elements.first)
        XCTAssertEqual(temp.elements.first?.title, "A new title")
        XCTAssertEqual(temp.buttons.first?.title, "See more")
    }

    func testModelToJson() {
        let list = ALKGenericListTemplate(headerImage: "", headerText: "The big title", elements: [], buttons: [])
        let jsonData = try! JSONEncoder().encode(list)
        let jsonString = String(bytes: jsonData, encoding: .utf8)
        XCTAssertNotNil(jsonString)
        XCTAssertFalse((jsonString?.isEmpty)!)

        // Comparing two json strings is not correct as position
        // of key-value pair can change. So decoding it to compare.
        let temp = try! JSONDecoder().decode(ALKGenericListTemplate.self, from: jsonData)
        XCTAssertEqual(temp.headerText, "The big title")
        XCTAssertEqual(temp.elements.count, 0)
    }
}
