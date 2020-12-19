//
//  EduLink_Achievement.swift
//  Centralis
//
//  Created by Amy While on 03/12/2020.
//

import UIKit

class EduLink_Achievement {
    
    public func achievementBehaviourLookups() {
        let url = URL(string: "\(EduLinkAPI.shared.authorisedSchool.server!)?method=EduLink.AchievementBehaviourLookups")!
        let headers: [String : String] = ["Content-Type" : "application/json;charset=utf-8"]
        let body = "{\"jsonrpc\":\"2.0\",\"method\":\"EduLink.AchievementBehaviourLookups\",\"params\":{\"authtoken\":\"\(EduLinkAPI.shared.authorisedUser.authToken!)\"},\"uuid\":\"\(UUID.shared.uuid)\",\"id\":\"1\"}"
        NetworkManager.shared.requestWithDict(url: url, method: "POST", headers: headers, jsonbody: body, completion: { (success, dict) -> Void in
            if success {
                if let result = dict["result"] as? [String : Any] {
                    if !(result["success"] as! Bool) {
                        NotificationCenter.default.post(name: .FailedAchievement, object: nil)
                        NotificationCenter.default.post(name: .FailedBehaviour, object: nil)
                        return
                    }
                    self.scrapeAllNeededData(result)
                    NotificationCenter.default.post(name: .SuccesfulAchievement, object: nil)
                    NotificationCenter.default.post(name: .SucccesfulBehaviour, object: nil)
                } else {
                    NotificationCenter.default.post(name: .FailedAchievement, object: nil)
                    NotificationCenter.default.post(name: .FailedBehaviour, object: nil)
                }
            } else {
                NotificationCenter.default.post(name: .NetworkError, object: nil)
            }
        })
    }
    
