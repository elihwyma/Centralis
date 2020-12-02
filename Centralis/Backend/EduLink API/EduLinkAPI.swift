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
    var rooms = [Room]()
    var yearGroups = [YearGroup]()
    var communityGroups = [CommunityGroup]()
    var admissionGroups = [AdmissionGroup]()
    var intakeGroups = [IntakeGroup]()
    var formGroups = [FormGroup]()
    var teachingGroups = [TeachingGroup]()
    var subjects = [Subject]()
    var reportCardTargetTypes = [ReportCardTargetType]()
    var status = Status()
    var catering = Catering()
    
    public func login(schoolCode: String!, username: String!, password: String!) {
        let loginManager = LoginManager()
        loginManager.authenticate(schoolCode: schoolCode, username: username, password: password)
    }
    
    public func clear() {
        self.authorisedUser = AuthorisedUser()
        self.authorisedSchool = AuthorisedSchool()
        self.personalMenus = [PersonalMenu]()
        self.rooms = [Room]()
        self.yearGroups = [YearGroup]()
        self.communityGroups = [CommunityGroup]()
        self.admissionGroups = [AdmissionGroup]()
        self.intakeGroups = [IntakeGroup]()
        self.formGroups = [FormGroup]()
        self.teachingGroups = [TeachingGroup]()
        self.subjects = [Subject]()
        self.reportCardTargetTypes = [ReportCardTargetType]()
        self.status = Status()
        self.catering = Catering()
    }
}
