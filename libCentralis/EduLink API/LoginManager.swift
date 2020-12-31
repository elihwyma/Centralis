//
//  LoginManager.swift
//  Centralis
//
//  Created by Amy While on 30/11/2020.
//

import UIKit

class LoginManager {
    
    static let shared = LoginManager()
    
    var username: String!
    var password: String!
    var schoolCode: String!
    
    public func schoolProvisioning(schoolCode: String!, _ rootCompletion: @escaping completionHandler) {
        self.schoolCode = schoolCode
        
        if self.schoolCode == "DemoSchool" {
            EduLinkAPI.shared.authorisedSchool.server = "https://demoapi.elihc.dev/api/uwu"
            EduLinkAPI.shared.authorisedSchool.school_id = "1"
            return rootCompletion(true, nil)
        }
        
        let body = "{\"jsonrpc\":\"2.0\",\"method\":\"School.FromCode\",\"params\":{\"code\":\"\(schoolCode!)\"},\"uuid\":\"\(UUID.shared.uuid)\",\"id\":\"1\"}"
        NetworkManager.requestWithDict(url: URL(string: "https://provisioning.edulinkone.com/?method=School.FromCode")!, method: "POST", headers: nil, jsonbody: body, completion: { (success, dict) -> Void in
            if !success { return rootCompletion(false, "Network Connection Error") }
            guard let result = dict["result"] as? [String : Any] else { return rootCompletion(false, "Unknown Error Ocurred") }
            if !(result["success"] as? Bool ?? false) {
                if (result["error"] as! String).contains("Unknown SCHOOL ID") {
                    return rootCompletion(false, "Invalid School Code")

                } else {
                    return rootCompletion(false, "Unknown Error Ocurred")
                }
            }
            guard let school = result["school"] as? [String : Any] else { return rootCompletion(false, "Unknown Error Ocurred") }
            EduLinkAPI.shared.authorisedSchool.server = school["server"] as? String
            EduLinkAPI.shared.authorisedSchool.school_id = "\(school["school_id"] ?? "Not Given")"
            self.schoolInfoz({ (success, error) -> Void in
                return rootCompletion(success, error)
            })
        })
    }
    
    private func schoolInfoz(_ zCompletion: @escaping completionHandler) {
        let body = "{\"jsonrpc\":\"2.0\",\"method\":\"EduLink.SchoolDetails\",\"params\":{\"establishment_id\":\"2\",\"from_app\":false},\"uuid\":\"FuckYouOvernetData\",\"id\":\"1\"}"
        let url = URL(string: "\(EduLinkAPI.shared.authorisedSchool.server!)?method=EduLink.SchoolDetails")
        let headers: [String : String] = ["Content-Type" : "application/json;charset=utf-8"]
        NetworkManager.requestWithDict(url: url!, method: "POST", headers: headers, jsonbody: body, completion: { (success, dict) -> Void in
            if !success { return zCompletion(false, "Network Connection Error") }
            guard let result = dict["result"] as? [String : Any] else { return zCompletion(false, "Unknown Error Ocurred") }
            if !(result["success"] as? Bool ?? false) { return zCompletion(false, "Unknown Error Ocurred") }
            guard let establishment = result["establishment"] as? [String : Any] else { return zCompletion(false, "Unknown Error Ocurred") }
            let imageData = establishment["logo"] as? String ?? ""
            EduLinkAPI.shared.authorisedUser.school = establishment["name"] as? String ?? "Not Given"
            if let decodedData = Data(base64Encoded: imageData, options: .ignoreUnknownCharacters) {
                EduLinkAPI.shared.authorisedSchool.schoolLogo = UIImage(data: decodedData)
            }
            return zCompletion(true, nil)
        })
    }

