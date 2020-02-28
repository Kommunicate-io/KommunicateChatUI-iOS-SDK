//
//  TemplateDecoderTests.swift
//  ApplozicSwiftDemoTests
//
//  Created by Mukesh on 29/04/19.
//  Copyright © 2019 Applozic. All rights reserved.
//

import XCTest
@testable import ApplozicSwift

class TemplateDecoderTests: XCTestCase {
    struct CustomType: Decodable {
        let title: String
    }

    func testWhenPayloadIsNotPresent() {
        XCTAssertThrowsError(try TemplateDecoder.decode(ListTemplate.self, from: ["": ""])) { error in
            guard let decodingError = error as? TemplateDecodingError else {
                XCTFail("Threw the wrong type of error")
                return
            }
            XCTAssert(decodingError == .payloadMissing)
        }
    }

    func testWhenEmptyPayloadIsPresent() {
        XCTAssertThrowsError(try TemplateDecoder.decode(ListTemplate.self, from: ["payload": ""]))
    }

    func testWhenCorrectPayloadIsPresent() {
        let customJson = ["payload": "{\"title\": \"Hello\"}"]
        XCTAssertNoThrow(try TemplateDecoder.decode(CustomType.self, from: customJson))
    }
}
