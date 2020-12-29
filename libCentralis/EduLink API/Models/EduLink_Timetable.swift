//
//  EduLink_TimeTable.swift
//  Centralis
//
//  Created by Amy While on 08/12/2020.
//

import Foundation

class EduLink_Timetable {
    public func timetable() {
        let url = URL(string: "\(EduLinkAPI.shared.authorisedSchool.server!)?method=EduLink.Timetable")!
        let headers: [String : String] = ["Content-Type" : "application/json;charset=utf-8"]
        let body = "{\"jsonrpc\":\"2.0\",\"method\":\"EduLink.Timetable\",\"params\":{\"date\":\"\(date())\",\"learner_id\":\"\(EduLinkAPI.shared.authorisedUser.id!)\",\"authtoken\":\"\(EduLinkAPI.shared.authorisedUser.authToken!)\"},\"uuid\":\"\(UUID.shared.uuid)\",\"id\":\"1\"}"
        NetworkManager.shared.requestWithDict(url: url, method: "POST", headers: headers, jsonbody: body, completion: { (success, dict) -> Void in
            if success {
                if let result = dict["result"] as? [String : Any] {
                    if !(result["success"] as! Bool) {
                        NotificationCenter.default.post(name: .FailedTimetable, object: nil)
                    }
                    self.scrapeResult(result)
                    NotificationCenter.default.post(name: .SuccesfulTimetable, object: nil)
                }
            } else {
                NotificationCenter.default.post(name: .NetworkError, object: nil)
            }
        })
    }
    
    private func date() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'"
        return dateFormatter.string(from: Date())
    }
    
    private func scrapeResult(_ result: [String : Any]) {
        guard let weeks = result["weeks"] as? [[String : Any]] else { return }
        EduLinkAPI.shared.weeks.removeAll()
        for week in weeks {
            var we = Week()
            we.is_current = week["is_current"] as? Bool ?? false
            we.name = week["name"] as? String ?? "Not Given"
            guard let days = week["days"] as? [[String : Any]] else { return }
            for day in days {
                var de = Day()
                de.date = day["date"] as? String ?? "Not Given"
                de.isCurrent = day["is_current"] as? Bool ?? false
                de.name = day["name"] as? String ?? "Not Given"
                guard let lessons = day["lessons"] as? [[String : Any]], let periods = day["periods"] as? [[String : Any]] else {
                    return
                }
                
                var memLesson = [Lesson]()
                
                for lesson in lessons {
                    var l = Lesson()
                    l.period_id = "\(lesson["period_id"] ?? "Not Given")"
                    if let room = lesson["room"] as? [String : Any] {
                        l.room_name = room["name"] as? String ?? "Not Given"
                        l.moved = room["moved"] as? Bool ?? false
                    }
                    l.teacher = lesson["teachers"] as? String ?? "Not Given"
                    if let teaching_group = lesson["teaching_group"] as? [String : Any] {
                        l.group = teaching_group["name"] as? String ?? "Not Given"
                        l.subject = teaching_group["subject"] as? String ?? "Not Given"
                    }
                    memLesson.append(l)
                }
                
                for period in periods {
                    var p = Period()
                    p.empty = period["empty"] as? Bool ?? false
                    p.end_time = period["end_time"] as? String ?? "Not Given"
                    p.start_time = period["start_time"] as? String ?? "Not Given"
                    p.id = "\(period["id"] ?? "Not Given")"
                    p.name = period["name"] as? String ?? "Not Given"
                    for lesson in memLesson where lesson.period_id == p.id {
                        p.lesson = lesson
                    }
                    de.periods.append(p)
                }
                we.days.append(de)
            }
            EduLinkAPI.shared.weeks.append(we)
        }
    }
}

public struct Week {
    var days = [Day]()
    var is_current: Bool!
    var name: String!
}

public struct Day {
    var date: String!
    var isCurrent: Bool!
    var name: String!
    var periods = [Period]()
}

public struct Lesson {
    var period_id: String!
    var room_name: String!
    var moved: Bool!
    var teacher: String!
    var group: String!
    var subject: String!
}

public struct Period {
    var empty: Bool!
    var start_time: String!
    var end_time: String!
    var id: String!
    var name: String!
    var lesson: Lesson!
}