    public func loginz(username: String, password: String, _ rootCompletion: @escaping completionHandler) {
        self.username = username
        self.password = password
        let url = URL(string: "\(EduLinkAPI.shared.authorisedSchool.server!)?method=EduLink.Login")!
        let headers: [String : String] = ["Content-Type" : "application/json;charset=utf-8"]
        let body = "{\"jsonrpc\":\"2.0\",\"method\":\"EduLink.Login\",\"params\":{\"from_app\":false,\"ui_info\":{\"format\":2,\"version\":\"0.5.113\",\"git_sha\":\"FuckYouOvernetData\"},\"fcm_token_old\":\"none\",\"username\":\"\(username)\",\"password\":\"\(password)\",\"establishment_id\":2},\"uuid\":\"FuckYouOvernetData\",\"id\":\"1\"}"
        NetworkManager.requestWithDict(url: url, method: "POST", headers: headers, jsonbody: body, completion: { (success, dict) -> Void in
            if !success { return rootCompletion(false, "Network Connection Error") }
            guard let result = dict["result"] as? [String : Any] else { return rootCompletion(false, "Unknown Error Ocurred") }
            if !(result["success"] as? Bool ?? false) {
                if (result["error"] as! String) == "The username or password is incorrect. Please try typing your password again" {
                    return rootCompletion(false, "Incorrect Username/Password")
                } else {
                    return rootCompletion(false, "Unknown Error Ocurred")
                }
            }
            EduLinkAPI.shared.authorisedUser.authToken =  result["authtoken"] as? String
            guard let user = result["user"] as? [String : Any] else { return rootCompletion(false, "Unknown Error Ocurred") }
            EduLinkAPI.shared.authorisedUser.id = "\(user["id"] ?? "Not Given")"
            EduLinkAPI.shared.authorisedUser.gender = user["gender"] as? String ?? "Not Given"
            EduLinkAPI.shared.authorisedUser.forename = user["forename"] as? String ?? "Not Given"
            EduLinkAPI.shared.authorisedUser.surname = user["surname"] as? String ?? "Not Given"
            EduLinkAPI.shared.authorisedUser.community_group_id = "\(user["community_group_id"] ?? "Not Given")"
            EduLinkAPI.shared.authorisedUser.form_group_id = "\(user["form_group_id"] ?? "Not Given")"
            EduLinkAPI.shared.authorisedUser.year_group_id = "\(user["year_group_id"] ?? "Not Given")"
            EduLinkAPI.shared.authorisedUser.types = user["types"] as? [String] ?? [String]()
            if let avatar = user["avatar"] as? [String : Any] {
                let imageData = avatar["photo"] as? String ?? ""
                if let decodedData = Data(base64Encoded: imageData, options: .ignoreUnknownCharacters) {
                    EduLinkAPI.shared.authorisedUser.avatar = UIImage(data: decodedData)
                }
            }
            self.personalMenu(result)
            self.schoolScraping(result)
            EduLink_Register.registerCodes({(success, error) -> Void in })
            return rootCompletion(true, nil)
        })
    }
    
    public func quickLogin(_ savedLogin: SavedLogin, _ zCompletion: @escaping completionHandler) {
        EduLinkAPI.shared.clear()
        self.schoolCode = savedLogin.schoolCode
        guard let pdata = KeyChainManager.load(key: savedLogin.username) else { return zCompletion(false, "Error loading saved login") }
        let pstr = String(decoding: pdata, as: UTF8.self)
        EduLinkAPI.shared.authorisedSchool.school_id = savedLogin.schoolID
        EduLinkAPI.shared.authorisedSchool.server = savedLogin.schoolServer
        LoginManager.shared.loginz(username: savedLogin.username, password: pstr, { (success, error) -> Void in
            return zCompletion(success, error)
        })
    }
    
    public func saveLogin() {
        if self.schoolCode.isEmpty || self.username.isEmpty || self.password.isEmpty { return }
        guard let schoolLogo = EduLinkAPI.shared.authorisedSchool.schoolLogo else { return }
        guard let png = schoolLogo.pngData() else { return }
        let decoder = JSONDecoder()
        let encoder = JSONEncoder()
        
        var l = UserDefaults.standard.object(forKey: "LoginCache") as? [Data] ?? [Data]()
        var logins = [SavedLogin]()
        for login in l {
            if let a = try? decoder.decode(SavedLogin.self, from: login) {
                if a.username == self.username && a.schoolCode == self.schoolCode { return }
                logins.append(a)
            }
        }
        let a = SavedLogin(username: self.username, schoolServer: EduLinkAPI.shared.authorisedSchool.server, image: png, schoolName: EduLinkAPI.shared.authorisedUser.school, forename: EduLinkAPI.shared.authorisedUser.forename, surname: EduLinkAPI.shared.authorisedUser.surname, schoolID: EduLinkAPI.shared.authorisedSchool.school_id, schoolCode: self.schoolCode)
        if let encoded = try? encoder.encode(a) {
            l.append(encoded)
        }
        KeyChainManager.save(key: self.username, data: Data(password.utf8))
        UserDefaults.standard.setValue(l, forKey: "LoginCache")
    }

