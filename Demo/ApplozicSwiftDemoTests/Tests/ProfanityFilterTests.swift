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
        bundle: Bundle(for: ProfanityFilterTests.self)
    )

    func test_whenUppercaseText() {
        XCTAssertTrue(profanityFilter.containsRestrictedWords(text: "BADWORD"))
    }

    func test_whenAllLowercaseText() {
        XCTAssertTrue(profanityFilter.containsRestrictedWords(text: "badword here"))
    }

    func test_whenUppercaseAndLowercaseTextCombination() {
        XCTAssertTrue(profanityFilter.containsRestrictedWords(text: "badWOrd here"))
    }

    func test_whenUppercaseInFileWithLowerCaseInText() {
        // In file it is: bestBadWord
        XCTAssertTrue(profanityFilter.containsRestrictedWords(text: "bestbadword"))
    }

    func test_whenWordContainsExtraCharacters() {
        XCTAssertFalse(profanityFilter.containsRestrictedWords(text: "--badWord"))
    }

    func test_whenMatchingWordIsInTheEnd() {
        XCTAssertTrue(profanityFilter.containsRestrictedWords(text: "hello badWord"))
    }

    func test_whenMatchIsPresent() {
        let profanityFilterWithRegex = try! ProfanityFilter(
            restrictedMessageRegex: "\\d{10}",
            bundle: Bundle(for: ProfanityFilterTests.self)
        )
        XCTAssertTrue(profanityFilterWithRegex
            .containsRestrictedWords(text: "hello 9299999999"))
    }

    func test_whenMatchIsNotPresent() {
        let profanityFilterWithRegex = try! ProfanityFilter(
            restrictedMessageRegex: "\\d{10}",
            bundle: Bundle(for: ProfanityFilterTests.self)
        )
        XCTAssertFalse(profanityFilterWithRegex
            .containsRestrictedWords(text: "hello 929999"))
    }

    func test_whenMatchesAndRestrictedWordsBothArePresent() {
        let profanityFilterWithRegex = try! ProfanityFilter(
            fileName: "restrictedWords",
            restrictedMessageRegex: "\\d{10}",
            bundle: Bundle(for: ProfanityFilterTests.self)
        )
        XCTAssertTrue(profanityFilterWithRegex
            .containsRestrictedWords(text: "hello 929999999 badword"))
    }

    func test_whenRegexPatternIsInvalid() {
        // "}" is missing in the end
        let invalidPattern = "\\d{10"
        let profanityFilterWithRegex = try! ProfanityFilter(
            restrictedMessageRegex: invalidPattern,
            bundle: Bundle(for: ProfanityFilterTests.self)
        )
        XCTAssertFalse(profanityFilterWithRegex
            .containsRestrictedWords(text: "hello 9299999999"))
    }
}
