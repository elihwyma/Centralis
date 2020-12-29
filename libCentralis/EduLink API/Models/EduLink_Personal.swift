//
//  EduLink_Personal.swift
//  Centralis
//
//  Created by Amy While on 04/12/2020.
//

import Foundation

class EduLink_Personal {
    
    class func personal(_ rootCompletion: @escaping completionHandler) {
        let url = URL(string: "\(EduLinkAPI.shared.authorisedSchool.server!)?method=EduLink.Personal")!
        let headers: [String : String] = ["Content-Type" : "application/json;charset=utf-8"]
        let body = "{\"jsonrpc\":\"2.0\",\"method\":\"EduLink.Personal\",\"params\":{\"learner_id\":\"\(EduLinkAPI.shared.authorisedUser.id!)\",\"authtoken\":\"\(EduLinkAPI.shared.authorisedUser.authToken!)\"},\"uuid\":\"\(UUID.shared.uuid)\",\"id\":\"1\"}"
        NetworkManager.shared.requestWithDict(url: url, method: "POST", headers: headers, jsonbody: body, completion: { (success, dict) -> Void in
            if !success { return rootCompletion(false, "Network Error") }
            guard let result = dict["result"] as? [String : Any] else { return rootCompletion(false, "Unknown Error") }
            if !(result["success"] as? Bool ?? false) { return rootCompletion(false, "Unknown Error") }
            if let personal = result["personal"] as? [String : Any] {
                self.scrapeTime(personal)
            }
            rootCompletion(true, nil)
        })
    }
    
    class func scrapeTime(_ personal: [String : Any]) {
        EduLinkAPI.shared.personal.id = "\(personal["id"] ?? "Not Given")"
        EduLinkAPI.shared.personal.forename = personal["forename"] as? String ?? "Not Given"
        EduLinkAPI.shared.personal.surname = personal["surname"] as? String ?? "Not Given"
        EduLinkAPI.shared.personal.gender = personal["gender"] as? String ?? "Not Given"
        EduLinkAPI.shared.personal.admission_number = "\(personal["admission_number"] ?? "Not Given")"
        EduLinkAPI.shared.personal.unique_pupil_number = personal["unique_pupil_number"] as? String ?? "Not Given"
        EduLinkAPI.shared.personal.unique_learner_number = "\(personal["unique_learner_number"] ?? "Not Given")"
        EduLinkAPI.shared.personal.date_of_birth = personal["date_of_birth"] as? String ?? "Not Given"
        EduLinkAPI.shared.personal.admission_date = personal["admission_date"] as? String ?? "Not Given"
        EduLinkAPI.shared.personal.email = personal["email"] as? String ?? "Not Given"
        EduLinkAPI.shared.personal.phone = personal["phone"] as? String ?? "Not Given"
        EduLinkAPI.shared.personal.address = personal["address"] as? String ?? "Not Given"
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
            EduLinkAPI.shared.personal.form = form_group["name"] as? String ?? "Not Given"
            if let room = form_group["room"] as? [String : String] {
                EduLinkAPI.shared.personal.room_code = room["code"] ?? "Not Given"
            }
            if let employee = form_group["employee"] as? [String : String] {
                EduLinkAPI.shared.personal.form_teacher = "\(employee["title"] ?? "Not Given") \(employee["forename"] ?? "Not Given") \(employee["surname"] ?? "Not Given")"
            }
        }
        EduLinkAPI.shared.personal.year = (personal["year_group"] as? [String : String] ?? [String : String]())["name"] ?? "Not Given"
        EduLinkAPI.shared.personal.house_group = (personal["house_group"] as? [String : String] ?? [String : String]())["name"] ?? "Not Given"
    }
    
}

struct Personal {
    var id: String!
    var forename: String!
    var surname: String!
    var gender: String!
    var admission_number: String!
    var unique_pupil_number: String!
    var unique_learner_number: String!
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
