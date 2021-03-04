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
        let learnerID = EduLinkAPI.shared.authorisedUser.id
        let params: [String : String] = [
            "authtoken" : EduLinkAPI.shared.authorisedUser.authToken
        ]
        NetworkManager.requestWithDict(url: nil, requestMethod: "EduLink.AchievementBehaviourLookups", params: params, completion: { (success, dict) -> Void in
            if !success { return rootCompletion(false, "Network Error") }
            guard let result = dict["result"] as? [String : Any] else { return rootCompletion(false, "Unknown Error") }
            if !(result["success"] as? Bool ?? false) { return rootCompletion(false, (result["error"] as? String ?? "Unknown Error")) }
            var achievementBehaviourLookups = AchievementBehaviourLookup()
            if EduLinkAPI.shared.authorisedUser.id == learnerID { achievementBehaviourLookups = EduLinkAPI.shared.achievementBehaviourLookups } else {
                if let index = EduLinkAPI.shared.authorisedUser.children.firstIndex(where: {$0.id == learnerID}) {
                    achievementBehaviourLookups = EduLinkAPI.shared.authorisedUser.children[index].achievementBehaviourLookups
                }
            }
            if let achievement_types = result["achievement_types"] as? [[String : Any]] {
                achievementBehaviourLookups.achievement_types.removeAll()
                for achievement_type in achievement_types {
                    var achievementType = AchievementType()
                    achievementType.id = "\(achievement_type["id"] ?? "Not Given")"
                    achievementType.active = achievement_type["active"] as? Bool
                    achievementType.code = achievement_type["code"] as? String
                    achievementType.description = achievement_type["description"] as? String
                    achievementType.position = achievement_type["position"] as? Int
                    achievementType.points = achievement_type["points"] as? Int
                    achievementType.system = achievement_type["system"] as? Bool
                    achievementBehaviourLookups.achievement_types.append(achievementType)
                }
            }
            if let achievement_activity_types = result["achievement_activity_types"] as? [[String : Any]] {
                achievementBehaviourLookups.achievement_activity_types.removeAll()
                for achievement_activity_type in achievement_activity_types {
                    var aat = AchievementActivityType()
                    aat.id = "\(achievement_activity_type["id"] ?? "Not Given")"
                    aat.active = achievement_activity_type["active"] as? Bool
                    aat.code = achievement_activity_type["code"] as? String
                    aat.description = achievement_activity_type["description"] as? String
                    achievementBehaviourLookups.achievement_activity_types.append(aat)
                }
            }
            if let achievement_award_types = result["achievement_award_types"] as? [[String : Any]] { achievementBehaviourLookups.achievement_award_types = SimpleStore.generate(achievement_award_types) }
            if let behaviour_types = result["behaviour_types"] as? [[String : Any]] {
                achievementBehaviourLookups.behaviour_types.removeAll()
                for behaviour_type in behaviour_types {
                    var bt = BehaviourType()
                    bt.id = "\(behaviour_type["id"] ?? "Not Given")"
                    bt.active = behaviour_type["active"] as? Bool
                    bt.code = behaviour_type["code"] as? String
                    bt.description = behaviour_type["description"] as? String
                    bt.position = behaviour_type["position"] as? Int
                    bt.points = behaviour_type["points"] as? Int
                    bt.system = behaviour_type["system"] as? Bool
                    bt.include_in_register = behaviour_type["include_in_register"] as? Bool
                    bt.is_bullying_type = behaviour_type["is_bullying_type"] as? Bool
                    achievementBehaviourLookups.behaviour_types.append(bt)
                }
            }
            if let behaviour_activity_types = result["behaviour_activity_types"] as? [[String : Any]] {
                achievementBehaviourLookups.behaviour_activity_types.removeAll()
                for behaviour_activity_type in behaviour_activity_types {
                    var bat = BehaviourActivityType()
                    bat.id = "\(behaviour_activity_type["id"] ?? "Not Given")"
                    bat.description = "\(behaviour_activity_type["description"] ?? "Not Given")"
                    bat.code = "\(behaviour_activity_type["code"] ?? "Not Given")"
                    bat.active = behaviour_activity_type["active"] as? Bool ?? false
                    achievementBehaviourLookups.behaviour_activity_types.append(bat)
                }
            }
            if let behaviour_actions_taken = result["behaviour_actions_taken"] as? [[String : Any]] { achievementBehaviourLookups.behaviour_actions_taken = SimpleStore.generate(behaviour_actions_taken) }
            if let behaviour_bullying_types = result["behaviour_bullying_types"] as? [[String : Any]] { achievementBehaviourLookups.behaviour_bullying_types = SimpleStore.generate(behaviour_bullying_types) }
            if let behaviour_locations = result["behaviour_locations"] as? [[String : Any]] { achievementBehaviourLookups.behaviour_locations = SimpleStore.generate(behaviour_locations) }
            if let behaviour_statuses = result["behaviour_statuses"] as? [[String : Any]] { achievementBehaviourLookups.behaviour_statuses = SimpleStore.generate(behaviour_statuses) }
            if let behaviour_times = result["behaviour_times"] as? [[String : Any]] { achievementBehaviourLookups.behaviour_times = SimpleStore.generate(behaviour_times) }
            if EduLinkAPI.shared.authorisedUser.id == learnerID { EduLinkAPI.shared.achievementBehaviourLookups = achievementBehaviourLookups } else {
                if let index = EduLinkAPI.shared.authorisedUser.children.firstIndex(where: {$0.id == learnerID}) {
                    EduLinkAPI.shared.authorisedUser.children[index].achievementBehaviourLookups = achievementBehaviourLookups
                }
            }
            rootCompletion(true, nil)
        })
    }
    
    /// Retrieve the achievements of the user, for more documentation see `Achievement`
    /// - Parameter rootCompletion: The completion handler, for more documentation see `completionHandler`
    class public func achievement(learnerID: String = EduLinkAPI.shared.authorisedUser.id, _ zCompletion: @escaping completionHandler) {
        let params: [String : String] = [
            "learner_id" : learnerID,
            "authtoken" : EduLinkAPI.shared.authorisedUser.authToken
        ]
        NetworkManager.requestWithDict(url: nil, requestMethod: "EduLink.Achievement", params: params, completion: { (success, dict) -> Void in
            if !success { return zCompletion(false, "Network Error") }
            guard let result = dict["result"] as? [String : Any] else { return zCompletion(false, "Unknown Error") }
            if !(result["success"] as? Bool ?? false) { return zCompletion(false, "Unknown Error") }
            if let employees = result["employees"] as? [[String : Any]] {
                EduLink_Employee.handle(employees)
            }
            var achievementsCache = [Achievement]()
            if let achievement = result["achievement"] as? [[String : Any]] {
                for achievement in achievement {
                    var a = Achievement()
                    a.id = "\(achievement["id"] ?? "Not Given")"
                    a.type_ids = achievement["type_ids"] as? [Int] ?? [Int]()
                    a.activity_id = "\(achievement["activity_id"] ?? "Not Given")"
                    a.date = achievement["date"] as? String ?? "Not Given"
                    let recorded = achievement["recorded"] as? [String : String]
                    a.employee_id = "\(recorded?["employee_id"] ?? "Not Given")"
                    a.comments = achievement["comments"] as? String ?? "Not Given"
                    a.points = achievement["points"] as? Int ?? 0
                    a.lesson_information = achievement["lesson_information"] as? String ?? "Not Given"
                    a.live = achievement["live"] as? Bool ?? false
                    achievementsCache.append(a)
                }
            }
            if EduLinkAPI.shared.authorisedUser.id == learnerID {
                EduLinkAPI.shared.achievementBehaviourLookups.achievements = achievementsCache
                if EduLinkAPI.shared.achievementBehaviourLookups.achievement_types.isEmpty { return self.achievementBehaviourLookups({ (success, error) -> Void in zCompletion(success, error)}) } else { zCompletion(true, nil)}
            } else {
                if let index = EduLinkAPI.shared.authorisedUser.children.firstIndex(where: {$0.id == learnerID}) {
                    EduLinkAPI.shared.authorisedUser.children[index].achievementBehaviourLookups.achievements = achievementsCache
                    if EduLinkAPI.shared.authorisedUser.children[index].achievementBehaviourLookups.achievement_types.isEmpty { return self.achievementBehaviourLookups({ (success, error) -> Void in zCompletion(success, error)}) } else { zCompletion(true, nil)}
                }
            }
        })
    }
    
    /// Retrieve the behaviours of the user, for more documentation see `Behaviour`
    /// - Parameter rootCompletion: The completion handler, for more documentation see `completionHandler`
    class public func behaviour(learnerID: String = EduLinkAPI.shared.authorisedUser.id, _ zCompletion: @escaping completionHandler) {
        let params: [String : String] = [
            "learner_id" : learnerID,
            "authtoken" : EduLinkAPI.shared.authorisedUser.authToken
        ]
        NetworkManager.requestWithDict(url: nil, requestMethod: "EduLink.Behaviour", params: params, completion: { (success, dict) -> Void in
            if !success { return zCompletion(false, "Network Error") }
            guard let result = dict["result"] as? [String : Any] else { return zCompletion(false, "Unknown Error") }
            if !(result["success"] as? Bool ?? false) { return zCompletion(false, "Unknown Error") }
            if let employees = result["employees"] as? [[String : Any]] {
                EduLink_Employee.handle(employees)
            }
            var achievementBehaviourLookups = AchievementBehaviourLookup()
            if EduLinkAPI.shared.authorisedUser.id == learnerID { achievementBehaviourLookups = EduLinkAPI.shared.achievementBehaviourLookups } else {
                if let index = EduLinkAPI.shared.authorisedUser.children.firstIndex(where: {$0.id == learnerID}) {
                    achievementBehaviourLookups = EduLinkAPI.shared.authorisedUser.children[index].achievementBehaviourLookups
                }
            }
            if let behaviours = result["behaviour"] as? [[String : Any]] {
                for behaviour in behaviours {
                    var b = Behaviour()
                    b.id = "\(behaviour["id"] ?? "Not Given")"
                    b.type_ids = behaviour["type_ids"] as? [Int] ?? [Int]()
                    b.activity_id = "\(behaviour["activity_id"] ?? "Not Given")"
                    b.time_id = "\(behaviour["time_id"] ?? "Not Given")"
                    b.status_id = "\(behaviour["status_id"] ?? "Not Given")"
                    b.bullying_type_id = "\(behaviour["bullying_type_id"] ?? "Not Given")"
                    b.location_id = "\(behaviour["location_id"] ?? "Not Given")"
                    let action = behaviour["action_taken"] as? [String : Any]
                    b.action_id = "\(action?["id"] ?? "Not Given")"
                    b.action_date = "\(action?["date"] ?? "Not Given")"
                    b.date = behaviour["date"] as? String ?? "Not Given"
                    let recorded = behaviour["recorded"] as? [String : String]
                    b.recorded_id = "\(recorded?["employee_id"] ?? "Not Given")"
                    b.comments = behaviour["comments"] as? String ?? "Not Given"
                    b.points = behaviour["points"] as? Int ?? 0
                    b.lesson_information = behaviour["lesson_information"] as? String ?? "Not Given"
                    achievementBehaviourLookups.behaviours.append(b)
                }
            }
            if let b4l = result["b4l"] as? [[String : Any]] {
                for b4l in b4l {
                    var b = BehaviourForLesson()
                    b.subject = "\(b4l["subject"] ?? "Not Given")"
                    let values = b4l["values"] as? [String : Any] ?? [String : Any]()
                    for value in values {
                        var v = B4LValue()
                        v.name = value.key
                        v.count = value.value as? Int ?? 0
                        b.values.append(v)
                    }
                    b.values = b.values.sorted { $0.count > $1.count }
                    achievementBehaviourLookups.behaviourForLessons.append(b)
                }
            }
            if let detentions = result["detentions"] as? [[String : Any]] {
                for detention in detentions {
                    var d = Detention()
                    d.attended = detention["attended"] as? String ?? ""
                    d.non_attendance_reason = detention["non_attendance_reason"] as? String ?? ""
                    d.id = "\(detention["id"] ?? "Not Given")"
                    d.description = detention["description"] as? String ?? "Not Given"
                    d.start_time = detention["start_time"] as? String ?? "Not Given"
                    d.end_time = detention["end_time"] as? String ?? "Not Given"
                    d.location = detention["location"] as? String ?? "Not Given"
                    d.date = detention["date"] as? String ?? "Not Given"
                    achievementBehaviourLookups.detentions.append(d)
                }
            }
            if EduLinkAPI.shared.authorisedUser.id == learnerID {
                EduLinkAPI.shared.achievementBehaviourLookups = achievementBehaviourLookups
                if EduLinkAPI.shared.achievementBehaviourLookups.achievement_types.isEmpty { return self.achievementBehaviourLookups({ (success, error) -> Void in zCompletion(success, error)}) } else { zCompletion(true, nil)}
            } else {
                if let index = EduLinkAPI.shared.authorisedUser.children.firstIndex(where: {$0.id == learnerID}) {
                    EduLinkAPI.shared.authorisedUser.children[index].achievementBehaviourLookups = achievementBehaviourLookups
                    if EduLinkAPI.shared.authorisedUser.children[index].achievementBehaviourLookups.achievement_types.isEmpty { return self.achievementBehaviourLookups({ (success, error) -> Void in zCompletion(success, error)}) } else { zCompletion(true, nil)}
                }
            }
        })
    }
}

