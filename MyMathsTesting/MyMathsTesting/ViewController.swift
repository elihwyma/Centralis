//
//  ViewController.swift
//  MyMathsTesting
//
//  Created by Amy While on 01/02/2022.
//

import UIKit
import Evander
import WebKit
import SwiftSoup

let SCHOOLUSER = "calday"
let SCHOOLPASSWORD = "matrix"
let USERNAME = "2112"
let PASSWORD = "liw"

class ViewController: UIViewController {
    
    public var randomProperty = true
    
    public lazy var webView: WKWebView = {
        let webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        return webView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        _ = webView
        DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
            self.myMaths { error in
                print(error)
            }
        }
    }
    
    class func parseResponseForm(_ str: String) -> [String: String] {
        var response = [String: String]()
        let comps = str.components(separatedBy: "&")
        for comp in comps {
            let data = comp.components(separatedBy: "=")
            guard data.count == 2 else { continue }
            response[data[0]] = data[1]
        }
        return response
    }
    
    func getToken(from document: Document) throws -> String? {
        if let metaInfo = try document.select("meta").first(where: { (try? $0.attr("name")) == "csrf-token" }) {
            return try metaInfo.attr("content")
        }
        return nil
    }
    
    func getHomework(from document: Document) throws -> [(String, String)] {
        var parsedTasks: [(String, String)] = []
        let tasks = try document.select("div").filter { $0.hasClass("accordion-group accordion-blue") }
        for task in tasks {
            guard let linkButton = try task.select("div").last(where: { (try? $0.attr("class")) == "portal-button" }) else { continue }
            let linkButtonHref = try linkButton.select("a")
            let link = try linkButtonHref.attr("href")
            
            guard let nameRef = try task.select("div").first(where: { (try? $0.attr("class")) == "span9 offset1" }),
                  let p = try nameRef.select("p").first() else { continue }
            let text = try p.text()
            
            parsedTasks.append((text, link))
        }
        return parsedTasks
    }
    
    func getPrevious(from document: Document) throws -> [(String, String, Date, Int)] {
        var parsedTasks: [(String, String, Date, Int)] = []
        let tasks = try document.select("div").filter { $0.hasClass("accordion-group accordion-blue") }
        for task in tasks {
            let dateCompleted = Int(try task.attr("date_completed")) ?? 0
            let percent = Int(try task.attr("percent")) ?? 0
            let topic = try task.attr("topic")
            guard let linkButton = try task.select("div").last(where: { (try? $0.attr("class")) == "portal-button" }) else { continue }
            let linkButtonHref = try linkButton.select("a")
            let link = try linkButtonHref.attr("href")
            
            parsedTasks.append((topic, link, Date(timeIntervalSince1970: TimeInterval(dateCompleted)), percent))
        }
        return parsedTasks
    }
    
    let genericMyMathsHeaders: [String: String] = [
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
    
    public func myMaths(_ completion: @escaping (String?) -> ()) {
        HTTPCookieStorage.shared.cookies?.forEach(HTTPCookieStorage.shared.deleteCookie)
        var myMathsHeaders = genericMyMathsHeaders
        NSLog("[*] Attempting Login")
        RequestsHandler.request(url: "https://login.mymaths.co.uk/login", type: Data.self, method: "GET", headers: myMathsHeaders) { one, two, three, data in
            guard let data = data else { return }
            let str = String(decoding: data, as: UTF8.self)
            
            guard let doc: Document = try? SwiftSoup.parse(str) else { return completion("Failed to parse HTML") }
            let token = (try? self.getToken(from: doc)) ?? "lol"
            let formData: [String: String] = [
                "utf8": "✓",
                "authenticity_token": token,
                "_form_generated_at": "lol",
                "account[user_name]": SCHOOLUSER,
                "account[password]": SCHOOLPASSWORD,
                "commit": "Log+in"
            ]
            
            RequestsHandler.request(url: "https://login.mymaths.co.uk/login", type: Data.self, method: "POST", headers: myMathsHeaders, form: formData) { one, two, three, data in
                guard let data = data else { return }
                let str = String(decoding: data, as: UTF8.self)
                if str.contains("Your username or password doesn&#39;t look right. Please try again.") {
                    return completion("Incorrect Username/Password")
                }
                Thread.mainBlock {
                    self.webView.loadHTMLString(str, baseURL: nil)
                }
                NSLog("[*] Logged into school")
                guard let doc: Document = try? SwiftSoup.parse(str) else { return completion("Failed to parse HTML") }
                let token = (try? self.getToken(from: doc)) ?? "lol"
                let formData: [String: String] = [
                    "utf8": "✓",
                    "authenticity_token": token,
                    "student[user_name]": USERNAME,
                    "student[password]": PASSWORD,
                    "commit": "Log+in"
                ]

                myMathsHeaders["Referer"] = "https://app.mymaths.co.uk/myportal/library/9"
                myMathsHeaders.removeValue(forKey: "TE")
                RequestsHandler.request(url: "https://app.mymaths.co.uk/myportal/student/authenticate", type: Data.self, method: "POST", headers: myMathsHeaders, form: formData) { one, two, three, data in
                    guard let data = data else { return }
                    let str = String(decoding: data, as: UTF8.self)
                    Thread.mainBlock {
                        self.webView.loadHTMLString(str, baseURL: nil)
                    }
                    if str.contains("School username") {
                        NSLog("[x] Ditching Attempt, Trying Again")
                        return self.myMaths(completion)
                    }
                    NSLog("[*] Logged into User")
                    guard let doc: Document = try? SwiftSoup.parse(str) else { return completion("Failed to parse HTML") }
                    guard let parsedTasks = try? self.getHomework(from: doc) else { return completion("Failed to get tasks") }
                    
                    NSLog("[*] Getting list of previous tasks")
                    RequestsHandler.request(url: "https://app.mymaths.co.uk/myportal/student/my_results", type: Data.self, method: "GET", headers: myMathsHeaders) { one, two, three, data in
                        print("\(one) \(two) \(three) \(data)")
                        guard let data = data else { return }
                        let str = String(decoding: data, as: UTF8.self)
                        Thread.mainBlock {
                            self.webView.loadHTMLString(str, baseURL: nil)
                        }
                        guard let doc: Document = try? SwiftSoup.parse(str) else { return completion("Failed to parse HTML") }
                        guard let previousTasks = try? self.getPrevious(from: doc) else { return completion("Failed to get previous tasks") }
                        print(previousTasks)
                        guard !parsedTasks.isEmpty else { return completion("No Current Set Tasks") }
                        var index = 0
                        func doTask() {
                            self.completeTask(task: parsedTasks[index]) { error in
                                if let error = error {
                                    NSLog("[x] Error when completion: \(error)")
                                } else {
                                    index++
                                    if index == parsedTasks.count {
                                        return
                                    }
                                    doTask()
                                }
                            }
                        }
                        // doTask()
                    }
                }
            }
        }
    }
    
    public func completeTask(task: (String, String), completion: @escaping (String?) -> Void) {
        var myMathsHeaders = genericMyMathsHeaders
        NSLog("[*] Attempting Task \(task.0)")
        myMathsHeaders["Referer"] = "https://app.mymaths.co.uk/myportal/student/my_homework"
        RequestsHandler.request(url: "https://app.mymaths.co.uk\(task.1)", type: Data.self, headers: myMathsHeaders) { one, two, three, data in
            guard let data = data else { return }
            let str = String(decoding: data, as: UTF8.self)
            Thread.mainBlock {
                self.webView.loadHTMLString(str, baseURL: nil)
            }
            guard let range = str.range(of: "taskID="),
                  let taskID = String(str[range.upperBound...]).components(separatedBy: "&").first else {
                return completion("Failed to get task ID")
            }
            var realID = task.1
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
            NSLog("[*] Loaded Task")
            RequestsHandler.request(url: "https://app.mymaths.co.uk/api/legacy/auth", type: Data.self, method: "POST", headers: myMathsHeaders, form: formData) { one, two, three, data in
                guard let data = data else { return }
                let str = String(decoding: data, as: UTF8.self)
                
                let connectionData = Self.parseResponseForm(str)
                guard let authCode = connectionData["authCode"] else { return completion("Failed to get authCode") }
                let formData: [String: String] = [
                    "taskID": taskID,
                    "realID": _realID
                ]
                NSLog("[*] Authenticated Task")
                RequestsHandler.request(url: "https://app.mymaths.co.uk/api/legacy/launch", type: Data.self, method: "POST", headers: myMathsHeaders, form: formData) { one, two, three, data in
                    guard let data = data else { return }
                    let str = String(decoding: data, as: UTF8.self)
                    
                    var connectionData = Self.parseResponseForm(str)
                    guard connectionData["login"] == "1" else { return completion("Not Logged in???? 1") }
                    NSLog("[*] Launched Task")
                    RequestsHandler.request(url: "https://contentapi.mymaths.co.uk/partial_save", type: Data.self, method: "OPTIONS", headers: myMathsHeaders) { one, two, three, data in
                        guard two == 204 else { return }
                        
                        let formData: [String: String] = [
                            "taskID": taskID,
                            "realID": _realID,
                            "authToken": connectionData["authToken"] ?? "No Auth"
                        ]
                        NSLog("[*] Created Session")
                        RequestsHandler.request(url: "https://app.mymaths.co.uk/api/legacy/auth", type: Data.self, method: "POST", headers: myMathsHeaders, form: formData) { one, two, three, data in
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
                            NSLog("[*] Generated hash")
                            let formData: [String: String] = [
                                "taskID": taskID,
                                "realID": _realID,
                                "authToken": connectionData["authToken"] ?? "No Auth",
                                "q1score": "\(q1Score)",
                                "q2score": "\(q2Score)",
                                "q3score": "\(q3Score)",
                                "q4score": "\(q4Score)",
                                "sCode": "\(sCode)",
                                "studentID": connectionData["studentID"] ?? "No ID"
                            ]
                            RequestsHandler.request(url: "https://app.mymaths.co.uk/api/legacy/save/mark", type: Data.self, method: "POST", headers: myMathsHeaders, form: formData) { one, two, three, data in
                                guard two == 200 else { return completion("Failed to set mark") }
                                NSLog("[*] Successfully got full marks on \(task.0)")
                                completion(nil)
                            }
                        }
                    }
                }
            }
        }
    }

}

