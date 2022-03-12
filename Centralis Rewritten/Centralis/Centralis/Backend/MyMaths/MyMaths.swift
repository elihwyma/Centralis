//
//  MyMaths.swift
//  Centralis
//
//  Created by Somica on 11/03/2022.
//

import Foundation
import Evander
import SwiftSoup

final public class MyMaths {
    
    static let shared = MyMaths()
    
    public struct MyMathsLogin: Codable {
        var schoolUser: String
        var schoolPass: String
        var username: String
        var password: String
        
        init(schoolUser: String, schoolPass: String, username: String, password: String) {
            self.schoolUser = schoolUser
            self.schoolPass = schoolPass
            self.username = username
            self.password = password
        }
    }
    
    public class CurrentTasks {
        let name: String
        let url: String
        
        init(name: String, url: String) {
            self.name = name
            self.url = url
        }
    }
    
    public class PastTasks: CurrentTasks {
        let date: Date
        let percent: Int
        
        init(name: String, url: String, date: Date, percent: Int) {
            self.date = date
            self.percent = percent
            super.init(name: name, url: url)
        }
    }
    
    private let genericMyMathsHeaders: [String: String] = [
        "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8",
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:96.0) Gecko/20100101 Firefox/96.0",
        "Accept-Encoding": "gzip, deflate, br",
        "Accept-Language": "en-GB,en;q=0.5",
        "DNT": "1",
        "Sec-Fetch-Dest": "document",
        "Sec-Fetch-Mode": "navigate",
        "Sec-Fetch-Site": "same-origin",
        "Sec-Fetch-User": "?1",
        "TE": "trailers",
        "Upgrade-Insecure-Requests": "1",
        "Referer": "https://login.mymaths.co.uk/login"
    ]
    
    class private func parseResponseForm(_ str: String) -> [String: String] {
        var response = [String: String]()
        let comps = str.components(separatedBy: "&")
        for comp in comps {
            let data = comp.components(separatedBy: "=")
            guard data.count == 2 else { continue }
            response[data[0]] = data[1]
        }
        return response
    }
    
    class private func getToken(from document: SwiftSoup.Document) throws -> String? {
        if let metaInfo = try document.select("meta").first(where: { (try? $0.attr("name")) == "csrf-token" }) {
            return try metaInfo.attr("content")
        }
        return nil
    }
    
    class private func getHomework(from document: SwiftSoup.Document) throws -> [CurrentTasks] {
        var parsedTasks = [CurrentTasks]()
        let tasks = try document.select("div").filter { $0.hasClass("accordion-group accordion-blue") }
        for task in tasks {
            guard let linkButton = try task.select("div").last(where: { (try? $0.attr("class")) == "portal-button" }) else { continue }
            let linkButtonHref = try linkButton.select("a")
            let link = try linkButtonHref.attr("href")
            
            guard let nameRef = try task.select("div").first(where: { (try? $0.attr("class")) == "span9 offset1" }),
                  let p = try nameRef.select("p").first() else { continue }
            let text = try p.text()
            
            parsedTasks.append(.init(name: text, url: link))
        }
        return parsedTasks
    }
    
    class private func getPrevious(from document: SwiftSoup.Document) throws -> [PastTasks] {
        var parsedTasks = [PastTasks]()
        let tasks = try document.select("div").filter { $0.hasClass("accordion-group accordion-blue") }
        for task in tasks {
            let dateCompleted = Int(try task.attr("date_completed")) ?? 0
            let percent = Int(try task.attr("percent")) ?? 0
            let topic = try task.attr("topic")
            guard let linkButton = try task.select("div").last(where: { (try? $0.attr("class")) == "portal-button" }) else { continue }
            let linkButtonHref = try linkButton.select("a")
            let link = try linkButtonHref.attr("href")
            
            parsedTasks.append(.init(name: topic, url: link, date: Date(timeIntervalSince1970: TimeInterval(dateCompleted)), percent: percent))
        }
        return parsedTasks
    }
    
    public func completeTask(task: CurrentTasks, logging: @escaping (String) -> Void, completion: @escaping (String?) -> Void) {
        var myMathsHeaders = genericMyMathsHeaders
        logging("[*] Attempting Task \(task.name)")
        myMathsHeaders["Referer"] = "https://app.mymaths.co.uk/myportal/student/my_homework"
        EvanderNetworking.request(url: "https://app.mymaths.co.uk\(task.url)", type: Data.self, headers: myMathsHeaders) { one, two, three, data in
            guard let data = data else { return }
            let str = String(decoding: data, as: UTF8.self)

            guard let range = str.range(of: "taskID="),
                  let taskID = String(str[range.upperBound...]).components(separatedBy: "&").first else {
                return completion("Failed to get task ID")
            }
            var realID = task.url
            realID.removeFirst()
            guard let _realID = realID.components(separatedBy: "-").first else {
                return completion("Failed to get task real ID")
            }
            
            myMathsHeaders["Referer"] = "https://static.mymaths.co.uk"
            let formData: [String: String] = [
                "taskID": taskID,
                "realID": _realID,
                "authToken": ""
            ]
            logging("[*] Loaded Task")
            EvanderNetworking.request(url: "https://app.mymaths.co.uk/api/legacy/auth", type: Data.self, method: "POST", headers: myMathsHeaders, form: formData) { one, two, three, data in
                guard let data = data else { return }
                let str = String(decoding: data, as: UTF8.self)
                
                let connectionData = Self.parseResponseForm(str)
                guard let authCode = connectionData["authCode"] else { return completion("Failed to get authCode") }
                let formData: [String: String] = [
                    "taskID": taskID,
                    "realID": _realID
                ]
                logging("[*] Authenticated Task")
                EvanderNetworking.request(url: "https://app.mymaths.co.uk/api/legacy/launch", type: Data.self, method: "POST", headers: myMathsHeaders, form: formData) { one, two, three, data in
                    guard let data = data else { return }
                    let str = String(decoding: data, as: UTF8.self)
                    
                    var connectionData = Self.parseResponseForm(str)
                    guard connectionData["login"] == "1" else { return completion("Not Logged in???? 1") }
                    logging("[*] Launched Task")
                    EvanderNetworking.request(url: "https://contentapi.mymaths.co.uk/partial_save", type: Data.self, method: "OPTIONS", headers: myMathsHeaders) { one, two, three, data in
                        guard two == 204 else { return }
                        
                        let formData: [String: String] = [
                            "taskID": taskID,
                            "realID": _realID,
                            "authToken": connectionData["authToken"] ?? "No Auth"
                        ]
                        logging("[*] Created Session")
                        EvanderNetworking.request(url: "https://app.mymaths.co.uk/api/legacy/auth", type: Data.self, method: "POST", headers: myMathsHeaders, form: formData) { one, two, three, data in
                            guard let data = data else { return }
                            let str = String(decoding: data, as: UTF8.self)
                            connectionData = Self.parseResponseForm(str)
                            guard connectionData["logged"] == "yes" else { return completion("Not Logged in???? 2") }
   
                            let q1Score = 99
                            let q2Score = 99
                            let q3Score = 99
                            let q4Score = 99
                            let _taskID = Int(taskID) ?? 0
                            let authCode = Int(authCode) ?? 0
                            var sCode = _taskID * authCode
                            sCode = sCode + q1Score * 100 + q2Score
                            sCode *= 10000
                            sCode = sCode + _taskID * _taskID
                            logging("[*] Generated hash")
                            
                            guard let _authToken = connectionData["authToken"],
                                  let studentID = connectionData["studentID"] else {
                                      return completion("Failed to get Student ID from MyMaths")
                            }
                            
                            let formData: [String: String] = [
                                "taskID": taskID,
                                "realID": _realID,
                                "authToken": _authToken,
                                "q1score": "\(q1Score)",
                                "q2score": "\(q2Score)",
                                "q3score": "\(q3Score)",
                                "q4score": "\(q4Score)",
                                "sCode": "\(sCode)",
                                "studentID": studentID
                            ]
                            EvanderNetworking.request(url: "https://app.mymaths.co.uk/api/legacy/save/mark", type: Data.self, method: "POST", headers: myMathsHeaders, form: formData) { one, two, three, data in
                                guard two == 200 else { return completion("Failed to set mark") }
                                logging("[*] Successfully got full marks on \(task.name)")
                                completion(nil)
                            }
                        }
                    }
                }
            }
        }
    }
    
    public func getTasks(login: MyMathsLogin, logging: @escaping (String) -> Void, count: Int = 0, _ completion: @escaping (String?, [CurrentTasks]?, [PastTasks]?) -> ()) {
        HTTPCookieStorage.shared.cookies?.forEach(HTTPCookieStorage.shared.deleteCookie)
        guard Reachability.shared.connected else {
            return completion("[x] No Active Internet Connection", nil, nil)
        }
        var myMathsHeaders = genericMyMathsHeaders
        logging("[*] Attempting Login")
        EvanderNetworking.request(url: "https://login.mymaths.co.uk/login", type: Data.self, method: "GET", headers: myMathsHeaders) { one, two, three, data in
            guard let data = data else { return }
            let str = String(decoding: data, as: UTF8.self)
            
            guard let doc = try? SwiftSoup.parse(str) else { return completion("Failed to parse HTML", nil, nil) }
            let token = (try? Self.getToken(from: doc)) ?? "lol"
            let formData: [String: String] = [
                "utf8": "✓",
                "authenticity_token": token,
                "_form_generated_at": "lol",
                "account[user_name]": login.schoolUser,
                "account[password]": login.schoolPass,
                "commit": "Log+in"
            ]
            
            EvanderNetworking.request(url: "https://login.mymaths.co.uk/login", type: Data.self, method: "POST", headers: myMathsHeaders, form: formData) { one, two, three, data in
                guard let data = data else { return }
                let str = String(decoding: data, as: UTF8.self)
                if str.contains("Your username or password doesn&#39;t look right. Please try again.") {
                    return completion("Incorrect Username/Password", nil, nil)
                }

                logging("[*] Logged into school")
                guard let doc = try? SwiftSoup.parse(str) else { return completion("Failed to parse HTML", nil, nil) }
                let token = (try? Self.getToken(from: doc)) ?? "lol"
                let formData: [String: String] = [
                    "utf8": "✓",
                    "authenticity_token": token,
                    "student[user_name]": login.username,
                    "student[password]": login.password,
                    "commit": "Log+in"
                ]

                myMathsHeaders["Referer"] = "https://app.mymaths.co.uk/myportal/library/9"
                myMathsHeaders.removeValue(forKey: "TE")
                EvanderNetworking.request(url: "https://app.mymaths.co.uk/myportal/student/authenticate", type: Data.self, method: "POST", headers: myMathsHeaders, form: formData) { one, two, three, data in
                    guard let data = data else { return }
                    let str = String(decoding: data, as: UTF8.self)

                    if str.contains("School username") {
                        if count == 15 {
                            logging("[x] Too many failed attempts, are you sure your details are correct?")
                            return completion("Failed to login", nil, nil)
                        } else {
                            logging("[x] Ditching Attempt, Trying Again")
                            return self.getTasks(login: login, logging: logging, count: count + 1, completion)
                        }
                    }
                    logging("[*] Logged into User")
                    guard let doc = try? SwiftSoup.parse(str) else { return completion("Failed to parse HTML", nil, nil) }
                    guard let parsedTasks = try? Self.getHomework(from: doc) else { return completion("Failed to get tasks", nil, nil) }
                    
                    logging("[*] Getting list of previous tasks")
                    EvanderNetworking.request(url: "https://app.mymaths.co.uk/myportal/student/my_results", type: Data.self, method: "GET", headers: myMathsHeaders) { one, two, three, data in
                        guard let data = data else { return }
                        let str = String(decoding: data, as: UTF8.self)
                        
                        guard let doc = try? SwiftSoup.parse(str) else { return completion("Failed to parse HTML", nil, nil) }
                        guard let previousTasks = try? Self.getPrevious(from: doc) else { return completion("Failed to get previous tasks", nil, nil) }
                        logging("[*] Got list of previous tasks")
                        completion(nil, parsedTasks, previousTasks)
                    }
                }
            }
        }
    }
}

