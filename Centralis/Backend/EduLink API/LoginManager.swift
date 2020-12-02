//
//  LoginManager.swift
//  Centralis
//
//  Created by Amy While on 30/11/2020.
//

import UIKit

class LoginManager {
    
    var username: String!
    var password: String!
    var schoolCode: String!
    
    private func invalidLogin() {
        NotificationCenter.default.post(name: .InvalidLogin, object: nil)
        print("Invalid Login")
    }
    
    private func invalidSchool() {
        NotificationCenter.default.post(name: .InvalidSchool, object: nil)
        print("Invalid School")
    }
    
    private func fail() {
        NotificationCenter.default.post(name: .FailedLogin, object: nil)
        print("Failed Login")
    }
    
    private func network() {
        NotificationCenter.default.post(name: .NetworkError, object: nil)
        print("Network Error")
    }
    
    public func authenticate(schoolCode: String!, username: String!, password: String!) {
        self.username = username
        self.password = password
        self.schoolCode = schoolCode
        
        let body = "{\"jsonrpc\":\"2.0\",\"method\":\"School.FromCode\",\"params\":{\"code\":\"\(schoolCode!)\"},\"uuid\":\"FuckYouOvernetData\",\"id\":\"1\"}"
        NetworkManager.shared.requestWithDict(url: URL(string: "https://provisioning.edulinkone.com/?method=School.FromCode")!, method: "POST", headers: nil, jsonbody: body, completion: { (success, dict) -> Void in
            if success {
                if let result = dict["result"] as? [String : Any] {
                    if !(result["success"] as! Bool) {
                        if (result["error"] as! String).contains("Unknown SCHOOL ID") {
                            self.invalidSchool()
                        } else {
                            self.fail()
                        }
                        return
                    }
                    if let school = result["school"] as? [String : Any] {
                        EduLinkAPI.shared.authorisedSchool.server = school["server"] as? String
                        EduLinkAPI.shared.authorisedSchool.school_id = school["school_id"] as? Int
                        self.schoolInfo()
                    } else {
                        self.fail()
                    }
                } else {
                    self.fail()
                }
            } else {
                self.network()
            }
        })
    }
    
    private func login() {
        let url = URL(string: "\(EduLinkAPI.shared.authorisedSchool.server!)?method=EduLink.Login")!
        let headers: [String : String] = ["Content-Type" : "application/json;charset=utf-8"]
        let body = "{\"jsonrpc\":\"2.0\",\"method\":\"EduLink.Login\",\"params\":{\"from_app\":false,\"ui_info\":{\"format\":2,\"version\":\"0.5.113\",\"git_sha\":\"FuckYouOvernetData\"},\"fcm_token_old\":\"none\",\"username\":\"\(username!)\",\"password\":\"\(password!)\",\"establishment_id\":2},\"uuid\":\"FuckYouOvernetData\",\"id\":\"1\"}"
        NetworkManager.shared.requestWithDict(url: url, method: "POST", headers: headers, jsonbody: body, completion: { (success, dict) -> Void in
            if success {
                if let result = dict["result"] as? [String : Any] {
                    if !(result["success"] as! Bool) {
                        if (result["error"] as! String) == "The username or password is incorrect. Please try typing your password again" {
                            self.invalidLogin()
                        } else {
                            self.fail()
                        }
                        self.fail()
                        return
                    }
                    EduLinkAPI.shared.authorisedUser.authToken = result["authtoken"] as? String
                    if let user = result["user"] as? [String : Any] {
                        EduLinkAPI.shared.authorisedUser.id = Int((user["id"] as? String)!)
                        EduLinkAPI.shared.authorisedUser.gender = user["gender"] as? String
                        EduLinkAPI.shared.authorisedUser.forename = user["forename"] as? String
                        EduLinkAPI.shared.authorisedUser.surname = user["surname"] as? String
                        EduLinkAPI.shared.authorisedUser.community_group_id = Int((user["community_group_id"] as? String)!)
                        EduLinkAPI.shared.authorisedUser.form_group_id = Int((user["form_group_id"] as? String)!)
                        EduLinkAPI.shared.authorisedUser.year_group_id = Int((user["year_group_id"] as? String)!)
                        EduLinkAPI.shared.authorisedUser.types = user["types"] as? [String]
                        let avatar = user["avatar"] as! [String : Any]
                        let imageData = avatar["photo"] as? String
                        if let decodedData = Data(base64Encoded: imageData!, options: .ignoreUnknownCharacters) {
                            EduLinkAPI.shared.authorisedUser.avatar = UIImage(data: decodedData)
                        }
                    } else {
                        self.fail()
                    }
                    
                    self.personalMenu(result)
                    self.schoolScraping(result)
                    NotificationCenter.default.post(name: .SuccesfulLogin, object: nil)
                } else {
                    self.fail()
                }
            } else {
                self.network()
            }
        })
    }
    
