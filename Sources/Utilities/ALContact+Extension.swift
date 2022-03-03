//
//  ALContact+Extension.swift
//
//
//  Created by Mukesh Thawani on 04/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import Foundation
import KommunicateCore_iOS_SDK

extension ALContact: ALKContactProtocol {
    public var friendUUID: String? {
        return userId
    }

    public var friendDisplayImgURL: URL? {
        guard let imageUrl = contactImageUrl, let url = URL(string: imageUrl) else {
            return nil
        }
        return url
    }

    public var friendProfileName: String? {
        if let name = getDisplayName(), !name.isEmpty {
            return name
        } else {
            return userId
        }
    }

    public var friendMood: String? {
        return nil
    }
}
