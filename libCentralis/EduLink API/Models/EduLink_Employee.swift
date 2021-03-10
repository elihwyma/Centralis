//
//  EduLink_Employee.swift
//  Centralis
//
//  Created by AW on 03/12/2020.
//

import Foundation

internal class EduLink_Employee {
    class internal func handle(_ employees: [[String : Any]]) {
        for employee in employees {
            var a = Employee()
            a.id = "\(employee["id"] ?? "Not Given")"
            let isFound = EduLinkAPI.shared.authorisedSchool.schoolInfo.employees.contains(where: {$0.id == a.id} )
            if isFound { continue }
            a.forename = employee["forename"] as? String ?? "Not Given"
            a.title = employee["title"] as? String ?? "Not Given"
            a.surname = employee["surname"] as? String ?? "Not Given"
            EduLinkAPI.shared.authorisedSchool.schoolInfo.employees.append(a)
        }
    }
}
