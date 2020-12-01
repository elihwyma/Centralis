//
//  NSNotification+Extensions.swift
//  Shade
//
//  Created by Amy While on 26/10/2020.
//

import Foundation

extension NSNotification.Name {
    static let HidePopup = Notification.Name("Shade.HidePopup")
    static let FailedLogin = Notification.Name("FailedLogin")
    static let NetworkError = Notification.Name("NetworkError")
    static let InvalidSchool = Notification.Name("InvalidSchool")
    static let InvalidLogin = Notification.Name("InvalidLogin")
    static let SuccesfulLogin = Notification.Name("SuccesfulLogin")
}
