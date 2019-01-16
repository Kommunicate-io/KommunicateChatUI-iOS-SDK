//
//  ALKQuickReplyViewSnapshotTests.swift
//  ApplozicSwiftDemoTests
//
//  Created by Shivam Pokhriyal on 10/01/19.
//  Copyright © 2019 Applozic. All rights reserved.
//

import Quick
import Nimble
import Nimble_Snapshots
@testable import ApplozicSwift

class ALKQuickReplyViewSnapshotTests: QuickSpec {

    override func spec() {
        describe("ALKQuickReplyView") {
            var view: ALKQuickReplyView!

            context("with small texts") {
                beforeEach {
                    let payload = "[{\"title\":\"Where is my cashback? \",\"message\":\"Where is my cashback? \"},{\"title\":\"Show me some offers \",\"message\":\"Show me some offers\"},{\"title\":\"Cancel my order \",\"message\":\"Cancel my order \"},{\"title\":\"I want to delete my account \",\"message\":\"I want to delete my account\"},{\"title\":\"Send money \",\"message\":\"Send money \"},{\"title\":\"Accept money \",\"message\":\"Accept money \"}]"
                    let dict = try! self.parseJson(string: payload)

                    view = ALKQuickReplyView(frame: CGRect(x: 0, y: 0, width: 300, height: ALKQuickReplyView.rowHeight(quickReplyArray: dict, maxWidth: 300)))
                    view.maxWidth = 300
                    view.update(quickReplyArray: dict)
                }
                it("has a valid snapshot") {
                    expect(view).to(haveValidSnapshot())
                }
            }

            context("with large texts") {
                beforeEach {
                    let payload = "[{\"title\":\"She's a good girl loves her mama\",\"message\":\"John Mayer\"},{\"title\":\"Come up to meet you tell you I'm sorry\",\"message\":\"Coldplay\"},{\"title\":\"All of these stars will guide us home\",\"message\":\"Ed Sheeran\"},{\"title\":\"I had all and then most of you some and now none of you\",\"message\":\"Lord Huron\"},{\"title\":\"They say love is pain well darling lets hurt tonight\",\"message\":\"One republic\"}]"
                    let dict = try! self.parseJson(string: payload)

                    view = ALKQuickReplyView(frame: CGRect(x: 0, y: 0, width: 300, height: ALKQuickReplyView.rowHeight(quickReplyArray: dict, maxWidth: 300)))
                    view.maxWidth = 300
                    view.update(quickReplyArray: dict)
                }
                it("has a valid snapshot") {
                    expect(view).to(haveValidSnapshot())
                }
            }
        }
    }

    func parseJson(string: String) throws -> [[String: Any]] {
        guard let data = string.data(using: .utf8),
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [AnyObject]
            else {
                throw NSError(domain: NSCocoaErrorDomain, code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON"])
        }
        return jsonObject.map { $0 as! [String: Any] }
    }
}
