//
//  EduLink-Status.swift
//  Centralis
//
//  Created by AW on 02/12/2020.
//

import Foundation

/// The model for getting status info
public class EduLink_Status {
    /// Retrieve status for the currently logged in user, for more documentation see `Status`
    /// - Parameter rootCompletion: The completion handler, for more documentation see `completionHandler`
    class public func status(rootCompletion: @escaping completionHandler) {
        NetworkManager.requestWithDict(url: nil, requestMethod: "EduLink.Status", completion: { (success, dict) -> Void in
            if !success { return rootCompletion(false, "Network Error") }
            guard let result = dict["result"] as? [String : Any] else { return rootCompletion(false, "Unknown Error Ocurred") }
            if !(result["success"] as? Bool ?? false) { return rootCompletion(false, "Unknown Error Ocurred") }
            EduLinkAPI.shared.status.new_messages = result["new_messages"] as? Int ?? 0
            EduLinkAPI.shared.status.new_forms = result["new_forms"] as? Int ?? 0
            if let session = result["session"] as? [String : Any] {
                let interval: TimeInterval = Double(session["expires"] as? Int ?? 0)
                EduLinkAPI.shared.status.expires = Date() + interval
            }
            if let lessons = result["lessons"] as? [String : Any] {
                if let current = lessons["current"] as? [String : Any] {
                    EduLinkAPI.shared.status.current = MiniLesson(current)
                }
                if let next = lessons["next"] as? [String : Any] {
                    EduLinkAPI.shared.status.upcoming = MiniLesson(next)
                }
            }
            rootCompletion(true, nil)
        })
    }
}

/// A container for Status
public struct Status {
    /// Number of new messages
    public var new_messages: Int = 0
    /// Number of new forms
    public var new_forms: Int = 0
    /// The Date of when the auth token expires
    public var expires: Date?
    /// The current lesson, usually shown on the Home Page. For more documentation see `MiniLesson`
    public var current: MiniLesson?
    /// The upcoming lesson, usually shown on the Home Page. For more documentation see `MiniLesson`
    public var upcoming: MiniLesson?
        
    /// The public init method for the class
    public init() {}
    
    /// Checks if the current auth token has expired. If the token is expired, will fire the notification ReAuth.
    public func hasExpired() {
        if let expires = self.expires {
            if expires > Date() {
                NotificationCenter.default.post(name: .ReAuth, object: nil)
            }
        }
    }
}

/// A container for a MiniLesson belonging to `Status`
public struct MiniLesson: Codable {
    /// The time the lesson starts
    public var startDate: Date?
    /// The time the lesson ends
    public var endDate: Date?
    /// The room the lesson is in
    public var room: Room?
    /// The subject for the lesson
    public var teaching_group: TeachingGroup?
    
    public var teacher: Employee?
    
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
            self = try decoder.decode(MiniLesson.self, from: json)
        } catch {
            NSLog("[Centralis] MiniLesson Error = \(String(describing: error))")
            return nil
        }
    }
}
