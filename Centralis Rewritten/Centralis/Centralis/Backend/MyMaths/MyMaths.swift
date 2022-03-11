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
    
    class private func getHomework(from document: SwiftSoup.Document) throws -> [(String, String)] {
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
    
    class private func getPrevious(from document: SwiftSoup.Document) throws -> [(String, String, Date, Int)] {
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
    
}
