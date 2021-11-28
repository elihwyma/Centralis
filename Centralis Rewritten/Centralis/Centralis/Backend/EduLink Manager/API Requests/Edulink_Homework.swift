//
//  Edulink_Homework.swift
//  Centralis
//
//  Created by Andromeda on 26/11/2021.
//

import Foundation
import Evander
import SerializedSwift
import SQLite

public final class Homework: EdulinkBase {
    
    @SerializedTransformable<DateConverter> var available_date: Date?
    @Serialized var completed: Bool
    @SerializedTransformable<DateConverter> var due_date: Date?
    @Serialized var description: String?
    @Serialized(default: "No Activity") var activity: String
    @Serialized var source: String
    @Serialized var set_by: String
    @Serialized var subject: String

    public lazy var notificationState: NotificationState = {
        if !isCurrent {
            return .past
        } else if isDueTomorrow {
            return .dayBefore
        } else {
            return .new
        }
    }()
    
    init(available_date: Date?, completed: Bool, due_date: Date?, description: String?, activity: String, source: String, set_by: String, subject: String, id: String) {
        super.init()
        self.available_date = available_date
        self.completed = completed
        self.due_date = due_date
        self.description = description
        self.activity = activity
        self.source = source
        self.set_by = set_by
        self.subject = subject
        self.id = id
    }
    
    public required init() {
        
    }
    
    public var isDueToday: Bool {
        if let due_date = due_date {
            return Calendar.current.isDateInToday(due_date)
        }
        return false
    }
    
    public var isCurrent: Bool {
        if let due_date = due_date {
            return Calendar.current.isDateInToday(due_date) || due_date > Date()
        }
        return false
    }
    
    public var isDueTomorrow: Bool {
        if let due_date = due_date {
            return Calendar.current.isDateInTomorrow(due_date)
        }
        return false
    }
    
    public class func updatedHomework(indexing: Bool = false, _ completion: @escaping (String?, [Homework]?) -> Void) {
        EvanderNetworking.edulinkDict(method: "EduLink.Homework", params: [.format(value: 2)]) { _, _, error, result in
            guard let result = result,
                  let homework = result["homework"] as? [String: Any],
                  let current = homework["current"] as? [[String: Any]],
                  let past = homework["past"] as? [[String: Any]],
                  let jsonCurrent = try? JSONSerialization.data(withJSONObject: current),
                  let jsonPast = try? JSONSerialization.data(withJSONObject: past) else { return completion(error ?? "Unknown Error", nil) }
            do {
                NSLog("\(current.count) \(past.count)")
                let current = try JSONDecoder().decode([Homework].self, from: jsonCurrent)
                let past = try JSONDecoder().decode([Homework].self, from: jsonPast)
                var allHomework = current + past
                if indexing {
                    return completion(nil, allHomework)
                } else {
                    PersistenceDatabase.HomeworkDatabase.changes(newHomework: &allHomework)
                    return completion(nil, allHomework)
                }
            } catch {
                return completion(error.localizedDescription, nil)
            }
        }
    }
    
    public func retrieveDescription(_ completion: @escaping (String?, String?) -> Void) {
        EvanderNetworking.edulinkDict(method: "EduLink.HomeworkDetails", params: [
            .custom(key: "source", value: source),
            .custom(key: "homework_id", value: id)
        ]) { [weak self] _, _, error, result in
            guard let result = result,
                  let homework = result["homework"] as? [String: Any],
                  let description = homework["description"] as? String else { return completion(error ?? "Unknown Error", nil) }
            if let `self` = self {
                self.description = description
                PersistenceDatabase.HomeworkDatabase.updateDescription(homework: self)
            }
            completion(nil, description)
        }
    }
    
    public func complete(complete: Bool, _ completion: @escaping (String?, Bool?) -> Void) {
        EvanderNetworking.edulinkDict(method: "EduLink.HomeworkCompleted", params: [
            .custom(key: "completed", value: complete ? "true" : "false"),
            .custom(key: "homework_id", value: id),
            .custom(key: "learner_id", value: EdulinkManager.shared.authenticatedUser?.learner_id ?? "-1"),
            .custom(key: "source", value: source)
        ]) { [weak self] _, _, error, result in
            if let error = error {
                completion(error, nil)
            } else {
                if let `self` = self {
                    self.completed = complete
                    PersistenceDatabase.HomeworkDatabase.updateCompleted(homework: self)
                }
                completion(nil, complete)
            }
        }
    }
    
    public enum NotificationState: Int64 {
        case new = 1
        case dayBefore = 2
        case past = 3
        case notified = 4
    }
}

public func == (lhs: Homework, rhs: Homework) -> Bool {
    lhs.id == rhs.id && lhs.due_date == rhs.due_date && lhs.activity == rhs.activity
}

