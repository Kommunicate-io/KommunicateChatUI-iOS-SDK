//
//  MessageMentionTests.swift
//  ApplozicSwiftDemoTests
//
//  Created by Mukesh on 13/09/19.
//  Copyright © 2019 Applozic. All rights reserved.
//

import XCTest
@testable import ApplozicSwift

class MessageMentionTests: XCTestCase {
    let sampleMessage = "@testdemo9 hi @testdemo10!"

    func sampleMetadataWithTwoIndices(
        firstIndex: (Int, Int) = (0, 10),
        secondIndex: (Int, Int) = (14, 25)
    ) -> [String: Any] {
        let sampleMetadata: [String: Any] = [
            "AL_MEMBER_MENTION":
                """
                [\n  {\n    \"indices\" : [\n      \(firstIndex.0),\n      \(firstIndex.1)\n    ],\n    \"userId\" : \"testdemo9\"\n  },\n  {\n    \"indices\" : [\n      \(secondIndex.0),\n      \(secondIndex.1)\n    ],\n    \"userId\" : \"testdemo10\"\n  }\n]
                """,
        ]
        return sampleMetadata
    }

    func test_whenSendingValidRange() {
        let decoder = MessageMentionDecoder(
            message: sampleMessage,
            metadata: sampleMetadataWithTwoIndices()
        )
        let attributedText =
            decoder.messageWithMentions(
                displayNamesOfUsers: [:],
                attributesForMention: [:],
                defaultAttributes: [:]
            )
        XCTAssertTrue(decoder.containsMentions)
        XCTAssertNotNil(attributedText)

        let firstMentionAttributes = [MessageMention.UserMentionKey: "@testdemo9"]
        let secondMentionAttributes = [MessageMention.UserMentionKey: "@testdemo10"]
        let correctAttributedText =
            NSAttributedString(
                string: "@testdemo9",
                attributes: firstMentionAttributes
            ) +
            NSAttributedString(string: " hi ") +
            NSAttributedString(
                string: "@testdemo10",
                attributes: secondMentionAttributes
            ) +
            NSAttributedString(string: "!")
        XCTAssertEqual(attributedText, correctAttributedText)
    }

    func test_whenSendingOneInvalidIndex() {
        let decoder = MessageMentionDecoder(
            message: sampleMessage,
            metadata: sampleMetadataWithTwoIndices(
                secondIndex: (15, 200)
            )
        )
        XCTAssertTrue(decoder.containsMentions)
        let attributedText =
            decoder.messageWithMentions(
                displayNamesOfUsers: [:],
                attributesForMention: [:],
                defaultAttributes: [:]
            )
        XCTAssertNotNil(attributedText)
        let attributes = [MessageMention.UserMentionKey: "@testdemo9"]
        let correctAttributedText =
            NSAttributedString(string: "@testdemo9", attributes: attributes) +
            NSAttributedString(string: " hi @testdemo10!")
        XCTAssertEqual(attributedText, correctAttributedText)
    }

    func test_whenSendingAllInvalidIndices() {
        let decoder = MessageMentionDecoder(
            message: sampleMessage,
            metadata: sampleMetadataWithTwoIndices(
                firstIndex: (1, 10),
                secondIndex: (15, 200)
            )
        )
        XCTAssertFalse(decoder.containsMentions)
        XCTAssertNil(
            decoder.messageWithMentions(
                displayNamesOfUsers: [:],
                attributesForMention: [:],
                defaultAttributes: [:]
            )
        )
    }
}
