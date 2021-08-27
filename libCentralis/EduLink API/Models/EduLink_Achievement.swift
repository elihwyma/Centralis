//
//  EduLink_Achievement.swift
//  Centralis
//
//  Created by AW on 03/12/2020.
//

import Foundation

/// A model for working with Achievements and Behaviours
public class EduLink_Achievement {
    class private func achievementBehaviourLookups(_ rootCompletion: @escaping completionHandler) {
        NetworkManager.requestWithDict(url: nil, requestMethod: "EduLink.AchievementBehaviourLookups", completion: { (success, dict) -> Void in
            if !success { return rootCompletion(false, "Network Error") }
            guard let result = dict["result"] as? [String : Any] else { return rootCompletion(false, "Unknown Error") }
            if !(result["success"] as? Bool ?? false) { return rootCompletion(false, (result["error"] as? String ?? "Unknown Error")) }
            var achievementBehaviourLookups = AchievementBehaviourLookup()
            achievementBehaviourLookups = EduLinkAPI.shared.achievementBehaviourLookups
            if let achievement_types = result["achievement_types"] as? [[String : Any]] {
                for achievement_typeDict in achievement_types {
                    if let achievement_type = AchievementType(achievement_typeDict) {
                        achievementBehaviourLookups.achievement_types.append(achievement_type)
                    }
                }
            }
            if let achievement_activity_types = result["achievement_activity_types"] as? [[String : Any]] {
                achievementBehaviourLookups.achievement_activity_types.removeAll()
                for achievement_activity_typeDict in achievement_activity_types {
                    if let achievement_activity_type = AchievementActivityType(achievement_activity_typeDict) {
                        achievementBehaviourLookups.achievement_activity_types.append(achievement_activity_type)
                    }
                }
            }
            if let achievement_award_types = result["achievement_award_types"] as? [[String : Any]] { achievementBehaviourLookups.achievement_award_types = SimpleStore.generate(achievement_award_types) }
            if let behaviour_types = result["behaviour_types"] as? [[String : Any]] {
                for behaviour_typeDict in behaviour_types {
                    if let behaviour_type = BehaviourType(behaviour_typeDict) {
                        achievementBehaviourLookups.behaviour_types.append(behaviour_type)
                    }
                }
            }
            if let behaviour_activity_types = result["behaviour_activity_types"] as? [[String : Any]] {
                for behaviour_activity_typeDict in behaviour_activity_types {
                    if let behaviour_activity_type = BehaviourActivityType(behaviour_activity_typeDict) {
                        achievementBehaviourLookups.behaviour_activity_types.append(behaviour_activity_type)
                    }
                }
            }
            if let behaviour_actions_taken = result["behaviour_actions_taken"] as? [[String : Any]] { achievementBehaviourLookups.behaviour_actions_taken = SimpleStore.generate(behaviour_actions_taken) }
            if let behaviour_bullying_types = result["behaviour_bullying_types"] as? [[String : Any]] { achievementBehaviourLookups.behaviour_bullying_types = SimpleStore.generate(behaviour_bullying_types) }
            if let behaviour_locations = result["behaviour_locations"] as? [[String : Any]] { achievementBehaviourLookups.behaviour_locations = SimpleStore.generate(behaviour_locations) }
            if let behaviour_statuses = result["behaviour_statuses"] as? [[String : Any]] { achievementBehaviourLookups.behaviour_statuses = SimpleStore.generate(behaviour_statuses) }
            if let behaviour_times = result["behaviour_times"] as? [[String : Any]] { achievementBehaviourLookups.behaviour_times = SimpleStore.generate(behaviour_times) }
            EduLinkAPI.shared.achievementBehaviourLookups = achievementBehaviourLookups
            rootCompletion(true, nil)
        })
    }
    
    /// Retrieve the achievements of the user, for more documentation see `Achievement`
    /// - Parameter rootCompletion: The completion handler, for more documentation see `completionHandler`
    class public func achievement(learnerID: String = EduLinkAPI.shared.authorisedUser.id, _ zCompletion: @escaping completionHandler) {
        let params: [String: AnyEncodable] = [
            "learner_id": AnyEncodable(learnerID)
        ]
        NetworkManager.requestWithDict(url: nil, requestMethod: "EduLink.Achievement", params: params, completion: { (success, dict) -> Void in
            if !success { return zCompletion(false, "Network Error") }
            guard let result = dict["result"] as? [String: Any] else { return zCompletion(false, "Unknown Error") }
            if !(result["success"] as? Bool ?? false) { return zCompletion(false, "Unknown Error") }
            if let employees = result["employees"] as? [[String: Any]] {
                EduLink_Employee.handle(employees)
            }
            var achievementsCache = [Achievement]()
            if let achievement = result["achievement"] as? [[String : Any]] {
                for achievementDict in achievement {
                    if let achievement = Achievement(achievementDict) {
                        achievementsCache.append(achievement)
                    }
                }
            }
            
            EduLinkAPI.shared.achievementBehaviourLookups.achievements = achievementsCache
            if EduLinkAPI.shared.achievementBehaviourLookups.achievement_types.isEmpty { return self.achievementBehaviourLookups(zCompletion) } else { zCompletion(true, nil)}
        })
    }
    
