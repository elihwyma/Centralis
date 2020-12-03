//
//  EduLink_Employee.swift
//  Centralis
//
//  Created by Amy While on 03/12/2020.
//

import Foundation

class EduLink_Employee {
    public func handle(_ employees: [[String : Any]]) {
        for employee in employees {
            var a = Employee()
            a.id = Int((employee["id"])! as! String)
            a.forename = employee["forename"] as? String
            a.title = employee["title"] as? String
            a.surname = employee["surname"] as? String
            var isFound = false
            for e in EduLinkAPI.shared.employees where e.id == a.id {
                isFound = true
            }
            if !isFound {
                EduLinkAPI.shared.employees.append(a)
            }
        }
    }
}
