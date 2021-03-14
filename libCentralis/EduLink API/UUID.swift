//
//  UUID.swift
//  Centralis
//
//  Created by AW on 02/12/2020.
//

import Foundation

internal class UUID {

    class private func randomString(_ length: Int) -> String {
      let letters = "abcdef0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }

    class internal var uuid: String {
        return "\(randomString(8))-\(randomString(4))-\(randomString(4))-\(randomString(4))-\(randomString(12))"
    }
    
    class internal func dateFromTime(_ time: String) -> Date? {
        let calendar = NSCalendar.current
        var components = calendar.dateComponents([.day,.month,.year], from: Date())
        let hour = time.components(separatedBy: ":")[0]
        let minute = time.components(separatedBy: ":")[1]
        components.hour = Int(hour) ?? 0
        components.minute = Int(minute) ?? 0
        return calendar.date(from: components)
    }
}