    /// Retrieve the behaviours of the user, for more documentation see `Behaviour`
    /// - Parameter rootCompletion: The completion handler, for more documentation see `completionHandler`
    class public func behaviour(learnerID: String = EduLinkAPI.shared.authorisedUser.id, _ zCompletion: @escaping completionHandler) {
        let params: [String: AnyEncodable] = [
            "learner_id": AnyEncodable(learnerID)
        ]
        NetworkManager.requestWithDict(url: nil, requestMethod: "EduLink.Behaviour", params: params, completion: { (success, dict) -> Void in
            if !success { return zCompletion(false, "Network Error") }
            guard let result = dict["result"] as? [String : Any] else { return zCompletion(false, "Unknown Error") }
            if !(result["success"] as? Bool ?? false) { return zCompletion(false, "Unknown Error") }
            if let employees = result["employees"] as? [[String : Any]] {
                EduLink_Employee.handle(employees)
            }
            var achievementBehaviourLookups = EduLinkAPI.shared.achievementBehaviourLookups
            var behaviourCache = [Behaviour]()
            if let behaviours = result["behaviour"] as? [[String : Any]] {
                for behaviourDict in behaviours {
                    if let behaviour = Behaviour(behaviourDict) {
                        NSLog("[Centralis] Appending Behaviour")
                        behaviourCache.append(behaviour)
                    }
                }
            }
            var b4lCache = [BehaviourForLesson]()
            achievementBehaviourLookups.behaviours = behaviourCache
            if let b4l = result["b4l"] as? [[String : Any]] {
                for b4lDict in b4l {
                    if let b4l = BehaviourForLesson(b4lDict) {
                        b4lCache.append(b4l)
                    }
                }
            }
            achievementBehaviourLookups.behaviourForLessons = b4lCache
            var detentionCache = [Detention]()
            if let detentions = result["detentions"] as? [[String : Any]] {
                for detentionDict in detentions {
                    if let detention = Detention(detentionDict) {
                        detentionCache.append(detention)
                    }
                }
            }
            achievementBehaviourLookups.detentions = detentionCache
            EduLinkAPI.shared.achievementBehaviourLookups = achievementBehaviourLookups
            if EduLinkAPI.shared.achievementBehaviourLookups.achievement_types.isEmpty { return self.achievementBehaviourLookups(zCompletion) } else { zCompletion(true, nil)}
        })
    }
}

/// A container for Detention
public struct Detention {
    /// If the detention was attended
    public var attended: String?
    /// Reason for not attending
    public var non_attendance_reason: String?
    /// The ID of the detention
    public var id: String
    /// The description of the detention
    public var description: String?
    /// The start time of the detention
    public var start_time: Date
    /// The end time of the detention
    public var end_time: Date
    /// The location of the detention
    public var location: String?
    /// The date of the detention
    public var date: Date
    
    init?(_ dict: [String: Any]) {
        guard let tmpID = dict["id"],
              let tmpStartTime = dict["start_time"] as? String,
              let tmpEndTime = dict["end_time"] as? String,
              let start_time = DateTime.date(tmpStartTime),
              let end_time = DateTime.date(tmpEndTime),
              let tmpDate = dict["date"] as? String,
              let date = DateTime.date(tmpDate) else { return nil }
        self.attended = dict["attended"] as? String
        self.non_attendance_reason = dict["non_attendance_reason"] as? String
        self.id = String(describing: tmpID)
        self.description = dict["description"] as? String
        self.start_time = start_time
        self.end_time = end_time
        self.location = dict["location"] as? String
        self.date = date
    }
}

/// A container for Behaviour For Lesson Values
public struct B4LValue {
    /// The name of the behaviour type
    public var name: String
    /// The count of the behaviour type
    public var count: Int
}

/// A container for BehaviourForLesson
public struct BehaviourForLesson {
    /// The subject of the lesson
    public var subject: String
    /// An array of values for the subject, for more documentation see `B4LValue`
    public var values = [B4LValue]()
    
