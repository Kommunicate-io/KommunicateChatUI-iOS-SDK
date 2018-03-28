//
//  ALKGenericCardTests.swift
//  ApplozicSwiftDemoTests
//
//  Created by Mukesh Thawani on 27/03/18.
//  Copyright © 2018 Applozic. All rights reserved.
//

import XCTest
@testable import ApplozicSwift

class ALKGenericCardTests: XCTestCase {

    let templateJsonData = "{\"elements\":[{\"title\":\"Book\",\"subtitle\":\"The only subtitle.\",\"description\":\"It's a good book.\",\"image_url\":\"https://www.image.com\",\"buttons\":[{\"type\":\"link\",\"title\":\"See more\",\"url\":\"https://www.click.com\"},{\"type\":\"post\",\"title\":\"Send message\",\"id\":\"12345\"},{\"type\":\"post\",\"title\":\"Send new message\",\"id\":\"123456\"}]},{\"title\":\"New Book\",\"subtitle\":\"The only subtitle.\",\"description\":\"It's a good book.\",\"image_url\":\"https://www.image.com\",\"buttons\":[{\"type\":\"link\",\"title\":\"See more\",\"url\":\"https://www.click.com\"},{\"type\":\"post\",\"title\":\"Send message\",\"id\":\"1234567\"},{\"type\":\"post\",\"title\":\"Send new message\",\"id\":\"12345689\"}]}]}".data(using: .utf8)

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    func testJsonMapping() {
        let temp = try! JSONDecoder().decode(ALKGenericCardTemplate.self, from: templateJsonData!)
        XCTAssertNotNil(temp.cards.first)
        XCTAssertEqual(temp.cards.count, 2)
        XCTAssertEqual(temp.cards.first?.title, "Book")
        XCTAssertEqual(temp.cards[1].title, "New Book")
        XCTAssertEqual(temp.cards.first?.buttons?.count, 3)
        XCTAssertEqual(temp.cards[1].buttons?.count, 3)
    }

    func testModelToJson() {
        let rich = ALKGenericCard(title: "Hello", subtitle: "subtitle", description: "descr", imageUrl: nil, buttons: nil)
        let richtemp = ALKGenericCardTemplate(cards: [rich])
        let jsonData = try! JSONEncoder().encode(richtemp)
        let jsonString = String(bytes: jsonData, encoding: .utf8)
        let expectedJson = "{\"elements\":[{\"title\":\"Hello\",\"subtitle\":\"subtitle\",\"description\":\"descr\"}]}"
        XCTAssertNotNil(jsonString)
        XCTAssert(!(jsonString?.isEmpty)!)
        XCTAssertEqual(jsonString!, expectedJson)
    }
}
