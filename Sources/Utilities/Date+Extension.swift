//
//  Date+Extension.swift
//
//
//  Created by Mukesh Thawani on 04/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import Foundation

extension Date {
    enum Formates {
        enum Time {
            static let twelve = "hh:mm a"
            static let twentyfour = "HH:mm"
        }

        enum DateAndTime {
            static let twelve = "dd/MM/yyyy, hh:mm a"
            static let twentyfour = "MM/dd/yyyy, HH:mm"
        }

        enum Date {
            static let twelve = "dd/MM/yyyy"
            static let twentyfour = "MM/dd/yyyy"
        }
    }

    /**
     @abstract Example - Assuming today is Friday 20 September 2017, we would show:
     Today, Yesterday, Wednesday, Tuesday, Monday, Sunday, Fri, Feb 24, Jun 3, 2016 (for previous year), Etc.
     */
    func stringCompareCurrentDate(showTodayTime: Bool = false) -> String {
        let calendar = Calendar.current
        let toDate: Date = calendar.startOfDay(for: Date())
        let fromDate: Date = calendar.startOfDay(for: self)
        let unitFlags: Set<Calendar.Component> = [.day]
        let differenceDateComponent: DateComponents = calendar.dateComponents(unitFlags, from: fromDate, to: toDate)

        guard let day = differenceDateComponent.day else {
            return ""
        }

        let dateFormatter = DateFormatter()

        if showTodayTime, day == 0 {
            let dateFormat = DateFormatter.dateFormat(fromTemplate: "HH:mm", options: 0, locale: Locale.current)
            dateFormatter.dateFormat = dateFormat
        } else if day < 2 {
            dateFormatter.dateStyle = .medium
            dateFormatter.doesRelativeDateFormatting = true
        } else {
            let fromTemplate = (day < 7 ? "EEEE" : "EdMMM")
            let dateFormat = DateFormatter.dateFormat(fromTemplate: fromTemplate, options: 0, locale: Locale.current)
            dateFormatter.dateFormat = dateFormat
        }

        return dateFormatter.string(from: self)
    }

    static func is24HrsFormate() -> Bool {
        let formatter = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: Locale.current)!
        return !formatter.contains("a")
    }

    static func formatedDate(formateString: String,
                             timeInMillSecs: Int64) -> String
    {
        let formatter = DateFormatter()
        formatter.dateFormat = formateString
        let date = Date(timeIntervalSince1970: TimeInterval(timeInMillSecs / 1000))
        return formatter.string(from: date)
    }
}