    private func schoolInfo() {
        let body = "{\"jsonrpc\":\"2.0\",\"method\":\"EduLink.SchoolDetails\",\"params\":{\"establishment_id\":\"2\",\"from_app\":false},\"uuid\":\"FuckYouOvernetData\",\"id\":\"1\"}"
        let url = URL(string: "\(EduLinkAPI.shared.authorisedSchool.server!)?method=EduLink.SchoolDetails")
        let headers: [String : String] = ["Content-Type" : "application/json;charset=utf-8"]
        NetworkManager.shared.requestWithDict(url: url!, method: "POST", headers: headers, jsonbody: body, completion: { (success, dict) -> Void in
            if success {
                if let result = dict["result"] as? [String : Any] {
                    if !(result["success"] as! Bool) {
                        NotificationCenter.default.post(name: .FailedLogin, object: nil)
                        return
                    }
                    if let establishment = result["establishment"] as? [String : Any] {
                        let imageData = establishment["logo"] as? String
                        EduLinkAPI.shared.authorisedUser.school = establishment["name"] as? String
                        if let decodedData = Data(base64Encoded: imageData!, options: .ignoreUnknownCharacters) {
                            EduLinkAPI.shared.authorisedSchool.schoolLogo = UIImage(data: decodedData)
                        }
                        self.login()
                    } else {
                        self.fail()
                    }
                } else {
                    self.fail()
                }
            } else {
                self.network()
            }
        })
    }
    
    private func personalMenu(_ dict: [String : Any]) {
        if let personal_menu = dict["personal_menu"] as? [[String : String]] {
            for menu in personal_menu {
                var personalMenu = PersonalMenu()
                personalMenu.id = Int((menu["id"])!)
                personalMenu.name = menu["name"]
                EduLinkAPI.shared.personalMenus.append(personalMenu)
            }
        }
    }
    
