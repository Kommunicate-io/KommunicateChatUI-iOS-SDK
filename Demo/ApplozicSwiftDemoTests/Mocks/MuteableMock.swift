//
//  MutableMock.swift
//  ApplozicSwiftDemoTests
//
//  Created by Shivam Pokhriyal on 23/10/18.
//  Copyright © 2018 Applozic. All rights reserved.
//

import Foundation
import KommunicateCoreiOSSDK
@testable import KommunicateChatUI_iOS_SDK

class MuteableMock: Muteable {
    var isDelegateCalled: Bool = false
    var time: Int64?

    func mute(conversation _: ALMessage, forTime: Int64, atIndexPath _: IndexPath) {
        isDelegateCalled = true
        time = forTime
    }
}
