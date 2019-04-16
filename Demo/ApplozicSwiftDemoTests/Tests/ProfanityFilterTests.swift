//
//  ProfanityFilterTests.swift
//  ApplozicSwiftDemoTests
//
//  Created by Mukesh on 10/04/19.
//  Copyright © 2019 Applozic. All rights reserved.
//

import XCTest
@testable import ApplozicSwift

class ProfanityFilterTests: XCTestCase {

    var profanityFilter: ProfanityFilter = try! ProfanityFilter(
        fileName: "restrictedWords",
        bundle: Bundle(for: ProfanityFilterTests.self))

    override func setUp() {
    }

    func testUppercaseText() {
        XCTAssertTrue(profanityFilter.containsRestrictedWords(text: "BADWORD"))
    }

    func testAllLowercaseText() {
        XCTAssertTrue(profanityFilter.containsRestrictedWords(text: "badword here"))
    }

    func testUppercaseAndLowercaseTextCombination() {
        XCTAssertTrue(profanityFilter.containsRestrictedWords(text: "badWOrd here"))
    }

    func testUppercaseInFileWithLowerCaseInText() {
        // In file it is: bestBadWord
        XCTAssertTrue(profanityFilter.containsRestrictedWords(text: "bestbadword"))
    }

    func testWhenWordContainsExtraCharacters() {
        XCTAssertFalse(profanityFilter.containsRestrictedWords(text: "--badWord"))
    }
}
