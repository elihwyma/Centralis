//
//  EduLinkAPI.swift
//  Centralis
//
//  Created by AW on 29/11/2020.
//

import Foundation

/// The main interface for libCentralis. This will contain any data that is recieved from the API.
public class EduLinkAPI {
    /// The shared instance, which should always be used
    public static let shared = EduLinkAPI()
    
    public var defaults: UserDefaults {
        UserDefaults.init(suiteName: "group.amywhile.centralis") ?? UserDefaults.standard
    }
    
    /// The user that is currently logged in, for more documentation see `AuthorisedUser`
    public var authorisedUser = AuthorisedUser()
    /// The school the current user is apart of, for more documentation see `AuthorisedSchool`
    public var authorisedSchool = AuthorisedSchool()
    /// The contained status, for more documentation see `Status`
    public var status = Status()
    /// The contained catering, for more documentation see `Catering`
    public var catering = Catering()
    /// The contained Achievement/Behaviour info, for more documentation see `AchievementBehaviourLookup`
    public var achievementBehaviourLookups = AchievementBehaviourLookup()
    /// The contained personal info, for more documentation see `Personal`
    public var personal: Personal?
    /// The contained homework, for more documentation see `Homeworks`
    public var homework = Homeworks()
    /// The contained timetable data, for more documentation see `Week`
    public var weeks = [Week]()
    /// The contained links, for more documentation see `Link`
    public var links = [Link]()
    /// The contained documents, for more documentation see `Document`
    public var documents = [Document]()
    /// The contained attendance data, for more documentation see `Attendance`
    public var attendance = Attendance()
    
    public var calendars = [iCal]()
    
    /// Will remove all contained data. This should be called when logging out
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
        self.personal = nil
    }
}
