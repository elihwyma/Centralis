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
    
    public func login(schoolCode: String!, username: String!, password: String!) {
        let loginManager = LoginManager()
        loginManager.authenticate(schoolCode: schoolCode, username: username, password: password)
    }
}


