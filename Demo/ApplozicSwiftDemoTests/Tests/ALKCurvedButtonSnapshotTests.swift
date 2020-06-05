//
//  ALKCurvedButtonSnapshotTests.swift
//  ApplozicSwiftDemoTests
//
//  Created by Shivam Pokhriyal on 10/01/19.
//  Copyright © 2019 Applozic. All rights reserved.
//

import Nimble
import Nimble_Snapshots
import Quick
import UIKit
@testable import ApplozicSwift

class ALKCurvedButtonSnapshotTests: QuickSpec {
    override func spec() {
        describe("CurvedImageButton") {
            var button: CurvedImageButton!

            context("with default settings") {
                beforeEach {
                    button = CurvedImageButton(title: "Demo text")
                }
                it("has a valid snapshot") {
                    expect(button).to(haveValidSnapshot())
                }
            }

            context("with different font") {
                beforeEach {
                    ALKRichMessageStyle.primaryColor = UIColor(85, green: 83, blue: 183)
                    let config = CurvedImageButton.Config()
                    CurvedImageButton.QuickReplyButtonStyle.shared.font = UIFont.boldSystemFont(ofSize: 40)
                    button = CurvedImageButton(title: "Demo text", config: config)
                }
                it("has a valid snapshot") {
                    expect(button).to(haveValidSnapshot())
                }
            }

            context("with different color") {
                beforeEach {
                    let config = CurvedImageButton.Config()
                    ALKRichMessageStyle.primaryColor = .red
                    CurvedImageButton.QuickReplyButtonStyle.shared.font = UIFont.systemFont(ofSize: 14)
                    button = CurvedImageButton(title: "Demo text", config: config)
                }
                it("has a valid snapshot") {
                    expect(button).to(haveValidSnapshot())
                }
            }

            context("with different width") {
                beforeEach {
                    ALKRichMessageStyle.primaryColor = UIColor(85, green: 83, blue: 183)
                    CurvedImageButton.QuickReplyButtonStyle.shared.font = UIFont.systemFont(ofSize: 14)
                    button = CurvedImageButton(title: "Very long text for button", maxWidth: 100)
                }
                it("has a valid snapshot") {
                    expect(button).to(haveValidSnapshot())
                }
            }

            context("with different backgroundColor") {
                beforeEach {
                    button = CurvedImageButton(title: "Demo text")
                    button.backgroundColor = UIColor.yellow
                }
                it("has a valid snapshot") {
                    expect(button).to(haveValidSnapshot())
                }
            }

            context("without border") {
                beforeEach {
                    button = CurvedImageButton(title: "Demo text")
                    button.layer.borderWidth = 0
                    button.backgroundColor = UIColor.white
                }
                it("has a valid snapshot") {
                    expect(button).to(haveValidSnapshot())
                }
            }
        }
    }
}
