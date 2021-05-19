//
//  EduLink_Personal.swift
//  Centralis
//
//  Created by AW on 04/12/2020.
//

import Foundation

/// The model for handling Personal
public class EduLink_Personal {
    /// Retrieve the user personal info, `Personal`
    /// - Parameter rootCompletion: The completion handler, for more documentation see `completionHandler`
    class public func personal(learnerID: String = EduLinkAPI.shared.authorisedUser.id, _ rootCompletion: @escaping completionHandler) {
        let params: [String: AnyEncodable] = [
            "learner_id": AnyEncodable(learnerID)
        ]
        NetworkManager.requestWithDict(url: nil, requestMethod: "EduLink.Personal", params: params, completion: { (success, dict) -> Void in
            if !success { return rootCompletion(false, "Network Error") }
            guard let result = dict["result"] as? [String : Any] else { return rootCompletion(false, "Unknown Error") }
            guard result["success"] as? Bool ?? false,
               let personalDict = result["personal"] as? [String: Any] else { return rootCompletion(false, (result["error"] as? String ?? "Unknown Error")) }
            let personalCache = Personal(personalDict)
            if EduLinkAPI.shared.authorisedUser.id == learnerID { EduLinkAPI.shared.personal = personalCache } else {
                if let index = EduLinkAPI.shared.authorisedUser.children.firstIndex(where: {$0.id == learnerID}) {
                    EduLinkAPI.shared.authorisedUser.children[index].personal = personalCache
                }
            }
            rootCompletion(true, nil)
        })
    }
}

/// A container for personal
public struct Personal {
    /// The ID for the user
    public var id: String
    /// The forename for the user
    public var forename: String?
    /// The surname for the user
    public var surname: String?
    /// The gender of the user
    public var gender: String?
    /// The admission number of the user
    public var admission_number: String?
    /// The unique pupil number of the user
    public var unique_pupil_number: String?
    /// The unique learner number of the user
    public var unique_learner_number: String?
    /// The date of birth of the user
    public var date_of_birth: String?
    /// The admission date of the user
    public var admission_date: String?
    /// The email of the user
    public var email: String?
    /// The phone number registered for the user
    public var phone: String?
    /// The adress registered for the user
    public var address: String?
    /// The users form group
    public var form: String?
    /// The form room for the user
    public var room_code: String?
    /// The users form teacher
    public var form_teacher: Employee?
    /// The ethnicity of the user
    public var ethnicity: String?
    /// The national student ID of the user
    public var national_id: String?
    /// An array of langauges the user is fluent in
    public var languages = [String]()
    /// A personal note for the user
    public var note: String?
    /// The year the user is part of
    public var year: String?
    /// The house group of the user
    public var house_group: String?
    
    init(_ dict: [String: Any]) {
        if let id = dict["id"] {
            self.id = String(describing: id)
        } else {
            self.id = "Unknown"
        }
        self.forename = dict["forename"] as? String
        self.surname = dict["surname"] as? String
        self.gender = dict["gender"] as? String
        self.unique_pupil_number = dict["unique_pupil_number"] as? String
        if let ulnTmp = dict["unique_learner_number"] {
            self.unique_learner_number = String(describing: ulnTmp)
        }
        if let an = dict["admission_number"] {
            self.admission_number = String(describing: an)
        }
        self.date_of_birth = dict["date_of_birth"] as? String
        self.admission_date = dict["admission_date"] as? String
        self.email = dict["email"] as? String
        self.phone = dict["phone"] as? String
        self.address = dict["address"] as? String
        self.ethnicity = dict["ethnicity"] as? String
        self.national_id = dict["national_identity"] as? String
        if let languages = dict["languages"] as? [String: String] {
            for language in languages.values {
                self.languages.append(language)
            }
        } else {
            self.languages.append("Not Given")
        }
        
        if let form_group = dict["form_group"] as? [String : Any] {
            self.form = form_group["name"] as? String
            if let room = form_group["room"] as? [String : String] {
                self.room_code = room["code"]
            }
            if let employee = form_group["employee"] as? [String : String] {
                self.form_teacher = Employee(employee)
            }
        }
        self.year = (dict["year_group"] as? [String : String] ?? [String : String]())["name"]
        self.house_group = (dict["house_group"] as? [String : String] ?? [String : String]())["name"]
    }
    
    func name(_ string: String) -> String {
        switch string {
        case "forename": return "Forename"
        case "surname": return "Surname"
        case "gender": return "Gender"
        case "admission_number": return "Admission Number"
        case "unique_pupil_number": return "Pupil Number"
        case "unique_learner_number": return "Learner Number"
        case "date_of_birth": return "Date of Birth"
        case "admission_date": return "Admission Date"
        case "email": return "Email"
        case "phone": return "Phone"
        case "form": return "Form Group"
        case "room_code": return "Form Room"
        case "form_teacher": return "Form Teacher"
        case "house_group": return "House"
        case "year": return "Year"
        default: return "Error"
        }
    }
}
