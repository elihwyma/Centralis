//
//  NSNotification+Extensions.swift
//  Shade
//
//  Created by AW on 26/10/2020.
//

import Foundation

/// A static list of Notifications used in the library
public extension NSNotification.Name {
    /// Is fired when the current authtoken has expired
    static let ReAuth = Notification.Name("Reauth")
    /// Is fired when the Timetable button in the app has been pressed
    static let TimetableButtonPressed = Notification.Name("TimetableButtonPressed")
    /// Learner Image Update
    static let LearnerImage = Notification.Name("LearnerImage")
    /// Settings Sign-Out
    static let SettingsSignOut = Notification.Name("Settings.Logout")
}
