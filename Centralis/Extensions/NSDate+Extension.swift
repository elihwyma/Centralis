//
//  NSDate+Extension.swift
//  Centralis
//
//  Created by AW on 07/01/2021.
//

import UIKit

extension Date {
    func minutesBetweenDates(_ newDate: Date, _ invert: Bool) -> Int {
        let newDateMinutes = newDate.timeIntervalSinceReferenceDate/60
        let oldDateMinutes = self.timeIntervalSinceReferenceDate/60
        if invert {
            return Int(CGFloat(oldDateMinutes - newDateMinutes).rounded())
        } else {
            return Int(CGFloat(newDateMinutes - oldDateMinutes).rounded())
        }
    }
}
