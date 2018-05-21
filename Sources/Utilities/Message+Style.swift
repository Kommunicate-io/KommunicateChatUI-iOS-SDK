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
        font: UIFont.font(.normal(size: 14)),
        text: .text(.gray9B)
    )

    public static var message = Style(
        font: UIFont.font(.normal(size: 14)),
        text: .text(.black00)
    )

    public static var playTime = Style(
        font: UIFont.font(.normal(size: 16)),
        text: .text(.black00)
    )

    public static var time = Style(
        font: UIFont.font(.italic(size: 12)),
        text: .text(.grayCC)
    )
}