    public func removeLogin(uwuIn: SavedLogin) {
        let decoder = JSONDecoder()
        var l = UserDefaults.standard.object(forKey: "LoginCache") as? [Data] ?? [Data]()
        var logins = [SavedLogin]()
        for login in l {
            if let a = try? decoder.decode(SavedLogin.self, from: login) {
                logins.append(a)
            }
        }
        for (index, login) in logins.enumerated() where ((login.schoolCode == uwuIn.schoolCode) && (login.username == uwuIn.username)) {
            l.remove(at: index)
        }
        KeyChainManager.delete(key: uwuIn.username)
        UserDefaults.standard.setValue(l, forKey: "LoginCache")
    }

    private func personalMenu(_ dict: [String : Any]) {
        if let personal_menu = dict["personal_menu"] as? [[String : String]] {
            for menu in personal_menu {
                var personalMenu = SimpleStore()
                personalMenu.id = "\(menu["id"] ?? "Not Given")"
                personalMenu.name = menu["name"] ?? "Not Given"
                EduLinkAPI.shared.authorisedUser.personalMenus.append(personalMenu)
            }
        }
    }
    
    private func schoolScraping(_ dict: [String : Any]) {
        if let establishment = dict["establishment"] as? [String : Any] {
            //MARK: - Rooms
            if let rooms = establishment["rooms"] as? [[String : String]] {
                for room in rooms {
                    var roomMemory = Room()
                    roomMemory.id = "\(room["id"] ?? "Not Given")"
                    roomMemory.code = room["code"] ?? "Not Given"
                    roomMemory.name = room["name"] ?? "Not Given"
                    EduLinkAPI.shared.authorisedSchool.schoolInfo.rooms.append(roomMemory)
                }
            }
            
            //MARK: - Year Groups
            if let year_groups = establishment["year_groups"] as? [[String : String]] {
                for yearGroup in year_groups {
                    var yg = SimpleStore()
                    yg.id = "\(yearGroup["id"] ?? "Not Given")"
                    yg.name = yearGroup["name"] ?? "Not Given"
                    EduLinkAPI.shared.authorisedSchool.schoolInfo.yearGroups.append(yg)
                }
            }
            
            //MARK: - Community Groups
            if let community_groups = establishment["community_groups"] as? [[String : String]] {
                for communityGroup in community_groups {
                    var cg = SimpleStore()
                    cg.id = "\(communityGroup["id"] ?? "Not Given")"
                    cg.name = communityGroup["name"] ?? "Not Given"
                    EduLinkAPI.shared.authorisedSchool.schoolInfo.communityGroups.append(cg)
                }
            }
            
            //MARK: - Admission Groups
            if let admission_groups = establishment["applicant_admission_groups"] as? [[String : String]] {
                for admissionGroup in admission_groups {
                    var ag = SimpleStore()
                    ag.id = "\(admissionGroup["id"] ?? "Not Given")"
                    ag.name = admissionGroup["name"] ?? "Not Given"
                    EduLinkAPI.shared.authorisedSchool.schoolInfo.admissionGroups.append(ag)
                }
            }
            
            //MARK: - Intake Groups
            if let intake_groups = establishment["applicant_intake_groups"] as? [[String : String]] {
                for intakeGroup in intake_groups {
                    var ig = SimpleStore()
                    ig.id = "\(intakeGroup["id"] ?? "Not Given")"
                    ig.name = intakeGroup["name"] ?? "Not Given"
                    EduLinkAPI.shared.authorisedSchool.schoolInfo.intakeGroups.append(ig)
                }
            }
            
            //MARK: - Form Groups
            if let form_groups = establishment["form_groups"] as? [[String : Any]] {
                for formGroup in form_groups {
                    var fg = FormGroup()
                    fg.id = "\(formGroup["id"] ?? "Not Given")"
                    fg.employee_id = Int((formGroup["employee_id"] as? String ?? ""))
                    fg.room_id = Int((formGroup["room_id"] as? String)!)
                    fg.name = formGroup["name"] as? String
                    let ygid = formGroup["year_group_ids"] as? [String]
                    for yg in ygid! {
                        fg.year_group_ids.append(Int(yg)!)
                    }
                    EduLinkAPI.shared.authorisedSchool.schoolInfo.formGroups.append(fg)
                }
            }
            
            //MARK: - Teaching Groups
            if let teaching_groups = establishment["teaching_groups"] as? [[String : Any]] {
                for teachingGroup in teaching_groups {
                    var tg = TeachingGroup()
                    tg.id = "\(teachingGroup["id"] ?? "Not Given")"
                    tg.employee_id = Int((teachingGroup["employee_id"] as? String ?? ""))
                    tg.name = teachingGroup["name"] as? String
                    let tgid = teachingGroup["year_group_ids"] as? [String]
                    for tgida in tgid! {
                        tg.year_group_ids.append(Int(tgida)!)
                    }
                    EduLinkAPI.shared.authorisedSchool.schoolInfo.teachingGroups.append(tg)
                }
            }
            
            //MARK: - Subjects
            if let subjects = establishment["subjects"] as? [[String : Any]] {
                for subject in subjects {
                    var s = Subject()
                    s.id = "\(subject["id"] ?? "Not Given")"
                    s.name = subject["name"] as? String
                    s.active = subject["active"] as? Bool
                    EduLinkAPI.shared.authorisedSchool.schoolInfo.subjects.append(s)
                }
            }
            
            //MARK: - Report Card Target Types
            if let report_card = establishment["report_card_target_types"] as? [[String : Any]] {
                for reportCard in report_card {
                    var rc = ReportCardTargetType()
                    rc.id = "\(reportCard["id"] ?? "Not Given")"
                    rc.code = reportCard["name"] as? String
                    rc.description = reportCard["description"] as? String
                    EduLinkAPI.shared.authorisedSchool.schoolInfo.reportCardTargetTypes.append(rc)
                }
            }
        }
    }
}

