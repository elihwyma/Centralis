//
//  EduLink_Achievement.swift
//  Centralis
//
//  Created by Amy While on 03/12/2020.
//

import Foundation

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
                        return
                    }
                    self.scrapeAllNeededData(result)
                    NotificationCenter.default.post(name: .SuccesfulAchievement, object: nil)
                } else {
                    NotificationCenter.default.post(name: .FailedAchievement, object: nil)
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
                            a.id = achievement["id"] as? Int
                            a.type_ids = achievement["type_ids"] as? [Int]
                            a.activity_id = achievement["activity_id"] as? Int
                            a.date = achievement["date"] as? String
                            let recorded = achievement["recorded"] as? [String : String]
                            a.employee_id = Int((recorded!["employee_id"])!)
                            a.comments = achievement["comments"] as? String
                            a.points = achievement["points"] as? Int
                            a.lesson_information = achievement["lesson_information"] as? String
                            a.live = achievement["live"] as? Bool
                            EduLinkAPI.shared.achievementBehaviourLookups.achievements.append(a)
                        }
                    }
                    self.achievementBehaviourLookups()
                } else {
                    NotificationCenter.default.post(name: .FailedAchievement, object: nil)
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
                achievementType.id = achievement_type["id"] as? Int
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
                aat.id = achievement_activity_type["id"] as? Int
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
                aat.id = achievement_award_type["id"] as? Int
                aat.name = achievement_award_type["name"] as? String
                EduLinkAPI.shared.achievementBehaviourLookups.achievement_award_types.append(aat)
            }
        }
        
        if let behaviour_types = result["behaviour_types"] as? [[String : Any]] {
            EduLinkAPI.shared.achievementBehaviourLookups.behaviour_types.removeAll()
            for behaviour_type in behaviour_types {
                var bt = BehaviourType()
                bt.id = behaviour_type["id"] as? Int
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
    }
}

