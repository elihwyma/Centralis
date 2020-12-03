//
//  StructModels.swift
//  Centralis
//
//  Created by Amy While on 30/11/2020.
//

import UIKit

struct SavedLogin: Codable {
    var username: String!
    var password: String!
    var schoolCode: String!
    var schoolServer: String!
    var schoolName: String!
    var schoolID: Int!
    var image: Data!
    var forename: String!
    var surname: String!
    
    init(username: String!, password: String, schoolServer: String!, image: Data!, schoolName: String!, forename: String!, surname: String!, schoolID: Int!, schoolCode: String!) {
        self.username = username
        self.password = password
        self.schoolServer = schoolServer
        self.image = image
        self.schoolName = schoolName
        self.forename = forename
        self.surname = surname
        self.schoolID = schoolID
        self.schoolCode = schoolCode
    }
}

struct AuthorisedUser {
    var authToken: String!
    var school: String!
    var forename: String!
    var surname: String!
    var gender: String!
    var id: Int!
    var form_group_id: Int!
    var year_group_id: Int!
    var community_group_id: Int!
    var avatar: UIImage!
    var types: [String]!
}

struct AuthorisedSchool {
    var server: String!
    var school_id: Int!
    var schoolLogo: UIImage!
}

struct PersonalMenu {
    var id: Int!
    var name: String!
}

struct Room {
    var id: Int!
    var name: String!
    var code: String!
}

struct YearGroup {
    var id: Int!
    var name: String!
}

struct CommunityGroup {
    var id: Int!
    var name: String!
}

struct AdmissionGroup {
    var id: Int!
    var name: String!
}

struct IntakeGroup {
    var id: Int!
    var name: String!
}

struct FormGroup {
    var id: Int!
    var name: String!
    var year_group_ids = [Int]()
    var employee_id: Int!
    var room_id: Int!
}

struct TeachingGroup {
    var id: Int!
    var name: String!
    var year_group_ids = [Int]()
    var employee_id: Int!
}

struct Subject {
    var id: Int!
    var name: String!
    var active: Bool!
}

struct ReportCardTargetType {
    var id: Int!
    var code: String!
    var description: String!
}

struct SchoolInfo {
    var rooms = [Room]()
    var yearGroups = [YearGroup]()
    var communityGroups = [CommunityGroup]()
    var admissionGroups = [AdmissionGroup]()
    var intakeGroups = [IntakeGroup]()
    var formGroups = [FormGroup]()
    var teachingGroups = [TeachingGroup]()
    var subjects = [Subject]()
    var reportCardTargetTypes = [ReportCardTargetType]()
}

struct Status {
    var new_messages: Int!
    var new_forms: Int!
}

struct CateringTransaction {
    var id: Int!
    var date: String!
    var items = [CateringItem]()
}

struct CateringItem {
    var item: String!
    var price: Double!
}

struct Catering {
    var balance: Double!
    var transactions = [CateringTransaction]()
}

struct Employee {
    var id: Int!
    var title: String!
    var forename: String!
    var surname: String!
}

struct Achievement {
    var id: Int!
    var type_ids: [Int]!
    var activity_id: Int!
    var date: String!
    var employee_id: Int!
    var comments: String!
    var points: Int!
    var lesson_information: String!
    var live: Bool!
}

struct AchievementType {
    var id: Int!
    var active: Bool!
    var code: String!
    var description: String!
    var position: Int!
    var points: Int!
    var system: Bool!
}

struct AchievementActivityType {
    var id: Int!
    var code: String!
    var description: String!
    var active: Bool!
}

struct AchievementAwardType {
    var id: Int!
    var name: String!
}

struct BehaviourType {
    var id: Int!
    var active: Bool!
    var code: String!
    var description: String!
    var position: Int!
    var points: Int!
    var system: Bool!
    var include_in_register: Bool!
    var is_bullying_type: Bool!
}

struct AchievementBehaviourLookup {
    var achievements = [Achievement]()
    
    var achievement_types = [AchievementType]()
    var achievement_activity_types = [AchievementActivityType]()
    var achievement_award_types = [AchievementAwardType]()
    
    var achievement_points_editable: Bool!
    var detentionmanagement_enabled: Bool!
    
    var behaviour_types = [BehaviourType]()
}


