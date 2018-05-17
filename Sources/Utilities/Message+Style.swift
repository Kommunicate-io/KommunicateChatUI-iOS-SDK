//
//  Message+Style.swift
//  ApplozicSwift
//
//  Created by Mukesh Thawani on 04/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import Foundation
public enum ALKMessageStyle {

    public static var displayName = Style(
        font: .normal(size: 14),
        text: .text(.gray9B)
    )

    public static let message = Style(
        font: .normal(size: 14),
        text: .text(.black00)
    )

    public static let playTime = Style(
        font: .normal(size: 16),
        text: .text(.black00)
    )

    public static let time = Style(
        font: .italic(size: 12),
        text: .text(.grayCC)
    )
}