    public func achievement() {
        let url = URL(string: "\(EduLinkAPI.shared.authorisedSchool.server!)?method=EduLink.Achievement")!
        let headers: [String : String] = ["Content-Type" : "application/json;charset=utf-8"]
        let body = "{\"jsonrpc\":\"2.0\",\"method\":\"EduLink.Achievement\",\"params\":{\"learner_id\":\"\(EduLinkAPI.shared.authorisedUser.id!)\",\"authtoken\":\"\(EduLinkAPI.shared.authorisedUser.authToken!)\"},\"uuid\":\"\(UUID.shared.uuid)\",\"id\":\"1\"}"
        NetworkManager.shared.requestWithDict(url: url, method: "POST", headers: headers, jsonbody: body, completion: { (success, dict) -> Void in
            if success {
                if let result = dict["result"] as? [String : Any] {
                    if !(result["success"] as! Bool) {
                        NotificationCenter.default.post(name: .FailedAchievement, object: nil)
                        return
                    }
                    if let employees = result["employees"] as? [[String : Any]] {
                        let employeeManager = EduLink_Employee()
                        employeeManager.handle(employees)
                    }
                    if let achievement = result["achievement"] as? [[String : Any]] {
                        EduLinkAPI.shared.achievementBehaviourLookups.achievements.removeAll()
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
                            EduLinkAPI.shared.achievementBehaviourLookups.achievements.append(a)
                        }
                    }
                    if EduLinkAPI.shared.achievementBehaviourLookups.achievement_types.isEmpty {
                        self.achievementBehaviourLookups()
                    } else {
                        NotificationCenter.default.post(name: .SuccesfulAchievement, object: nil)
                    }
                } else {
                    NotificationCenter.default.post(name: .FailedAchievement, object: nil)
                }
            } else {
                NotificationCenter.default.post(name: .NetworkError, object: nil)
            }
        })
    }
    
    public func behaviour() {
        let url = URL(string: "\(EduLinkAPI.shared.authorisedSchool.server!)?method=EduLink.Behaviour")!
        let headers: [String : String] = ["Content-Type" : "application/json;charset=utf-8"]
        let body = "{\"jsonrpc\":\"2.0\",\"method\":\"EduLink.Behaviour\",\"params\":{\"learner_id\":\"\(EduLinkAPI.shared.authorisedUser.id!)\",\"authtoken\":\"\(EduLinkAPI.shared.authorisedUser.authToken!)\",\"format\":\"2\"},\"uuid\":\"\(UUID.shared.uuid)\",\"id\":\"1\"}"
        NetworkManager.shared.requestWithDict(url: url, method: "POST", headers: headers, jsonbody: body, completion: { (success, dict) -> Void in
            if success {
                if let result = dict["result"] as? [String : Any] {
                    if !(result["success"] as! Bool) {
                        NotificationCenter.default.post(name: .FailedBehaviour, object: nil)
                        return
                    }
                    if let employees = result["employees"] as? [[String : Any]] {
                        let employeeManager = EduLink_Employee()
                        employeeManager.handle(employees)
                    }
                    if let behaviours = result["behaviour"] as? [[String : Any]] {
                        EduLinkAPI.shared.achievementBehaviourLookups.behaviours.removeAll()
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
                            EduLinkAPI.shared.achievementBehaviourLookups.behaviours.append(b)
                        }
                    }
                    if let b4l = result["b4l"] as? [[String : Any]] {
                        EduLinkAPI.shared.achievementBehaviourLookups.behaviourForLessons.removeAll()
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
                            EduLinkAPI.shared.achievementBehaviourLookups.behaviourForLessons.append(b)
                        }
                    }
                    if let detentions = result["detentions"] as? [[String : Any]] {
                        EduLinkAPI.shared.achievementBehaviourLookups.detentions.removeAll()
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
                            EduLinkAPI.shared.achievementBehaviourLookups.detentions.append(d)
                        }
                    }
                    if EduLinkAPI.shared.achievementBehaviourLookups.behaviour_types.isEmpty {
                        self.achievementBehaviourLookups()
                    } else {
                        NotificationCenter.default.post(name: .SucccesfulBehaviour, object: nil)
                    }
                } else {
                    NotificationCenter.default.post(name: .FailedBehaviour, object: nil)
                }
            } else {
                NotificationCenter.default.post(name: .NetworkError, object: nil)
            }
        })
    }
    
    private func scrapeAllNeededData(_ result: [String : Any]) {
        if let achievement_types = result["achievement_types"] as? [[String : Any]] {
            EduLinkAPI.shared.achievementBehaviourLookups.achievement_types.removeAll()
            for achievement_type in achievement_types {
                var achievementType = AchievementType()
                achievementType.id = "\(achievement_type["id"] ?? "Not Given")"
                achievementType.active = achievement_type["active"] as? Bool
                achievementType.code = achievement_type["code"] as? String
                achievementType.description = achievement_type["description"] as? String
                achievementType.position = achievement_type["position"] as? Int
                achievementType.points = achievement_type["points"] as? Int
                achievementType.system = achievement_type["system"] as? Bool
                EduLinkAPI.shared.achievementBehaviourLookups.achievement_types.append(achievementType)
            }
        }
        
        if let achievement_activity_types = result["achievement_activity_types"] as? [[String : Any]] {
            EduLinkAPI.shared.achievementBehaviourLookups.achievement_activity_types.removeAll()
            for achievement_activity_type in achievement_activity_types {
                var aat = AchievementActivityType()
                aat.id = "\(achievement_activity_type["id"] ?? "Not Given")"
                aat.active = achievement_activity_type["active"] as? Bool
                aat.code = achievement_activity_type["code"] as? String
                aat.description = achievement_activity_type["description"] as? String
                EduLinkAPI.shared.achievementBehaviourLookups.achievement_activity_types.append(aat)
            }
        }
        
        if let achievement_award_types = result["achievement_award_types"] as? [[String : Any]] {
            EduLinkAPI.shared.achievementBehaviourLookups.achievement_award_types.removeAll()
            for achievement_award_type in achievement_award_types {
                var aat = AchievementAwardType()
                aat.id = "\(achievement_award_type["id"] ?? "Not Given")"
                aat.name = achievement_award_type["name"] as? String
                EduLinkAPI.shared.achievementBehaviourLookups.achievement_award_types.append(aat)
            }
        }
        
        if let behaviour_types = result["behaviour_types"] as? [[String : Any]] {
            EduLinkAPI.shared.achievementBehaviourLookups.behaviour_types.removeAll()
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
                EduLinkAPI.shared.achievementBehaviourLookups.behaviour_types.append(bt)
            }
        }
        
        if let behaviour_activity_types = result["behaviour_activity_types"] as? [[String : Any]] {
            EduLinkAPI.shared.achievementBehaviourLookups.behaviour_activity_types.removeAll()
            for behaviour_activity_type in behaviour_activity_types {
                var bat = BehaviourActivityType()
                bat.id = "\(behaviour_activity_type["id"] ?? "Not Given")"
                bat.description = "\(behaviour_activity_type["description"] ?? "Not Given")"
                bat.code = "\(behaviour_activity_type["code"] ?? "Not Given")"
                bat.active = behaviour_activity_type["active"] as? Bool ?? false
                EduLinkAPI.shared.achievementBehaviourLookups.behaviour_activity_types.append(bat)
            }
        }
        
        if let behaviour_actions_taken = result["behaviour_actions_taken"] as? [[String : Any]] {
            EduLinkAPI.shared.achievementBehaviourLookups.behaviour_actions_taken.removeAll()
            for behaviour_actions_taken in behaviour_actions_taken {
                var bat = BehaviourActionsTaken()
                bat.id = "\(behaviour_actions_taken["id"] ?? "Not Given")"
                bat.name = "\(behaviour_actions_taken["name"] ?? "Not Given")"
                EduLinkAPI.shared.achievementBehaviourLookups.behaviour_actions_taken.append(bat)
            }
        }
        
        if let behaviour_bullying_types = result["behaviour_bullying_types"] as? [[String : Any]] {
            EduLinkAPI.shared.achievementBehaviourLookups.behaviour_bullying_types.removeAll()
            for behaviour_bullying_type in behaviour_bullying_types {
                var bbt = BehaviourBullyingType()
                bbt.id = "\(behaviour_bullying_type["id"] ?? "Not Given")"
                bbt.name = "\(behaviour_bullying_type["name"] ?? "Not Given")"
                EduLinkAPI.shared.achievementBehaviourLookups.behaviour_bullying_types.append(bbt)
            }
        }
        
        if let behaviour_locations = result["behaviour_locations"] as? [[String : Any]] {
            EduLinkAPI.shared.achievementBehaviourLookups.behaviour_locations.removeAll()
            for behaviour_location in behaviour_locations {
                var bl = BehaviourLocation()
                bl.id = "\(behaviour_location["id"] ?? "Not Given")"
                bl.name = "\(behaviour_location["name"] ?? "Not Given")"
                EduLinkAPI.shared.achievementBehaviourLookups.behaviour_locations.append(bl)
            }
        }
        
        if let behaviour_statuses = result["behaviour_statuses"] as? [[String : Any]] {
            EduLinkAPI.shared.achievementBehaviourLookups.behaviour_statuses.removeAll()
            for behaviour_status in behaviour_statuses {
                var bs = BehaviourStatus()
                bs.id = "\(behaviour_status["id"] ?? "Not Given")"
                bs.name = "\(behaviour_status["name"] ?? "Not Given")"
                EduLinkAPI.shared.achievementBehaviourLookups.behaviour_statuses.append(bs)
            }
        }
        
        if let behaviour_times = result["behaviour_times"] as? [[String : Any]] {
            EduLinkAPI.shared.achievementBehaviourLookups.behaviour_times.removeAll()
            for behaviour_time in behaviour_times {
                var bt = BehaviourTime()
                bt.id = "\(behaviour_time["id"] ?? "Not Given")"
                bt.name = "\(behaviour_time["name"] ?? "Not Given")"
                EduLinkAPI.shared.achievementBehaviourLookups.behaviour_times.append(bt)
            }
        }
    }
}


