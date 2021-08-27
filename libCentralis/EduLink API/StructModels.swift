//
//  StructModels.swift
//  Centralis
//
//  Created by AW on 30/11/2020.
//

import Foundation

/// A container for the Employee dictionary returned from EduLink
public struct Employee: Hashable, Codable {
    /// The Employee ID
    public var id: YouFuckers
    /// The Employee's Title
    public var title: String = "None"
    /// The forename of the Employee
    public var forename: String = "None"
    /// The surname of the Employee
    public var surname: String = "None"
    
    public var name: String {
        "\(title) \(forename) \(surname)"
    }
    
    init?(_ dict: [String: Any]) {
        do {
            guard let json = dict.json else { return nil }
            self = try JSONDecoder().decode(Employee.self, from: json)
        } catch {
            NSLog("[Centralis] Employee Error = \(error.localizedDescription)")
            return nil
        }
    }
}

/// A simple container for lots of dictionaries returned from EduLink
public struct SimpleStore {
    /// The belonging ID
    public var id: String
    /// The belonging Name
    public var name: String
    
    static func generate(_ array: [[String : Any]]) -> [SimpleStore] {
        var cache = [SimpleStore]()
        for a in array {
            let id = "\(a["id"] ?? "Not Given")"
            let name = "\(a["name"] ?? "Not Given")"
            let c = SimpleStore(id: id, name: name)
            cache.append(c)
        }
        return cache
    }
}

/// A container for classrooms
public struct Room: Codable {
    /// The ID of the room
    public var id: YouFuckers
    /// The name of the room
    public var name: String
    /// The shortened room code
    public var code: YouFuckers?
    
    init?(_ dict: [String: Any]) {
        do {
            guard let json = dict.json else { return nil }
            self = try JSONDecoder().decode(Room.self, from: json)
        } catch {
            NSLog("[Centralis] Room Error = \(error.localizedDescription)")
            return nil
        }
    }
}

/// A container for form groups
public struct FormGroup: Codable {
    /// The ID of the group
    public var id: YouFuckers
    /// The name of the group
    public var name: String
    /// The ID of the year group it belongs to
    public var year_group_ids: [YouFuckers]?
    /// The ID of the form tutor, for more documentation see `Employee`
    public var employee_id: YouFuckers?
    /// The ID of the form room, for more documentation see `Room`
    public var room_id: YouFuckers?
    
    init?(_ dict: [String: Any]) {
        do {
            guard let json = dict.json else { return nil }
            self = try JSONDecoder().decode(FormGroup.self, from: json)
        } catch {
            NSLog("[Centralis] FormGroup Error = \(String(describing: error)) \(dict)")
            return nil
        }
    }
}

/// A container for teaching group, or class
public struct TeachingGroup: Codable {
    /// The ID of the group
    public var id: YouFuckers
    /// The name of the group
    public var name: String
    /// The ID of the year group it belongs to
    public var year_group_ids: [YouFuckers]?
    /// The ID of the teacher, for more documentation see `Employee`
    public var employee_id: YouFuckers?
    public var subject: String?
    
    init?(_ dict: [String: Any]) {
        do {
            guard let json = dict.json else { return nil }
            self = try JSONDecoder().decode(TeachingGroup.self, from: json)
        } catch {
            NSLog("[Centralis] TeachingGroup Error = \(error.localizedDescription)")
            return nil
        }
    }
}

/// A container for subjects offered at the school
public struct Subject: Codable {
    /// The ID of the subject
    public var id: YouFuckers
    /// The name of the subject
    public var name: String
    /// If the subject is actively being offered at the school
    public var active: Bool
    
    init?(_ dict: [String: Any]) {
        do {
            guard let json = dict.json else { return nil }
            self = try JSONDecoder().decode(Subject.self, from: json)
        } catch {
            NSLog("[Centralis] Subject Error = \(error.localizedDescription)")
            return nil
        }
    }
}

/// Container for Report Card Target Type
public struct ReportCardTargetType: Codable {
    /// The ID of the report card
    public var id: YouFuckers
    /// The code belonging to the card
    public var code: String
    /// The description of the report card
    public var description: String
    
    init?(_ dict: [String: Any]) {
        do {
            guard let json = dict.json else { return nil }
            self = try JSONDecoder().decode(ReportCardTargetType.self, from: json)
        } catch {
            NSLog("[Centralis] ReportCardTargetType Error = \(error.localizedDescription)")
            return nil
        }
    }
}

public struct YouFuckers: Codable, Equatable, Hashable {
    public var value: String
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(String.self) {
            value = x
            return
        }
        if let x = try? container.decode(Int.self) {
            value = String(x)
            return
        }
        throw DecodingError.typeMismatch(YouFuckers.self, .init(codingPath: decoder.codingPath, debugDescription: "Failed to Parse You Fuckers"))
    }
}

public func == (lhs: YouFuckers, rhs: YouFuckers) -> Bool {
    lhs.value == rhs.value
}

extension Dictionary {
    var json: Data? {
        try? JSONSerialization.data(withJSONObject: self, options: [])
    }
}