/// A container for Detention
public struct Detention {
    /// If the detention was attended
    public var attended: String!
    /// Reason for not attending
    public var non_attendance_reason: String!
    /// The ID of the detention
    public var id: String!
    /// The description of the detention
    public var description: String!
    /// The start time of the detention
    public var start_time: String!
    /// The end time of the detention
    public var end_time: String!
    /// The location of the detention
    public var location: String!
    /// The date of the detention
    public var date: String!
}

/// A container for Behaviour For Lesson Values
public struct B4LValue {
    /// The name of the behaviour type
    public var name: String!
    /// The count of the behaviour type
    public var count: Int!
}

/// A container for BehaviourForLesson
public struct BehaviourForLesson {
    /// The subject of the lesson
    public var subject: String!
    /// An array of values for the subject, for more documentation see `B4LValue`
    public var values = [B4LValue]()
}

/// A container for an Achievement
public struct Achievement {
    /// The ID of the achievement
    public var id: String!
    /// The type ID's of the achievement. For more documentation see `AchievementType`
    public var type_ids: [Int]!
    /// The activity ID's of the achievement. For more documentation see `AchievementActivityType`
    public var activity_id: String!
    /// The date of the achievement
    public var date: String!
    /// The ID of the employee who gave the achievement. For more documentation see `Employee`
    public var employee_id: String!
    /// The comments given by the teacher
    public var comments: String!
    /// The total points the achievement was worth
    public var points: Int!
    /// The information for the lesson during the achievement
    public var lesson_information: String!
    /// If the achievement is shown to the user
    public var live: Bool!
}

