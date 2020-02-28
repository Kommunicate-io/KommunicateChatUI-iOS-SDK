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
                    var config = CurvedImageButton.Config()
                    config.font = UIFont.boldSystemFont(ofSize: 40)
                    button = CurvedImageButton(title: "Demo text", config: config)
                }
                it("has a valid snapshot") {
                    expect(button).to(haveValidSnapshot())
                }
            }

            context("with different color") {
                beforeEach {
                    var config = CurvedImageButton.Config()
                    let color = CurvedImageButton.Config.Color(
                        text: .red,
                        border: UIColor.red.cgColor,
                        background: .clear,
                        tint: .red
                    )
                    config.color = color
                    button = CurvedImageButton(title: "Demo text", config: config)
                }
                it("has a valid snapshot") {
                    expect(button).to(haveValidSnapshot())
                }
            }

            context("with different width") {
                beforeEach {
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
