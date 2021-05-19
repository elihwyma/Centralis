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
            let weekCache = weeks.map({ Week($0) })
            NSLog("[Centralis] Week Cache = \(weekCache)")
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
    public var is_current: Bool
    /// The name of the week
    public var name: String
    
    init(_ dict: [String: Any]) {
        self.name = dict["name"] as? String ?? "None"
        self.is_current = dict["is_current"] as? Bool ?? false
        guard let days = dict["days"] as? [[String: Any]] else { return }
        
        for dayDict in days {
            var day = Day(dayDict)
            guard let periodDicts = dayDict["periods"] as? [[String: Any]],
                  let lessonDicts = dayDict["lessons"] as? [[String: Any]] else {
                self.days.append(day)
                continue
            }
            var lessonCache = [Lesson]()
            for lessonDict in lessonDicts {
                if let lesson = Lesson(lessonDict) {
                    lessonCache.append(lesson)
                }
            }
            for periodDict in periodDicts {
                guard var period = Period(periodDict, day: day.date) else { continue }
                if let lesson = lessonCache.first(where: { $0.period_id == period.id }) {
                    period.lesson = lesson
                }
                day.periods.append(period)
            }
            self.days.append(day)
        }
    }
}

/// A container for a Timetable Day
public struct Day {
    /// If the day is the current or not
    public var isCurrent: Bool
    /// The name of the day
    public var name: String
    /// An array of periods for that week, for more documentation see `Period`
    public var periods = [Period]()
    public var date: Date?
    
    init(_ dict: [String: Any]) {
        let name = dict["name"] as? String ?? "None"
        self.isCurrent = dict["is_current"] as? Bool ?? false
        self.name = name
        
        if let dateTmp = dict["date"] as? String,
           let date = DateTime.date(dateTmp) {
            self.date = date
        }
    }
}

/// A container for a Timetable Lesson
public struct Lesson: Hashable {
    /// The ID of the belonging period, for more documentation see `Period`
    public var period_id: String
    /// The room for the lesson
    public var room_name: String?
    /// If the Lesson has had a room change
    public var moved: Bool = false
    /// The teacher for the lesson
    public var teacher: Employee?
    /// The teaching group for the lesson
    public var group: String
    /// The subject for the lesson
    public var subject: String
    
    init?(_ dict: [String: Any]) {
        guard let tmpPeriodID = dict["period_id"] else { return nil }
        self.period_id = String(describing: tmpPeriodID)
        let room = dict["room"] as? [String: Any]
        self.room_name = room?["name"] as? String
        self.moved = room?["moved"] as? Bool ?? false
        if let teacher = dict["teacher"] as? [String: Any] {
            self.teacher = Employee(teacher)
        }
        let teaching_group = dict["teaching_group"] as? [String: Any]
        self.group = teaching_group?["name"] as? String ?? "None"
        self.subject = teaching_group?["subject"] as? String ?? "None"
    }
}

/// A container for a Timetable Period
public struct Period: Hashable {
    /// If the period is a free period
    public var empty: Bool = true
    /// What time the period starts
    public var start_time: Date
    /// What time the period ends
    public var end_time: Date
    /// The ID of the period
    public var id: String
    /// The name of the period
    public var name: String
    /// The lesson for that period, nil if is free period. For more documentation see `Lesson`
    public var lesson: Lesson? {
        didSet {
            if lesson != nil {
                empty = false
            }
        }
    }
    
    init?(_ dict: [String: Any], day: Date?) {
        guard let tmpID = dict["id"],
              let name = dict["name"] as? String,
              let start = dict["start_time"] as? String,
              let end = dict["end_time"] as? String,
              let start_time = DateTime.dateFromTime(time: start, date: day),
              let end_time = DateTime.dateFromTime(time: end, date: day) else { return nil }
        self.id = String(describing: tmpID)
        self.name = name
        self.start_time = start_time
        self.end_time = end_time
        if let empty = dict["empty"] as? Bool {
            self.empty = empty
        }
        
    }
}
