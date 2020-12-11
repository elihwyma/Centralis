//
//  NSNotification+Extensions.swift
//  Shade
//
//  Created by Amy While on 26/10/2020.
//

import Foundation

extension NSNotification.Name {
    static let HidePopup = Notification.Name("Shade.HidePopup")
    static let NetworkError = Notification.Name("NetworkError")
    
    //Login
    static let InvalidSchool = Notification.Name("InvalidSchool")
    static let InvalidLogin = Notification.Name("InvalidLogin")
    static let SuccesfulLogin = Notification.Name("SuccesfulLogin")
    static let FailedLogin = Notification.Name("FailedLogin")
    
    //Status
    static let FailedStatus = Notification.Name("FailedStatus")
    static let SuccesfulStatus = Notification.Name("SuccesfulStatus")
    static let ReAuth = Notification.Name("Reauth")
    
    //Catering
    static let FailedCatering = Notification.Name("FailedCatering")
    static let SuccesfulCatering = Notification.Name("SuccesfulCatering")
    
    //Achievement
    static let FailedAchievement = Notification.Name("FailedAchievement")
    static let SuccesfulAchievement = Notification.Name("SuccesfulAchievement")
    
    //Personal
    static let FailedPersonal = Notification.Name("FailedPersonal")
    static let SuccesfulPersonal = Notification.Name("SuccesfulPersonal")

    //Homework
    static let FailedHomework = Notification.Name("FailedHomework")
    static let SuccesfulHomework = Notification.Name("SuccesfulHomework")
    static let SuccesfulHomeworkToggle = Notification.Name("SuccesfulToggle")
    static let SuccesfulHomeworkDetail = Notification.Name("SuccesfulHomeworkDetail")
    
    //Timetable
    static let FailedTimetable = Notification.Name("FailedTimetable")
    static let SuccesfulTimetable = Notification.Name("SuccesfulTimetable")
    static let TimetableButtonPressed = Notification.Name("TimetableButtonPressed")
    
    //Links
    static let FailedLink = Notification.Name("FailedLink")
    static let SuccesfulLink = Notification.Name("SuccesfulLink")
}
