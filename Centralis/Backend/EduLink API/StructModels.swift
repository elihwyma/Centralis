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
    var image: Data!
    var schoolName: String!
    var forename: String!
    
    init(_ username: String!, _ password: String, _ schoolCode: String!, _ image: Data!, _ schoolName: String!, _ forename: String!) {
        self.username = username
        self.password = password
        self.schoolCode = schoolCode
        self.image = image
        self.schoolName = schoolName
        self.forename = forename
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



