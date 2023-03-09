//
//  ALUserServiceMock.swift
//
//  Created by Mukesh Thawani on 17/11/17.
//

import Foundation
import KommunicateCore_iOS_SDK

class ALUserServiceMock: ALUserService {
    var getListOfUsersMethodCalled: Bool = false

    override func getListOfRegisteredUsers(completion: ((Error?) -> Swift.Void)!) {
        getListOfUsersMethodCalled = true
        completion(nil)
    }
}
