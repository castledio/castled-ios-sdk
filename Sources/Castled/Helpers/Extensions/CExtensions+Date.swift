//
//  Date+Extension.swift
//  Castled
//
//  Created by antony on 30/08/2023.
//

import Foundation
@_spi(CastledInternal)

public extension Date {
    static func from(epochTimestamp: TimeInterval) -> Date {
        return Date(timeIntervalSince1970: epochTimestamp)
    }

    func timeAgo(defaultFormat: String? = "MMM d, yyyy") -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.year, .month, .weekOfMonth, .day, .hour, .minute], from: self, to: now)
        /*  if let years = components.year, years > 0 {
             return "\(years) year\(years > 1 ? "s" : "") ago"
         } else if let months = components.month, months > 0 {
             return "\(months) month\(months > 1 ? "s" : "") ago"
         } else if let weeks = components.weekOfMonth, weeks > 0 {
             return "\(weeks) week\(weeks > 1 ? "s" : "") ago"
         }*/
        if self.timeIntervalSinceNow < -604800 { // One week has 604,800 seconds
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = defaultFormat
            return dateFormatter.string(from: self)
        } else
        if let days = components.day, days > 0 {
            if days >= 7 {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = defaultFormat
                return dateFormatter.string(from: self)
            } else {
                return "\(days) day\(days > 1 ? "s" : "") ago"
            }
        } else if let hours = components.hour, hours > 0 {
            return "\(hours)h ago"
        } else if let minutes = components.minute, minutes > 0 {
            return "\(minutes)m ago"
        } else {
            return "Now"
        }
    }

    func string(defaultFormat: String? = "yyyy-MM-dd'T'HH:mm:ss'Z'") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = defaultFormat
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        return dateFormatter.string(from: self)
    }
}
