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
    
    //Catering
    static let FailedCatering = Notification.Name("FailedCatering")
    static let SuccesfulCatering = Notification.Name("SuccesfulCatering")
}
