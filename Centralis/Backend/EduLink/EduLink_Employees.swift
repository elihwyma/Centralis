//
//  EduLink_Employees.swift
//  Centralis
//
//  Created by Amy While on 30/08/2022.
//

import Foundation
import Evander

public final class Employees {
    
    public class func employees(_ completion: @escaping (String?, Bool) -> ()) {
        EvanderNetworking.edulinkDict(method: "EduLink.Employees", params: [.custom(key: "employee_ids", value: ["65"])]) { success, boop, message, bap in
            
        }
    }
    
}
