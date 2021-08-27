//
//  EduLink_Employee.swift
//  Centralis
//
//  Created by AW on 03/12/2020.
//

import Foundation

internal class EduLink_Employee {
    class internal func handle(_ employees: [[String : Any]]) {
        for employeeDict in employees {
            guard let employee = Employee(employeeDict) else { continue }
            EduLinkAPI.shared.authorisedSchool.schoolInfo.employees[employee.id.value] = employee
        }
    }
}
