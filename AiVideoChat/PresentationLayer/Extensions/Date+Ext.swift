//
//  Date+Ext.swift
//  AiVideoChat
//
//  Created by Влад Шимченко on 22.06.2026.
//

import UIKit

extension Date {

    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }

    func monthYearString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL d"
        return formatter.string(from: self)
    }

    func timeString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: self)
    }

    func dayString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM"
        return formatter.string(from: self)
    }
}

extension DateFormatter {

    static let dolaISO8601: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds
        ]
        return formatter
    }()
}

extension String {

    func toDolaDate() -> Date? {
        return DateFormatter.dolaISO8601.date(from: self)
    }
}
