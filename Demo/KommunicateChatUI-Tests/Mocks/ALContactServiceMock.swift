//
//  ALContactServiceMock.swift
//
//  Created by Shivam Pokhriyal on 24/10/18.
//

import Foundation
import KommunicateCore_iOS_SDK

class ALContactServiceMock: ALContactService {
    override func loadContact(byKey _: String!, value _: String!) -> ALContact! {
        let contact = ALContact()
        contact.displayName = "demoDisplayName"
        return contact
    }
}
