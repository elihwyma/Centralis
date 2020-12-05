//
//  EduLink_Personal.swift
//  Centralis
//
//  Created by Amy While on 04/12/2020.
//

import Foundation

class EduLink_Personal {
    
    public func personal() {
        let url = URL(string: "\(EduLinkAPI.shared.authorisedSchool.server!)?method=EduLink.Personal")!
        let headers: [String : String] = ["Content-Type" : "application/json;charset=utf-8"]
        let body = "{\"jsonrpc\":\"2.0\",\"method\":\"EduLink.Personal\",\"params\":{\"learner_id\":\"\(EduLinkAPI.shared.authorisedUser.id!)\",\"authtoken\":\"\(EduLinkAPI.shared.authorisedUser.authToken!)\"},\"uuid\":\"\(UUID.shared.uuid)\",\"id\":\"1\"}"
        NetworkManager.shared.requestWithDict(url: url, method: "POST", headers: headers, jsonbody: body, completion: { (success, dict) -> Void in
            if success {
                if let result = dict["result"] as? [String : Any] {
                    if !(result["success"] as! Bool) {
                        NotificationCenter.default.post(name: .FailedPersonal, object: nil)
                        return
                    }
                    if let personal = result["personal"] as? [String : Any] {
                        self.scrapeTime(personal)
                    }
                    NotificationCenter.default.post(name: .SuccesfulPersonal, object: nil)
                } else {
                    NotificationCenter.default.post(name: .FailedPersonal, object: nil)
                }
            } else {
                NotificationCenter.default.post(name: .NetworkError, object: nil)
            }
        })
    }
    
    private func scrapeTime(_ personal: [String : Any]) {
        EduLinkAPI.shared.personal.id = Int((personal["id"] as! String))
        EduLinkAPI.shared.personal.forename = personal["forename"] as? String
        EduLinkAPI.shared.personal.surname = personal["surname"] as? String
        EduLinkAPI.shared.personal.gender = personal["gender"] as? String
        EduLinkAPI.shared.personal.admission_number = Int((personal["admission_number"] as! String))
        EduLinkAPI.shared.personal.unique_pupil_number = personal["unique_pupil_number"] as? String
        EduLinkAPI.shared.personal.unique_learner_number = Int((personal["unique_learner_number"] as! String))
        EduLinkAPI.shared.personal.date_of_birth = personal["date_of_birth"] as? String
        EduLinkAPI.shared.personal.admission_date = personal["admission_date"] as? String
        EduLinkAPI.shared.personal.email = personal["email"] as? String
        EduLinkAPI.shared.personal.phone = personal["phone"] as? String
        EduLinkAPI.shared.personal.address = personal["address"] as? String
        EduLinkAPI.shared.personal.ethnicity = personal["ethnicity"] as? String ?? "Not Given"
        EduLinkAPI.shared.personal.national_id = personal["national_identity"] as? String ?? "Not Given"
        EduLinkAPI.shared.personal.languages.removeAll()
        if let languages = personal["languages"] as? [String: String] {
            for language in languages.values {
                EduLinkAPI.shared.personal.languages.append(language)
            }
        } else {
            EduLinkAPI.shared.personal.languages.append("Not Given")
        }
        
        if let form_group = personal["form_group"] as? [String : Any] {
            EduLinkAPI.shared.personal.form = form_group["name"] as? String
            if let room = form_group["room"] as? [String : String] {
                EduLinkAPI.shared.personal.room_code = room["code"]
            }
            if let employee = form_group["employee"] as? [String : String] {
                EduLinkAPI.shared.personal.form_teacher = "\(employee["title"]!) \(employee["forename"]!) \(employee["surname"]!)"
            }
        }
        EduLinkAPI.shared.personal.year = (personal["year_group"] as? [String : String])!["name"]
        EduLinkAPI.shared.personal.house_group = (personal["house_group"] as? [String : String])!["name"]
    }
    
}

struct Personal {
    var id: Int!
    var forename: String!
    var surname: String!
    var gender: String!
    var admission_number: Int!
    var unique_pupil_number: String!
    var unique_learner_number: Int!
    var date_of_birth: String!
    var admission_date: String!
    var email: String!
    var phone: String!
    var address: String!
    var form: String!
    var room_code: String!
    var form_teacher: String!
    var ethnicity: String!
    var national_id: String!
    var languages = [String]()
    var note: String!
    var year: String!
    var house_group: String!
}
