//
//  EduLink_Message.swift
//  Centralis
//
//  Created by Andromeda on 27/08/2021.
//

import Foundation


public class EduLink_Messages {
    class public func messages(count: Int = 10, page: Int = 1,  _ rootCompletion: @escaping completionHandler) {
        let params: [String: AnyEncodable] = [
            "page": AnyEncodable(page),
            "per_page": AnyEncodable(count)
        ]
        NetworkManager.requestWithDict(url: nil, requestMethod: "Communicator.Inbox", params: params, completion: { (success, dict) -> Void in
            if !success { return rootCompletion(false, "Network Error") }
            guard let result = dict["result"] as? [String : Any] else { return rootCompletion(false, "Unknown Error") }
            if !(result["success"] as? Bool ?? false) { return rootCompletion(false, (result["error"] as? String ?? "Unknown Error")) }
            if let messages = result["messages"] as? [[String: Any]] {
                let messages = messages.compactMap { Message($0) }
                messages.forEach { message in
                    if !EduLinkAPI.shared.messages.contains(where: { $0.id.value == message.id.value }) {
                        EduLinkAPI.shared.messages.append(message)
                    }
                }
                EduLinkAPI.shared.messages.sort { $0.date > $1.date }
            }
            rootCompletion(true, nil)
        })
    }
}







public struct Message: Decodable {
    
    var id: YouFuckers
    var type: String
    var subject: String
    var body: String
    var date: Date
    var read: Date?
    var sender: Sender
    
    struct Sender: Decodable {
        var id: YouFuckers
        var type: String
        var name: String
    }
    
    init?(_ dict: [String: Any]) {
        do {
            guard let json = dict.json else { return nil }
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .custom({ decoder in
                let container = try decoder.singleValueContainer()
                guard let x = try? container.decode(String.self) else { return Date() }
                if let date = DateTime.date(x) {
                    return date
                } else if let date = DateTime.dateTime(x) {
                    return date
                } else if let date = DateTime.dateFromTime(time: x) {
                    return date
                }
                return Date()
            })
            self = try decoder.decode(Message.self, from: json)
        } catch {
            NSLog("[Centralis] Message Error = \(String(describing: error))")
            return nil
        }
    }
}
