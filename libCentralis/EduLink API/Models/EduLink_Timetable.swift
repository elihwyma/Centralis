//
//  EduLink_TimeTable.swift
//  Centralis
//
//  Created by AW on 08/12/2020.
//

import Foundation

/// The model for getting timetable info
public class EduLink_Timetable {
    /// Retrieve timetable data for the currently logged in user
    /// - Parameter rootCompletion: The completion handler, for more documentation see `completionHandler`
    class public func timetable(learnerID: String = EduLinkAPI.shared.authorisedUser.id, _ rootCompletion: @escaping completionHandler) {
        let params: [String : String] = [
            "learner_id" : learnerID,
            "date" : "\(date())"
        ]
        NetworkManager.requestWithDict(url: nil, requestMethod: "EduLink.Timetable", params: params, completion: { (success, dict) -> Void in
            if !success { return rootCompletion(false, "Network Error") }
            guard let result = dict["result"] as? [String : Any] else { return rootCompletion(false, "Unknown Error") }
            if !(result["success"] as? Bool ?? false) { return rootCompletion(false, (result["error"] as? String ?? "Unknown Error")) }
            guard let weeks = result["weeks"] as? [[String : Any]] else { return rootCompletion(false, "Error parsing timetable response") }
            var weekCache = [Week]()
            for week in weeks {
                var we = Week()
                we.is_current = week["is_current"] as? Bool ?? false
                we.name = week["name"] as? String ?? "Not Given"
                guard let days = week["days"] as? [[String : Any]] else { continue }
                for day in days {
                    var de = Day()
                    de.date = day["date"] as? String ?? "Not Given"
                    de.isCurrent = day["is_current"] as? Bool ?? false
                    de.name = day["name"] as? String ?? "Not Given"
                    guard let lessons = day["lessons"] as? [[String : Any]], let periods = day["periods"] as? [[String : Any]] else {
                        continue
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
                weekCache.append(we)
            }
            if EduLinkAPI.shared.authorisedUser.id == learnerID { EduLinkAPI.shared.weeks = weekCache } else {
                if let index = EduLinkAPI.shared.authorisedUser.children.firstIndex(where: {$0.id == learnerID}) {
                    EduLinkAPI.shared.authorisedUser.children[index].weeks = weekCache
                }
            }
            rootCompletion(true, nil)
        })
    }
    
    class private func date() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'"
        return dateFormatter.string(from: Date())
    }
}

/// A container for a Timetable Week
public struct Week {
    /// An array of days for that week, for more documentation see `Day`
    public var days = [Day]()
    /// If the week is the current or not
    public var is_current: Bool!
    /// The name of the week
    public var name: String!
}

/// A container for a Timetable Day
public struct Day {
    /// The date of the day
    public var date: String!
    /// If the day is the current or not
    public var isCurrent: Bool!
    /// The name of the day
    public var name: String!
    /// An array of periods for that week, for more documentation see `Period`
    public var periods = [Period]()
}

/// A container for a Timetable Lesson
public struct Lesson: Hashable {
    /// The ID of the belonging period, for more documentation see `Period`
    public var period_id: String!
    /// The room for the lesson
    public var room_name: String!
    /// If the Lesson has had a room change
    public var moved: Bool!
    /// The teacher for the lesson
    public var teacher: String!
    /// The teaching group for the lesson
    public var group: String!
    /// The subject for the lesson
    public var subject: String!
}

/// A container for a Timetable Period
public struct Period: Hashable {
    /// If the period is a free period
    public var empty: Bool!
    /// What time the period starts
    public var start_time: String!
    /// What time the period ends
    public var end_time: String!
    /// The ID of the period
    public var id: String!
    /// The name of the period
    public var name: String!
    /// The lesson for that period, nil if is free period. For more documentation see `Lesson`
    public var lesson: Lesson!
}
