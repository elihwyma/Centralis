//
//  EduLink_Homework.swift
//  Centralis
//
//  Created by Amy While on 05/12/2020.
//

import Foundation

class EduLink_Homework {
    
    class func homework(_ rootCompletion: @escaping completionHandler) {
        let url = URL(string: "\(EduLinkAPI.shared.authorisedSchool.server!)?method=EduLink.Homework")!
        let headers: [String : String] = ["Content-Type" : "application/json;charset=utf-8"]
        let body = "{\"jsonrpc\":\"2.0\",\"method\":\"EduLink.Homework\",\"params\":{\"format\":\"2\",\"authtoken\":\"\(EduLinkAPI.shared.authorisedUser.authToken!)\"},\"uuid\":\"\(UUID.shared.uuid)\",\"id\":\"1\"}"
        NetworkManager.requestWithDict(url: url, method: "POST", headers: headers, jsonbody: body, completion: { (success, dict) -> Void in
            if !success { return rootCompletion(false, "Network Error") }
            guard let result = dict["result"] as? [String : Any] else { return rootCompletion(false, "Unknown Error") }
            if !(result["success"] as? Bool ?? false) { return rootCompletion(false, (result["error"] as? String ?? "Unknown Error")) }
            if let homework = result["homework"] as? [String : Any] {
                if let current = homework["current"] as? [[String : Any]] {
                    self.scrapeLeWork(.current, dict: current)
                }
                if let past = homework["past"] as? [[String : Any]] {
                    self.scrapeLeWork(.past, dict: past)
                }
            }
            rootCompletion(true, nil)
        })
    }
    
    class func homeworkDetails(_ index: Int!, _ homework: Homework!, _ context: HomeworkContext, _ rootCompletion: @escaping completionHandler) {
        let url = URL(string: "\(EduLinkAPI.shared.authorisedSchool.server!)?method=EduLink.HomeworkDetails")!
        let headers: [String : String] = ["Content-Type" : "application/json;charset=utf-8"]
        let body = "{\"jsonrpc\":\"2.0\",\"method\":\"EduLink.HomeworkDetails\",\"params\":{\"homework_id\":\"\(homework.id!)\",\"source\":\"\(homework.source!)\",\"authtoken\":\"\(EduLinkAPI.shared.authorisedUser.authToken!)\"},\"uuid\":\"\(UUID.shared.uuid)\",\"id\":\"1\"}"
        NetworkManager.requestWithDict(url: url, method: "POST", headers: headers, jsonbody: body, completion: { (success, dict) -> Void in
            if !success { return rootCompletion(false, "Network Error") }
            guard let result = dict["result"] as? [String : Any] else { return rootCompletion(false, "Unknown Error") }
            if !(result["success"] as? Bool ?? false) { return rootCompletion(false, (result["error"] as? String ?? "Unknown Error")) }
            if let ab = result["homework"] as? [String : Any] {
                var hw = homework
                hw?.description = ab["description"] as? String ?? "Not Given"
                switch context {
                case .current: EduLinkAPI.shared.homework.current[index] = hw!
                case .past: EduLinkAPI.shared.homework.past[index] = hw!
                }
            }
            rootCompletion(true, nil)
        })
    }
    
    class func completeHomework(_ completed: Bool, _ index: Int, _ context: HomeworkContext, _ rootCompletion: @escaping completionHandler) {
        let homework: Homework!
        switch context{
        case .current: homework = EduLinkAPI.shared.homework.current[index]
        case .past: homework = EduLinkAPI.shared.homework.past[index]
        }
        let url = URL(string: "\(EduLinkAPI.shared.authorisedSchool.server!)?method=EduLink.HomeworkCompleted")!
        let headers: [String : String] = ["Content-Type" : "application/json;charset=utf-8"]
        let body = "{\"jsonrpc\":\"2.0\",\"method\":\"EduLink.HomeworkCompleted\",\"params\":{\"completed\":\"\(completed ? "true" : "false")\",\"homework_id\":\"\(homework.id!)\",\"learner_id\":\"\(EduLinkAPI.shared.authorisedUser.id!)\",\"source\":\"\(homework.source!)\",\"authtoken\":\"\(EduLinkAPI.shared.authorisedUser.authToken!)\"},\"uuid\":\"\(UUID.shared.uuid)\",\"id\":\"1\"}"
        NetworkManager.requestWithDict(url: url, method: "POST", headers: headers, jsonbody: body, completion: { (success, dict) -> Void in
            if !success { return rootCompletion(false, "Network Error") }
            guard let result = dict["result"] as? [String : Any] else { return rootCompletion(false, "Unknown Error") }
            if !(result["success"] as? Bool ?? false) { return rootCompletion(false, (result["error"] as? String ?? "Unknown Error")) }
            switch context {
            case .current: EduLinkAPI.shared.homework.current[index].completed = completed
            case .past: EduLinkAPI.shared.homework.past[index].completed = completed
            }
            rootCompletion(true, nil)
        })
    }
    
    class func scrapeLeWork(_ context: HomeworkContext, dict: [[String : Any]]) {
        switch context {
        case .current: EduLinkAPI.shared.homework.current.removeAll()
        case .past: EduLinkAPI.shared.homework.past.removeAll()
        }
        for h in dict {
            var homework = Homework()
            homework.id = "\(h["id"] ?? "Not Given")"
            homework.activity = h["activity"] as? String ?? "Not Given"
            homework.subject = h["subject"] as? String ?? "Not Given"
            homework.due_date = h["due_date"] as? String ?? "Not Given"
            homework.available_date = h["available_date"] as? String ?? "Not Given"
            homework.completed = h["completed"] as? Bool ?? false
            homework.set_by = h["set_by"] as? String ?? "Not Given"
            homework.due_text = h["due_text"] as? String ?? "Not Given"
            homework.available_text = h["available_text"] as? String ?? "Not Given"
            homework.status = h["status"] as? String ?? "Not Given"
            homework.source = h["source"] as? String ?? "Not Given"
            homework.description = h["description"] as? String ?? ""
            switch context {
            case .current: EduLinkAPI.shared.homework.current.append(homework)
            case .past: EduLinkAPI.shared.homework.past.append(homework)
            }
        }
        
        if context == .past { EduLinkAPI.shared.homework.past.reverse() }
    }
    
}

struct Homeworks {
    var current = [Homework]()
    var past = [Homework]()
}

struct Homework {
    var id: String!
    var activity: String!
    var subject: String!
    var due_date: String!
    var available_date: String!
    var completed: Bool!
    var set_by: String!
    var due_text: String!
    var available_text: String!
    var status: String!
    var description: String!
    var source: String!
}

enum HomeworkContext {
    case current
    case past
}
