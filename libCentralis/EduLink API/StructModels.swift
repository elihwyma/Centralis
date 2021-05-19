//
//  StructModels.swift
//  Centralis
//
//  Created by AW on 30/11/2020.
//

import Foundation

/// A container for the Employee dictionary returned from EduLink
public struct Employee: Hashable {
    /// The Employee ID
    public var id: String
    /// The Employee's Title
    public var title: String = "None"
    /// The forename of the Employee
    public var forename: String = "None"
    /// The surname of the Employee
    public var surname: String = "None"
    
    public var name: String
    
    init?(_ dict: [String: Any]) {
        guard let tmpID = dict["id"] else { return nil }
        self.id = String(describing: tmpID)
        var nameCache = ""
        if let title = dict["title"] as? String {
            nameCache += title + " "
            self.title = title
        }
        if let forename = dict["forename"] as? String {
            nameCache += forename + " "
            self.forename = forename
        }
        if let surname = dict["surname"] as? String {
            nameCache += surname
            self.surname = surname
        }
        if nameCache.last == " " {
            nameCache.removeLast()
        }
        self.name = nameCache
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