/// A container for a Behaviour
public struct Behaviour {
    /// The ID of the behaviour
    public var id: String!
    /// The type ID's of the behaviour, for more documentation see `BehaviourType`
    public var type_ids: [Int]!
    /// The activity ID's of the behaviour, for more documentation see `BehaviourActivityType`
    public var activity_id: String!
    /// The date of the behaviour
    public var date: String!
    /// The time ID for the behaviour
    public var time_id: String!
    /// The status ID of the behaviour
    public var status_id: String!
    /// The bullying type ID
    public var bullying_type_id: String!
    /// The location ID for the behaviour
    public var location_id: String!
    /// The action ID for the behaviour
    public var action_id: String!
    /// The action date of the behaviour
    public var action_date: String!
    /// The recorded ID of the behaviour
    public var recorded_id: String!
    /// The information for the lesson during the behaviour
    public var lesson_information: String!
    /// The comments given by the teacher
    public var comments: String!
    /// The total points the behaviour was worth
    public var points: Int!
}

/// A container for AchievementType
public struct AchievementType {
    /// The ID of the achievement type
    public var id: String!
    /// If the achievement type is active
    public var active: Bool!
    /// The code for the achievement type
    public var code: String!
    /// The description for the achievement type
    public var description: String!
    /// The position of the achievement type
    public var position: Int!
    /// How many points that type is worth
    public var points: Int!
    /// If the type is in the school system
    public var system: Bool!
}

