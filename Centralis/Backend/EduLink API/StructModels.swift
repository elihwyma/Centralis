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
    
    init(_ username: String!, _ password: String, _ schoolServer: String!, _ image: Data!, _ schoolName: String!, _ forename: String!, _ surname: String!, _ schoolID: Int!, _ schoolCode: String!) {
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


