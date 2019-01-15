//
//  ALKCurvedButtonSnapshotTests.swift
//  ApplozicSwiftDemoTests
//
//  Created by Shivam Pokhriyal on 10/01/19.
//  Copyright © 2019 Applozic. All rights reserved.
//

import Quick
import Nimble
import Nimble_Snapshots
@testable import ApplozicSwift

class ALKCurvedButtonSnapshotTests: QuickSpec {

    override func spec() {
        describe("ALKCurvedButton") {
            var button: ALKCurvedButton!

            context("with default settings") {
                beforeEach {
                    button = ALKCurvedButton(title: "Demo text")
                }
                it("has a valid snapshot") {
                    expect(button).to(haveValidSnapshot())
                }
            }

            context("with different font") {
                beforeEach {
                    button = ALKCurvedButton(title: "Demo text", font: UIFont.boldSystemFont(ofSize: 40))
                }
                it("has a valid snapshot") {
                    expect(button).to(haveValidSnapshot())
                }
            }

            context("with different color") {
                beforeEach {
                    button = ALKCurvedButton(title: "Demo text", color: UIColor.red)
                }
                it("has a valid snapshot") {
                    expect(button).to(haveValidSnapshot())
                }
            }

            context("with different width") {
                beforeEach {
                    button = ALKCurvedButton(title: "Very long text for button", maxWidth: 100)
                }
                it("has a valid snapshot") {
                    expect(button).to(haveValidSnapshot())
                }
            }

            context("with different backgroundColor") {
                beforeEach {
                    button = ALKCurvedButton(title: "Demo text")
                    button.backgroundColor = UIColor.yellow
                }
                it("has a valid snapshot") {
                    expect(button).to(haveValidSnapshot())
                }
            }

            context("without border") {
                beforeEach {
                    button = ALKCurvedButton(title: "Demo text")
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