    private func schoolScraping(_ dict: [String : Any]) {
        if let establishment = dict["establishment"] as? [String : Any] {
            //MARK: - Rooms
            if let rooms = establishment["rooms"] as? [[String : String]] {
                for room in rooms {
                    var roomMemory = Room()
                    roomMemory.id = Int((room["id"])!)
                    roomMemory.code = room["code"]
                    roomMemory.name = room["name"]
                    EduLinkAPI.shared.rooms.append(roomMemory)
                }
            }
            
            //MARK: - Year Groups
            if let year_groups = establishment["year_groups"] as? [[String : String]] {
                for yearGroup in year_groups {
                    var yg = YearGroup()
                    yg.id = Int((yearGroup["id"])!)
                    yg.name = yearGroup["name"]
                    EduLinkAPI.shared.yearGroups.append(yg)
                }
            }
            
            //MARK: - Community Groups
            if let community_groups = establishment["community_groups"] as? [[String : String]] {
                for communityGroup in community_groups {
                    var cg = CommunityGroup()
                    cg.id = Int((communityGroup["id"])!)
                    cg.name = communityGroup["name"]
                    EduLinkAPI.shared.communityGroups.append(cg)
                }
            }
            
            //MARK: - Admission Groups
            if let admission_groups = establishment["applicant_admission_groups"] as? [[String : String]] {
                for admissionGroup in admission_groups {
                    var ag = AdmissionGroup()
                    ag.id = Int((admissionGroup["id"])!)
                    ag.name = admissionGroup["name"]
                    EduLinkAPI.shared.admissionGroups.append(ag)
                }
            }
            
            //MARK: - Intake Groups
            if let intake_groups = establishment["applicant_intake_groups"] as? [[String : String]] {
                for intakeGroup in intake_groups {
                    var ig = IntakeGroup()
                    ig.id = Int((intakeGroup["id"])!)
                    ig.name = intakeGroup["name"]
                    EduLinkAPI.shared.intakeGroups.append(ig)
                }
            }
            
            //MARK: - Form Groups
            if let form_groups = establishment["form_groups"] as? [[String : Any]] {
                for formGroup in form_groups {
                    var fg = FormGroup()
                    fg.id = Int((formGroup["id"] as! String))
                    fg.employee_id = Int((formGroup["employee_id"] as? String ?? ""))
                    fg.room_id = Int((formGroup["room_id"] as? String)!)
                    fg.name = formGroup["name"] as? String
                    let ygid = formGroup["year_group_ids"] as? [String]
                    for yg in ygid! {
                        fg.year_group_ids.append(Int(yg)!)
                    }
                    EduLinkAPI.shared.formGroups.append(fg)
                }
            }
            
            //MARK: - Teaching Groups
            if let teaching_groups = establishment["teaching_groups"] as? [[String : Any]] {
                for teachingGroup in teaching_groups {
                    var tg = TeachingGroup()
                    tg.id = Int((teachingGroup["id"] as! String))
                    tg.employee_id = Int((teachingGroup["employee_id"] as? String ?? ""))
                    tg.name = teachingGroup["name"] as? String
                    let tgid = teachingGroup["year_group_ids"] as? [String]
                    for tgida in tgid! {
                        tg.year_group_ids.append(Int(tgida)!)
                    }
                    EduLinkAPI.shared.teachingGroups.append(tg)
                }
            }
            
            //MARK: - Subjects
            if let subjects = establishment["subjects"] as? [[String : Any]] {
                for subject in subjects {
                    var s = Subject()
                    s.id = Int((subject["id"] as! String))
                    s.name = subject["name"] as? String
                    s.active = subject["active"] as? Bool
                    EduLinkAPI.shared.subjects.append(s)
                }
            }
            
            //MARK: - Report Card Target Types
            if let report_card = establishment["report_card_target_types"] as? [[String : Any]] {
                for reportCard in report_card {
                    var rc = ReportCardTargetType()
                    rc.id = reportCard["id"] as? Int
                    rc.code = reportCard["name"] as? String
                    rc.description = reportCard["description"] as? String
                    EduLinkAPI.shared.reportCardTargetTypes.append(rc)
                }
            }
        }
    }
    
    public func saveLogins(schoolCode: String, username: String, password: String) {
        if let png = EduLinkAPI.shared.authorisedSchool.schoolLogo.pngData() {
            let decoder = JSONDecoder()
            let encoder = JSONEncoder()
            
            var l = UserDefaults.standard.object(forKey: "SavedLogins") as? [Data] ?? [Data]()
            var logins = [SavedLogin]()
            for login in l {
                if let a = try? decoder.decode(SavedLogin.self, from: login) {
                    logins.append(a)
                }
            }
            
            var changePassword = -1
            for (index, login) in logins.enumerated() where ((login.schoolCode == schoolCode) && (login.username == username)) {
                logins[index].password = password
                changePassword = index
                l.remove(at: index)
            }
            
            let newLogin = ((changePassword != -1) ? logins[changePassword] : SavedLogin(username, password, schoolCode, png, EduLinkAPI.shared.authorisedUser.school!, EduLinkAPI.shared.authorisedUser.forename!))

            if let encoded = try? encoder.encode(newLogin) {
                l.append(encoded)
            }

            UserDefaults.standard.setValue(l, forKey: "SavedLogins")
        }
    }

    public func removeLogin(uwuIn: SavedLogin) {
        let decoder = JSONDecoder()
        
        var l = UserDefaults.standard.object(forKey: "SavedLogins") as? [Data] ?? [Data]()
        var logins = [SavedLogin]()
        for login in l {
            if let a = try? decoder.decode(SavedLogin.self, from: login) {
                logins.append(a)
            }
        }
        
        for (index, login) in logins.enumerated() where ((login.schoolCode == uwuIn.schoolCode) && (login.username == uwuIn.username) && (login.password == uwuIn.password)) {
            l.remove(at: index)
        }
        
        UserDefaults.standard.setValue(l, forKey: "SavedLogins")
    }
}
