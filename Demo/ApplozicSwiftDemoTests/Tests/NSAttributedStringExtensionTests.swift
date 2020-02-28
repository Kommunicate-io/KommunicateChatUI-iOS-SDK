//
//  NSAttributedStringExtensionTests.swift
//  ApplozicSwiftDemoTests
//
//  Created by Mukesh on 04/10/19.
//  Copyright © 2019 Applozic. All rights reserved.
//

import XCTest
@testable import ApplozicSwift

class NSAttributedStringExtensionTests: XCTestCase {
    let charactersToRemove = CharacterSet.whitespacesAndNewlines

    func testAttributedString_whenTrimmed() {
        let attributedString1 = NSAttributedString(string: " abc ")
        XCTAssertEqual(attributedString1.trimmingCharacters(in: charactersToRemove).string, "abc")

        let attributedString2 = NSAttributedString(string: "abc \n ")
        XCTAssertEqual(attributedString2.trimmingCharacters(in: charactersToRemove).string, "abc")

        let attributedString3 = NSAttributedString(string: " ")
        XCTAssertEqual(attributedString3.trimmingCharacters(in: charactersToRemove).string, "")
    }

    func testAttributedStringWithAttributes_whenTrimmed() {
        let attributedString1 = NSMutableAttributedString(string: "abc \n ")
        let stringWithAttributes = NSAttributedString(
            string: "with custom color",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.red]
        )
        attributedString1.append(stringWithAttributes)

        let expectedAttributedString1 = NSMutableAttributedString(string: "abc \n ")
        expectedAttributedString1.append(stringWithAttributes)
        XCTAssertEqual(attributedString1.trimmingCharacters(in: charactersToRemove), expectedAttributedString1)

        let attributedString2 = NSMutableAttributedString(string: "  \n abc")
        attributedString2.append(stringWithAttributes)

        // Empty lines and spaces in the start should be removed
        // and attributes shouldn't get affected.
        let expectedAttributedString2 = NSMutableAttributedString(string: "abc")
        expectedAttributedString2.append(stringWithAttributes)
        XCTAssertEqual(attributedString2.trimmingCharacters(in: charactersToRemove), expectedAttributedString2)

        let attributedString3 = NSMutableAttributedString(string: "abc")
        let stringWithAttributesAndEmptyLines = NSAttributedString(
            string: "with custom color \n  ",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.red]
        )
        attributedString3.append(stringWithAttributesAndEmptyLines)

        let expectedAttributedString3 = NSMutableAttributedString(string: "abc")
        expectedAttributedString3.append(stringWithAttributes)
        XCTAssertEqual(attributedString3.trimmingCharacters(in: charactersToRemove), expectedAttributedString3)
    }
}
