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
        let params: [String : String] = [:]
        NetworkManager.requestWithDict(url: nil, requestMethod: "EduLink.Status", params: params, completion: { (success, dict) -> Void in
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
                    EduLinkAPI.shared.status.current = self.generateLesson(current)
                }
                if let next = lessons["next"] as? [String : Any] {
                    EduLinkAPI.shared.status.upcoming = self.generateLesson(next)
                }
            }
            rootCompletion(true, nil)
        })
    }
    
    class private func generateLesson(_ lesson: [String : Any]) -> MiniLesson {
        var ml = MiniLesson()
        if let room = lesson["room"] as? [String : Any] { ml.room = room["name"] as? String ?? "Not Given" }
        if let tg = lesson["teaching_group"] as? [String : Any] { ml.subject = tg["subject"] as? String ?? "Not Given" }
        if let start_time = lesson["start_time"] as? String { ml.startDate = UUID.dateFromTime(start_time) }
        if let end_time = lesson["end_time"] as? String { ml.endDate = UUID.dateFromTime(end_time) }
        return ml
    }
}

/// A container for Status
public struct Status {
    /// Number of new messages
    public var new_messages: Int!
    /// Number of new forms
    public var new_forms: Int!
    /// The Date of when the auth token expires
    public var expires: Date?
    /// The current lesson, usually shown on the Home Page. For more documentation see `MiniLesson`
    public var current: MiniLesson!
    /// The upcoming lesson, usually shown on the Home Page. For more documentation see `MiniLesson`
    public var upcoming: MiniLesson!
    
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
public struct MiniLesson {
    /// The time the lesson starts
    public var startDate: Date?
    /// The time the lesson ends
    public var endDate: Date?
    /// The room the lesson is in
    public var room: String!
    /// The subject for the lesson
    public var subject: String!
}