/// A container for AchievementActivityType
public struct AchievementActivityType {
    /// The ID of the achievement activity type
    public var id: String!
    /// The code for the achievement activity type
    public var code: String!
    /// The description for the achievement activity type
    public var description: String!
    /// If the activity type is active
    public var active: Bool!
}

/// A container for Behaviour Type
public struct BehaviourType {
    /// The ID of the behaviour type
    public var id: String!
    /// If the behaviour type is active
    public var active: Bool!
    /// The code for the behaviour type
    public var code: String!
    /// The description for the behaviour type
    public var description: String!
    /// The position for the behaviour type
    public var position: Int!
    /// How many points the behaviour type is worth
    public var points: Int!
    /// If the type is in the school system
    public var system: Bool!
    /// If the type should be included in the register
    public var include_in_register: Bool!
    /// If the type is a type of bullying
    public var is_bullying_type: Bool!
}

/// A container for BehaviourActivityType
public struct BehaviourActivityType {
    /// The ID for the activity type
    public var id: String!
    /// The code for the activity type
    public var code: String!
    /// The description for the activity type
    public var description: String!
    /// If the activity type is active
    public var active: Bool!
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
    public var achievement_points_editable: Bool!
    /// Can detentions be managed by the current user
    public var detentionmanagement_enabled: Bool!
    
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

