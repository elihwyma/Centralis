//
//  DateTime.swift
//  Centralis
//
//  Created by Andromeda on 19/05/2021.
//

import Foundation

class DateTime {
    
    class func date(_ string: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale.current
        return formatter.date(from: string)
    }
    
    class internal func dateFromTime(time: String, date: Date? = nil) -> Date? {
        let calendar = NSCalendar.current
        var components = calendar.dateComponents([], from: date != nil ? date! : Date())
        let hour = time.components(separatedBy: ":")[0]
        let minute = time.components(separatedBy: ":")[1]
        components.hour = Int(hour) ?? 0
        components.minute = Int(minute) ?? 0
        return calendar.date(from: components)
    }
    
}

extension Date {
    
    var time: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
    
    var shortDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: self)
    }
    
}
