//
//  CreateGroupViewModel.swift
//  
//
//  Created by Mukesh Thawani on 04/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import Foundation


class ALKCreateGroupViewModel {
    
    var groupName: String = ""
    var originalGroupName: String = ""
    
    func isAddParticipantButtonEnabled() -> Bool {
        let name = groupName.trimmingCharacters(in: .whitespacesAndNewlines)
        return !name.isEmpty
    }
    
    init(groupName name: String) {
        groupName = name
        originalGroupName = name
    }
}
