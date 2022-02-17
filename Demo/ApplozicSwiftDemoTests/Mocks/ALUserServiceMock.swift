//
//  ALUserServiceMock.swift
//  ApplozicSwiftDemoTests
//
//  Created by Mukesh Thawani on 17/11/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import Foundation
import ApplozicCore

class ALUserServiceMock: ALUserService {
    var getListOfUsersMethodCalled: Bool = false

    override func getListOfRegisteredUsers(completion: ((Error?) -> Swift.Void)!) {
        getListOfUsersMethodCalled = true
        completion(nil)
    }
}
