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
    var personalMenus = [PersonalMenu]()
    var schoolInfo = SchoolInfo()
    var status = Status()
    var catering = Catering()
    var employees = [Employee]()
    var achievementBehaviourLookups = AchievementBehaviourLookup()
    var personal = Personal()
    
    public func login(schoolCode: String!, username: String!, password: String!) {
        let loginManager = LoginManager()
        loginManager.authenticate(schoolCode: schoolCode, username: username, password: password)
    }
    
    public func quickLogin(_ savedLogin: SavedLogin) {
        let loginManager = LoginManager()
        loginManager.schoolCode = savedLogin.schoolCode
        loginManager.username = savedLogin.username
        loginManager.password = savedLogin.password
        self.authorisedSchool.school_id = savedLogin.schoolID
        self.authorisedSchool.server = savedLogin.schoolServer
        loginManager.login()
    }
    
    public func clear() {
        self.authorisedUser = AuthorisedUser()
        self.authorisedSchool = AuthorisedSchool()
        self.personalMenus = [PersonalMenu]()
        self.schoolInfo = SchoolInfo()
        self.status = Status()
        self.catering = Catering()
        self.employees = [Employee]()
        self.achievementBehaviourLookups = AchievementBehaviourLookup()
    }
}
