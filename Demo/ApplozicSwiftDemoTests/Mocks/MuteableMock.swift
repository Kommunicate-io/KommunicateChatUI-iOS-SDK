//
//  MutableMock.swift
//  ApplozicSwiftDemoTests
//
//  Created by Shivam Pokhriyal on 23/10/18.
//  Copyright © 2018 Applozic. All rights reserved.
//

import Foundation
import Applozic
@testable import ApplozicSwift

class MuteableMock: Muteable {
    
    var isDelegateCalled: Bool = false
    var time: Int64? = nil
    
    func mute(conversation: ALMessage, forTime: Int64, atIndexPath: IndexPath) {
        isDelegateCalled = true
        time = forTime
    }
}
