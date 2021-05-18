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
            guard let id = employee["id"] as? String,
                  let forename = employee["forename"] as? String,
                  let title = employee["title"] as? String,
                  let surname = employee["surname"] as? String,
                  !EduLinkAPI.shared.authorisedSchool.schoolInfo.employees.contains(where: {$0.id == id} ) else { continue }
            let a = Employee(id: id, title: title, forename: forename, surname: surname)
            EduLinkAPI.shared.authorisedSchool.schoolInfo.employees.append(a)
        }
    }
}
