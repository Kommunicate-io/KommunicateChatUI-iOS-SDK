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

    let templateJsonData = "[{\n  \"title\": \"Demo First Title\",\n  \"subtitle\": \"demo first subtitle.\",\n  \"headerImageUrl\": \"http://www.tollesonhotels.com/wp-content/uploads/2017/03/hotel-room.jpg\",\n  \"overlayText\": \"Rs. 4000\",\n  \"description\": \"demo description\",\n  \"rating\": 2345,\n  \"actions\": [\n    {\n      \"data\": \"Thanks for selections, We will send details\",\n      \"name\": \"View Details\",\n      \"action\": \"sendMessage\"\n    },\n    {\n      \"data\": \"www.facebook.com/myhotel.html\",\n      \"name\": \"Go to Facebook\",\n      \"action\": \"openUrl\"\n    },\n    {\n      \"data\": \"Thanks for selections, We will send details\",\n      \"name\": \"Open Activity\",\n      \"action\": \"openActivity\"\n    }\n  ]\n\n},\n{\"title\": \"Demo Second Title\",\n  \"subtitle\": \"demo second subtitle.\",\n  \"headerImageUrl\": \"http://www.tollesonhotels.com/wp-content/uploads/2017/03/hotel-room.jpg\",\n  \"overlayText\": \"Rs. 3000\",\n  \"description\": \"demo description\",\n  \"rating\": 2345,\n  \"actions\": [\n    {\n      \"data\": \"Thanks for selections, We will send details\",\n      \"name\": \"View Details\",\n      \"action\": \"sendMessage\"\n    },\n    {\n      \"data\": \"www.facebook.com\",\n      \"name\": \"Go to Facebook\",\n      \"action\": \"openUrl\"\n    },\n    {\n      \"data\": \"Thanks for selections, We will send details\",\n      \"name\": \"Open Activity\",\n      \"action\": \"openActivity\"\n    }\n  ]\n}]".data(using: .utf8)

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    func testJsonMapping() {
        let cards = try! JSONDecoder().decode([ALKGenericCard].self, from: templateJsonData!)
        let temp = ALKGenericCardTemplate(cards: cards)
        XCTAssertNotNil(temp.cards.first)
        XCTAssertEqual(temp.cards.count, 2)
        XCTAssertEqual(temp.cards.first?.title, "Demo First Title")
        XCTAssertEqual(temp.cards[1].title, "Demo Second Title")
        XCTAssertEqual(temp.cards.first?.buttons?.count, 3)
        XCTAssertEqual(temp.cards[1].buttons?.count, 3)
    }

    func testModelToJson() {
        let rich = ALKGenericCard(title: "Hello", subtitle: "subtitle", imageUrl: nil, overlayText: nil, description: "dummy description", rating: nil, buttons: nil)
        let jsonData = try! JSONEncoder().encode(rich)
        let jsonString = String(bytes: jsonData, encoding: .utf8)
        let expectedJson = "{\"title\":\"Hello\",\"subtitle\":\"subtitle\",\"description\":\"dummy description\"}"
        XCTAssertNotNil(jsonString)
        XCTAssert(!(jsonString?.isEmpty)!)
        XCTAssertEqual(jsonString!, expectedJson)
    }
}
