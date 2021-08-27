//
//  EduLink_Homework.swift
//  Centralis
//
//  Created by AW on 05/12/2020.
//

import Foundation

/// A model for working with homework
public class EduLink_Homework {
    /// Retrieve a list of current and past homework of the user. For more documentation see `Homeworks`
    /// - Parameter rootCompletion: The completion handler, for more documentation see `completionHandler`
    class public func homework(learnerID: String = EduLinkAPI.shared.authorisedUser.id, _ rootCompletion: @escaping completionHandler) {
        let params: [String: AnyEncodable] = [
            "learner_id": AnyEncodable(learnerID)
        ]
        NetworkManager.requestWithDict(url: nil, requestMethod: "EduLink.Homework", params: params, completion: { (success, dict) -> Void in
            if !success { return rootCompletion(false, "Network Error") }
            guard let result = dict["result"] as? [String : Any] else { return rootCompletion(false, "Unknown Error") }
            if !(result["success"] as? Bool ?? false) { return rootCompletion(false, (result["error"] as? String ?? "Unknown Error")) }
            if let homework = result["homework"] as? [String : Any] {
                if let currentDict = homework["current"] as? [[String : Any]] {
                    let current = currentDict.compactMap({ Homework($0) }).sorted(by: { $0.due_date ?? Date() < $1.due_date ?? Date() })
                    EduLinkAPI.shared.homework.current = current
                }
                if let pastDict = homework["past"] as? [[String : Any]] {
                    let past = pastDict.compactMap({ Homework($0) }).sorted(by: { $0.due_date ?? Date() > $1.due_date ?? Date() })
                    EduLinkAPI.shared.homework.past = past
                }
            }
            rootCompletion(true, nil)
        })
    }
    
    /// Retrieve the description of a homework
    /// - Parameters:
    ///   - index: The array index of the homework in it's respective array
    ///   - homework: The homework object
    ///   - context: If the homework is current or past
    ///   - rootCompletion: The completion handler, for more documentation see `completionHandler`
    class public func homeworkDetails(learnerID: String = EduLinkAPI.shared.authorisedUser.id, _ index: Int!, _ homework: Homework!, _ context: HomeworkContext, _ rootCompletion: @escaping completionHandler) {
        let params: [String: AnyEncodable] = [
            "source": AnyEncodable(homework.source),
            "homework_id": AnyEncodable(homework.id)
        ]
        NetworkManager.requestWithDict(url: nil, requestMethod: "EduLink.HomeworkDetails", params: params, completion: { (success, dict) -> Void in
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
    
    /// Toggle if a homework is marked as completed or not
    /// - Parameters:
    ///   - completed: If the homework should be marked as completed or not
    ///   - index: The array index of the homework in it's respective array
    ///   - context: If the homework is current or past
    ///   - rootCompletion: The completion handler, for more documentation see `completionHandler`
    class public func completeHomework(learnerID: String = EduLinkAPI.shared.authorisedUser.id, _ completed: Bool, _ index: Int, _ context: HomeworkContext, _ rootCompletion: @escaping completionHandler) {
        let homework: Homework!
        switch context{
        case .current: homework = EduLinkAPI.shared.homework.current[index]
        case .past: homework = EduLinkAPI.shared.homework.past[index]
        }
        let params: [String: AnyEncodable] = [
            "learner_id" : AnyEncodable(learnerID),
            "completed" : AnyEncodable(completed ? "true" : "false"),
            "homework_id" : AnyEncodable(homework.id),
            "source" : AnyEncodable(homework.source)
        ]
        NetworkManager.requestWithDict(url: nil, requestMethod: "EduLink.HomeworkCompleted", params: params, completion: { (success, dict) -> Void in
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
}

/// A container for current and past homeworks
public struct Homeworks {
    /// An array of current homeworks, for more documentation see `Homework`
    public var current = [Homework]()
    /// An array of past homeworks, for more documentation see `Homework`
    public var past = [Homework]()
}

/// A container for Homework
public struct Homework {
    /// The ID of the homework
    public var id: String
    /// The title of the homework
    public var activity: String?
    /// The subject of the homework
    public var subject: String?
    /// The due date of the homework
    public var due_date: Date?
    /// The date of when the homework was made available
    public var available_date: Date?
    /// Is the homework marked as completed
    public var completed: Bool
    /// The teacher who set the homework
    public var set_by: String?
    /// The set due text
    public var due_text: String?
    /// The set available text
    public var available_text: String?
    /// The status of the homework
    public var status: String?
    /// The description of the homework
    public var description: String?
    /// The source of the homewor
    public var source: String
    
    init?(_ dict: [String: Any]) {
        guard let tmpID = dict["id"] else { return nil }
        self.id = String(describing: tmpID)
        self.activity = dict["activity"] as? String
        self.subject = dict["subject"] as? String
        if let tmpDueDate = dict["due_date"] as? String,
           let due_date = DateTime.date(tmpDueDate) {
            self.due_date = due_date
        }
        if let tmpAvailableDate = dict["available_date"] as? String,
           let available_date = DateTime.dateTime(tmpAvailableDate) {
            self.available_date = available_date
        }
        self.completed = dict["completed"] as? Bool ?? false
        self.set_by = dict["set_by"] as? String
        self.due_text = dict["due_text"] as? String
        self.available_text = dict["available_text"] as? String
        self.status = dict["status"] as? String
        self.source = dict["source"] as? String ?? "EduLink"
        self.description = dict["description"] as? String
    }
}

/// An enum for if the homework is current or past
public enum HomeworkContext {
    /// If the homework is set for a date in the future
    case current
    /// If the homework due date has passed
    case past
}
