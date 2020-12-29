//
//  EduLinkAPI.swift
//  Centralis
//
//  Created by Amy While on 29/11/2020.
//

import UIKit

class EduLinkAPI {
    static let shared = EduLinkAPI()
    
    var authorisedUser = AuthorisedUser()
    var authorisedSchool = AuthorisedSchool()
    var status = Status()
    var catering = Catering()
    var achievementBehaviourLookups = AchievementBehaviourLookup()
    var personal = Personal()
    var homework = Homeworks()
    var weeks = [Week]()
    var links = [Link]()
    var documents = [Document]()
    var attendance = Attendance()

    public func clear() {
        self.authorisedUser = AuthorisedUser()
        self.authorisedSchool = AuthorisedSchool()
        self.status = Status()
        self.catering = Catering()
        self.achievementBehaviourLookups = AchievementBehaviourLookup()
        self.homework = Homeworks()
        self.weeks = [Week]()
        self.links = [Link]()
        self.documents = [Document]()
        self.attendance = Attendance()
    }
}