    init?(_ dict: [String: Any]) {
        guard let subject = dict["subject"] as? String,
              let values = dict["values"] as? [String: Any] else { return nil }
        self.subject = subject
        for value in values {
            guard let count = value.value as? Int else { continue }
            let b4lValue = B4LValue(name: value.key, count: count)
            self.values.append(b4lValue)
        }
        self.values = self.values.sorted { $0.count > $1.count }
    }
}

/// A container for an Achievement
public struct Achievement {
    /// The ID of the achievement
    public var id: String
    /// The type ID's of the achievement. For more documentation see `AchievementType`
    public var type_ids: [Int]?
    /// The activity ID's of the achievement. For more documentation see `AchievementActivityType`
    public var activity_id: String?
    /// The date of the achievement
    public var date: Date
    /// The ID of the employee who gave the achievement. For more documentation see `Employee`
    public var employee_id: String?
    /// The comments given by the teacher
    public var comments: String?
    /// The total points the achievement was worth
    public var points: Int
    /// The information for the lesson during the achievement
    public var lesson_information: String?
    /// If the achievement is shown to the user
    public var live: Bool
    
    init?(_ dict: [String: Any]) {
        guard let tmpID = dict["id"],
              let tmpDate = dict["date"] as? String,
              let date = DateTime.date(tmpDate),
              let points = dict["points"] as? Int else { return nil }
        self.id = String(describing: tmpID)
        self.date = date
        self.points = points
        self.live = dict["live"] as? Bool ?? false
        self.type_ids = dict["type_ids"] as? [Int]
        self.activity_id = dict["activity_id"] as? String
        let recorded = dict["recorded"] as? [String: String]
        self.employee_id = recorded?["employee_id"]
        self.comments = dict["comments"] as? String
        self.lesson_information = dict["lesson_information"] as? String
    }
}

/// A container for a Behaviour
public struct Behaviour {
    /// The ID of the behaviour
    public var id: String
    /// The type ID's of the behaviour, for more documentation see `BehaviourType`
    public var type_ids: [Int]?
    /// The activity ID's of the behaviour, for more documentation see `BehaviourActivityType`
    public var activity_id: String?
    /// The date of the behaviour
    public var date: Date
    /// The time ID for the behaviour
    public var time_id: String?
    /// The status ID of the behaviour
    public var status_id: String?
    /// The bullying type ID
    public var bullying_type_id: String?
    /// The location ID for the behaviour
    public var location_id: String?
    /// The action ID for the behaviour
    public var action_id: String?
    /// The action date of the behaviour
    public var action_date: Date?
    /// The recorded ID of the behaviour
    public var recorded_id: String?
    /// The information for the lesson during the behaviour
    public var lesson_information: String?
    /// The comments given by the teacher
    public var comments: String?
    /// The total points the behaviour was worth
    public var points: Int
    
    init?(_ dict: [String: Any]) {
        guard let tmpID = dict["id"],
              let tmpDate = dict["date"] as? String,
              let date = DateTime.date(tmpDate),
              let points = dict["points"] as? Int else { return nil }
        let action = dict["action_taken"] as? [String: Any]
        self.action_id = action?["id"] as? String
        if let tmpActionDate = action?["date"] as? String {
            let actionDate = DateTime.date(tmpActionDate)
            self.action_date = actionDate
        }
        self.id = String(describing: tmpID)
        self.date = date
        self.points = points
        self.type_ids = dict["type_ids"] as? [Int]
        self.time_id = dict["time_id"] as? String
        self.activity_id = dict["activity_id"] as? String
        self.status_id = dict["status_id"] as? String
        self.bullying_type_id = dict["bullying_type_id"] as? String
        self.location_id = dict["location_id"] as? String
        
        if let recorded = dict["recorded"] as? [String: String] {
            self.recorded_id = recorded["employee_id"]
        }
        self.comments = dict["comments"] as? String
        self.lesson_information = dict["lesson_information"] as? String
    }
}

/// A container for AchievementType
public struct AchievementType {
    /// The ID of the achievement type
    public var id: String
    /// If the achievement type is active
    public var active: Bool
    /// The code for the achievement type
    public var code: String
    /// The description for the achievement type
    public var description: String
    /// The position of the achievement type
    public var position: Int
    /// How many points that type is worth
    public var points: Int
    /// If the type is in the school system
    public var system: Bool
    
    init?(_ dict: [String: Any]) {
        guard let tmpID = dict["id"],
              let active = dict["active"] as? Bool,
              let code = dict["code"] as? String,
              let description = dict["description"] as? String,
              let position = dict["posititon"] as? Int,
              let points = dict["points"] as? Int,
              let system = dict["system"] as? Bool else { return nil }
        self.id = String(describing: tmpID)
        self.active = active
        self.code = code
        self.description = description
        self.position = position
        self.system = system
        self.points = points
    }
}

