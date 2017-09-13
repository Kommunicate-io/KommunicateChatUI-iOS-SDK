//
//  Message+Style.swift
//  ApplozicSwift
//
//  Created by Mukesh Thawani on 04/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import Foundation
enum ALKMessageStyle {
    
    static let displayName = Style(
        font: .normal(size: 14),
        color: .gray9B
    )
    
    static let message = Style(
        font: .normal(size: 14),
        color: .black00
    )
    
    static let playTime = Style(
        font: .normal(size: 16),
        color: .black00
    )
    
    static let time = Style(
        font: .italic(size: 12),
        color: .grayCC
    )
}
