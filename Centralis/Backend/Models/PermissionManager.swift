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
    
    public enum Permission: CaseIterable {
        case timetable
        case documents
        case exams
        case behaviour
        case achievement
        case attendance
        case catering
        case homework
        case links
        case clubs
        case account
        case messages
    }
    
    public func reloadPermissions() {
        guard let menus = EdulinkManager.shared.authenticatedUser?.personal_menu else { return permissions.removeAll() }
        permissions = menus.compactMap { Permission(caseName: $0.name.lowercased()) }
        if EdulinkManager.shared.authenticatedUser?.capabilities?.communicator_enabled ?? false {
            permissions.append(.messages)
        }
    }
    
    public class func contains(_ permission: Permission) -> Bool {
        PermissionManager.shared.permissions.contains(permission)
    }
    
}

extension CaseIterable {

    init?(caseName: String) {
        for v in Self.allCases where "\(v)" == caseName {
            self = v
            return
        }
        return nil
    }
    
}
