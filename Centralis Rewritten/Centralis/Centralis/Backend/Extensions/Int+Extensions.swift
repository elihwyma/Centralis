//
//  Int+Extensions.swift
//  Centralis
//
//  Created by Andromeda on 27/11/2021.
//

import Foundation

extension Double {
    
    public var int: Int {
        Int(self)
    }
    
    public var int64: Int64 {
        Int64(self)
    }
    
}

extension Date {
    
    public init?(timeSince1970: Int64?) {
        if let timeSince1970 = timeSince1970 {
            self.init(timeIntervalSince1970: TimeInterval(timeSince1970))
        }
        return nil
    }
    
    var dayAfter: Date {
        Calendar.current.date(byAdding: .day, value: 1, to: self)!
    }

    var dayBefore: Date {
        Calendar.current.date(byAdding: .day, value: -1, to: self)!
    }
    
    var dayName: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self)
    }
    
    func years(sinceDate: Date) -> Int {
        Calendar.current.dateComponents([.year], from: sinceDate, to: self).year!
    }

    func months(sinceDate: Date) -> Int {
        Calendar.current.dateComponents([.month], from: sinceDate, to: self).month!
    }

    func days(sinceDate: Date) -> Int {
        Calendar.current.dateComponents([.day], from: sinceDate, to: self).day!
    }

    func hours(sinceDate: Date) -> Int {
        Calendar.current.dateComponents([.hour], from: sinceDate, to: self).hour!
    }

    func minutes(sinceDate: Date) -> Int {
        Calendar.current.dateComponents([.minute], from: sinceDate, to: self).minute!
    }

    func seconds(sinceDate: Date) -> Int {
        Calendar.current.dateComponents([.second], from: sinceDate, to: self).second!
    }
}