struct Detention {
    var attended: String!
    var non_attendance_reason: String!
    var id: String!
    var description: String!
    var start_time: String!
    var end_time: String!
    var location: String!
    var date: String!
}

struct B4LValue {
    var name: String!
    var count: Int!
}

struct BehaviourForLesson {
    var subject: String!
    var values = [B4LValue]()
}

struct Achievement {
    var id: String!
    var type_ids: [Int]!
    var activity_id: String!
    var date: String!
    var employee_id: String!
    var comments: String!
    var points: Int!
    var lesson_information: String!
    var live: Bool!
}

struct Behaviour {
    var id: String!
    var type_ids: [Int]!
    var activity_id: String!
    var date: String!
    var time_id: String!
    var status_id: String!
    var bullying_type_id: String!
    var location_id: String!
    var action_id: String!
    var action_date: String!
    var recorded_id: String!
    var lesson_information: String!
    var comments: String!
    var points: Int!
}

struct AchievementType {
    var id: String!
    var active: Bool!
    var code: String!
    var description: String!
    var position: Int!
    var points: Int!
    var system: Bool!
}

struct AchievementActivityType {
    var id: String!
    var code: String!
    var description: String!
    var active: Bool!
}

struct AchievementAwardType {
    var id: String!
    var name: String!
}

struct BehaviourType {
    var id: String!
    var active: Bool!
    var code: String!
    var description: String!
    var position: Int!
    var points: Int!
    var system: Bool!
    var include_in_register: Bool!
    var is_bullying_type: Bool!
}

struct BehaviourActivityType {
    var id: String!
    var code: String!
    var description: String!
    var active: Bool!
}

struct BehaviourActionsTaken {
    var id: String!
    var name: String!
}

struct BehaviourBullyingType {
    var id: String!
    var name: String!
}

struct BehaviourLocation {
    var id: String!
    var name: String!
}

struct BehaviourStatus {
    var id: String!
    var name: String!
}

struct BehaviourTime {
    var id: String!
    var name: String!
}

struct AchievementBehaviourLookup {
    var achievements = [Achievement]()
    var behaviours = [Behaviour]()
    var behaviourForLessons = [BehaviourForLesson]()
    var detentions = [Detention]()
    
    var achievement_types = [AchievementType]()
    var achievement_activity_types = [AchievementActivityType]()
    var achievement_award_types = [AchievementAwardType]()
    
    var achievement_points_editable: Bool!
    var detentionmanagement_enabled: Bool!
    
    var behaviour_types = [BehaviourType]()
    var behaviour_activity_types = [BehaviourActivityType]()
    var behaviour_actions_taken = [BehaviourActionsTaken]()
    var behaviour_bullying_types = [BehaviourBullyingType]()
    var behaviour_locations = [BehaviourLocation]()
    var behaviour_statuses = [BehaviourStatus]()
    var behaviour_times = [BehaviourTime]()
}

