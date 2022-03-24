//
//  PermissionManager.swift
//  Centralis
//
//  Created by Amy While on 22/03/2022.
//

import Foundation
import Evander

final public class PermissionManager {
    
    public static let shared = PermissionManager()
    private(set) public var permissions = [Permission]()
    
    public enum Permission: String {
        case timetable = "Timetable"
        case documents = "Documents"
        case exams = "Exams"
        case behaviour = "Behaviour"
        case achievement = "Achievement"
        case attendance = "Attendance"
        case catering = "Catering"
        case homework = "Homework"
        case links = "Links"
        case clubs = "Clubs"
        case account = "Account Info"
        case messages = "Messages"
    }
    
    public func reloadPermissions() {
        guard let menus = EdulinkManager.shared.authenticatedUser?.personal_menu else { return permissions.removeAll() }
        permissions = menus.compactMap { Permission(rawValue: $0.name) }
        if EdulinkManager.shared.authenticatedUser?.capabilities?.communicator_enabled ?? false {
            permissions.append(.messages)
        }
    }
    
    public class func contains(_ permission: Permission) -> Bool {
        PermissionManager.shared.permissions.contains(permission)
    }
    
}