/// A container for AchievementActivityType
public struct AchievementActivityType {
    /// The ID of the achievement activity type
    public var id: String
    /// The code for the achievement activity type
    public var code: String
    /// The description for the achievement activity type
    public var description: String
    /// If the activity type is active
    public var active: Bool

    init?(_ dict: [String: Any]) {
        guard let tmpID = dict["id"],
              let active = dict["active"] as? Bool,
              let code = dict["code"] as? String,
              let description = dict["description"] as? String else { return nil }
        self.id = String(describing: tmpID)
        self.active = active
        self.code = code
        self.description = description
    }
}

/// A container for Behaviour Type
public struct BehaviourType {
    /// The ID of the behaviour type
    public var id: String
    /// If the behaviour type is active
    public var active: Bool
    /// The code for the behaviour type
    public var code: String
    /// The description for the behaviour type
    public var description: String
    /// The position for the behaviour type
    public var position: Int
    /// How many points the behaviour type is worth
    public var points: Int
    /// If the type is in the school system
    public var system: Bool
    /// If the type should be included in the register
    public var include_in_register: Bool
    /// If the type is a type of bullying
    public var is_bullying_type: Bool

    init?(_ dict: [String: Any]) {
        guard let tmpID = dict["id"],
              let active = dict["active"] as? Bool,
              let code = dict["code"] as? String,
              let description = dict["description"] as? String,
              let position = dict["position"] as? Int,
              let points = dict["points"] as? Int,
              let system = dict["system"] as? Bool,
              let include_in_register = dict["include_in_register"] as? Bool,
              let is_bullying_type = dict["is_bullying_type"] as? Bool else { return nil }
        self.id = String(describing: tmpID)
        self.active = active
        self.code = code
        self.description = description
        self.position = position
        self.points = points
        self.system = system
        self.include_in_register = include_in_register
        self.is_bullying_type = is_bullying_type
    }
}

/// A container for BehaviourActivityType
public struct BehaviourActivityType {
    /// The ID for the activity type
    public var id: String
    /// The code for the activity type
    public var code: String
    /// The description for the activity type
    public var description: String
    /// If the activity type is active
    public var active: Bool
    
    init?(_ dict: [String: Any]) {
        guard let tmpID = dict["id"],
              let description = dict["description"] as? String,
              let code = dict["code"] as? String,
              let active = dict["active"] as? Bool else { return nil }
        self.id = String(describing: tmpID)
        self.description = description
        self.code = code
        self.active = active
    }
}

/// A mass container for achievements, behaviours. detensions, behaviour in lesson, and types
public struct AchievementBehaviourLookup {
    /// An array of achievements, for more documentation see `Achievement`
    public var achievements = [Achievement]()
    /// An array of behaviours, for more documentation see `Behaviour`
    public var behaviours = [Behaviour]()
    /// An array of subjects for BehaviourInLesson, for more documentation see `BehaviourForLesson`
    public var behaviourForLessons = [BehaviourForLesson]()
    /// An array of detentions, for more documentation see `Detention`
    public var detentions = [Detention]()
    
    /// An array of achievement types, for more documentation see `AchievementType`
    public var achievement_types = [AchievementType]()
    /// An array of achievement activity types, for more documentation see `AchievementActivityType`
    public var achievement_activity_types = [AchievementActivityType]()
    /// An array of achievement award types, for more documentation see `SimpleStore`
    public var achievement_award_types = [SimpleStore]()
    
    /// Are achievement points editable by the current user
    public var achievement_points_editable: Bool = false
    /// Can detentions be managed by the current user
    public var detentionmanagement_enabled: Bool = false
    
    /// An array of behaviour types, for more documentation see `BehaviourType`
    public var behaviour_types = [BehaviourType]()
    /// An array of behaviour activity types, for more documentation see `BehaviourActivityType`
    public var behaviour_activity_types = [BehaviourActivityType]()
    /// An array of behaviour actions taken, for more documentation see `SimpleStore`
    public var behaviour_actions_taken = [SimpleStore]()
    /// An array of behaviour bullying types, for more documentation see `SimpleStore`
    public var behaviour_bullying_types = [SimpleStore]()
    /// An array of behaviour locations, for more documentation see `SimpleStore`
    public var behaviour_locations = [SimpleStore]()
    /// An array of behaviour statuses, for more documentation see `SimpleStore`
    public var behaviour_statuses = [SimpleStore]()
    /// An array of behaviour times, for more documentation see `SimpleStore`
    public var behaviour_times = [SimpleStore]()
}

