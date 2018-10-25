//
//  ALKChatBarSnapshotTests.swift
//  ApplozicSwiftDemoTests
//
//  Created by Shivam Pokhriyal on 24/10/18.
//  Copyright © 2018 Applozic. All rights reserved.
//

import Quick
import Nimble
import Nimble_Snapshots
import Applozic
@testable import ApplozicSwift

class ALKChatBarSnapshotTests: QuickSpec{
    
    override func spec() {
        
        describe("ChatBar") {
            
            var configuration: ALKConfiguration!
            var chatBar: ALKChatBar!
            var demoView: UIView!
            
            func prepareChatBar() {
                chatBar.showMediaView()
                demoView.addViewsForAutolayout(views: [chatBar])
                chatBar.leadingAnchor.constraint(equalTo: demoView.leadingAnchor).isActive = true
                chatBar.trailingAnchor.constraint(equalTo: demoView.trailingAnchor).isActive = true
            }
            
            beforeEach {
                demoView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 300))
                configuration = ALKConfiguration()
            }
            
            context("configure line between send icon and text view") {

                it("hides line image") {
                    configuration.hideLineImageFromChatBar = true
                    chatBar = ALKChatBar(frame: .zero, configuration: configuration)
                    prepareChatBar()
                    expect(chatBar).to(haveValidSnapshot())
                }

                it("shows line image") {
                    configuration.hideLineImageFromChatBar = false
                    chatBar = ALKChatBar(frame: .zero, configuration: configuration)
                    prepareChatBar()
                    expect(chatBar).to(haveValidSnapshot())
                }
            }

            context("configure send icon") {
                
                it("show send icon") {
                    configuration.hideAudioOptionInChatBar = true
                    chatBar = ALKChatBar(frame: .zero, configuration: configuration)
                    prepareChatBar()
                    expect(chatBar).to(haveValidSnapshot())
                }
                
                it("change send icon image") {
                    configuration.hideAudioOptionInChatBar = true
                    configuration.sendMessageIcon = UIImage(named: "close", in: Bundle.applozic, compatibleWith: nil)
                    chatBar = ALKChatBar(frame: .zero, configuration: configuration)
                    prepareChatBar()
                    expect(chatBar).to(haveValidSnapshot())
                }
            }
        }
    }
    
}
