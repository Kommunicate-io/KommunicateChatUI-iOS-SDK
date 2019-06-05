//
//  ChatCellConfig.swift
//  ApplozicSwift
//
//  Created by Shivam Pokhriyal on 03/06/19.
//

import Foundation

public struct ChatCellConfig {

    public struct Received {

        public struct ProfileImage {
            public static var width: CGFloat = 37.0
            public static var height: CGFloat = 37.0
            /// Top padding of `ProfileImage` from `DisplayName`
            public static var topPadding: CGFloat = 2.0
        }

        public struct TimeLabel {
            /// Left padding of `TimeLabel` from `MessageView`
            public static var leftPadding: CGFloat = 2.0
            public static var maxWidth: CGFloat = 200.0
        }

        public struct DisplayName {
            public static var height: CGFloat = 16.0

            /// Left padding of `DisplayName` from `ProfileImage`
            public static var leftPadding: CGFloat = 10.0

            /// Right padding of `DisplayName` from `ReceivedMessageView`. Used as lessThanOrEqualTo
            public static var rightPadding: CGFloat = 20.0
        }

        public struct MessageView {
            /// Left padding of `MessageView` from `ProfileImage`
            public static var leftPadding: CGFloat = 10.0

            /// Top padding of `MessageView` from `DisplayName`
            public static var topPadding: CGFloat = 2.0

            /// Bottom padding of `MessageView` from `TimeLabel`'s bottom
            public static var bottomPadding: CGFloat = 2.0
        }

        public static var cellPadding = Padding(left: 10, right: 60, top: 10, bottom: 10)

    }
}
