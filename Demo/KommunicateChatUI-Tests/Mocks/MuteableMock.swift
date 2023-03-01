//
//  MutableMock.swift
//
//  Created by Shivam Pokhriyal on 23/10/18.
//

import Foundation
import KommunicateCore_iOS_SDK
@testable import KommunicateChatUI_iOS_SDK

class MuteableMock: Muteable {
    var isDelegateCalled: Bool = false
    var time: Int64?

    func mute(conversation _: ALMessage, forTime: Int64, atIndexPath _: IndexPath) {
        isDelegateCalled = true
        time = forTime
    }
}