struct SavedLogin: Codable {
    var username: String!
    var schoolCode: String!
    var schoolServer: String!
    var schoolName: String!
    var schoolID: String!
    var image: Data!
    var forename: String!
    var surname: String!
    
    init(username: String!, schoolServer: String!, image: Data!, schoolName: String!, forename: String!, surname: String!, schoolID: String!, schoolCode: String!) {
        self.username = username
        self.schoolServer = schoolServer
        self.image = image
        self.schoolName = schoolName
        self.forename = forename
        self.surname = surname
        self.schoolID = schoolID
        self.schoolCode = schoolCode
    }
}

struct AuthorisedUser {
    var authToken: String!
    var school: String!
    var forename: String!
    var surname: String!
    var gender: String!
    var id: String!
    var form_group_id: String!
    var year_group_id: String!
    var community_group_id: String!
    var avatar: UIImage!
    var types: [String]!
    var personalMenus = [SimpleStore]()
}

struct AuthorisedSchool {
    var server: String!
    var school_id: String!
    var schoolLogo: UIImage!
    var schoolInfo = SchoolInfo()
}

struct Room {
    var id: String!
    var name: String!
    var code: String!
}

struct FormGroup {
    var id: String!
    var name: String!
    var year_group_ids = [Int]()
    var employee_id: Int!
    var room_id: Int!
}

struct TeachingGroup {
    var id: String!
    var name: String!
    var year_group_ids = [Int]()
    var employee_id: Int!
}

struct Subject {
    var id: String!
    var name: String!
    var active: Bool!
}

struct ReportCardTargetType {
    var id: String!
    var code: String!
    var description: String!
}

struct SchoolInfo {
    var rooms = [Room]()
    var yearGroups = [SimpleStore]()
    var communityGroups = [SimpleStore]()
    var admissionGroups = [SimpleStore]()
    var intakeGroups = [SimpleStore]()
    var formGroups = [FormGroup]()
    var teachingGroups = [TeachingGroup]()
    var subjects = [Subject]()
    var reportCardTargetTypes = [ReportCardTargetType]()
    var employees = [Employee]()
    var lesson_codes = [RegisterCode]()
    var statutory_codes = [RegisterCode]()
}
