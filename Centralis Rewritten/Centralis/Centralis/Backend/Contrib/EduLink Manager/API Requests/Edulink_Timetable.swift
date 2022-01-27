//
//  Edulink_Timetable.swift
//  Centralis
//
//  Created by Somica on 07/12/2021.
//

import Foundation
import Evander
import SerializedSwift

final public class Timetable: EdulinkBase {
    
    private static var current: String {
        date(for: Date())
    }
    
    private static func date(for date: Date) -> String {
        let calendar = Calendar.current

        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        return "\(year)-\(String(format: "%02d", month))-\(String(format: "%02d", day))"
    }
    
    fileprivate final class _Week: Serializable {
        @Serialized var name: String
        @Serialized(default: false) var is_current: Bool
        @Serialized(default: []) var days: [_Day]
        
        required public init() {}
    }
    
    fileprivate final class _Day: Serializable {
        @SerializedTransformable<DateConverter> var date: Date?
        @Serialized(default: false) var is_current: Bool
        @Serialized var name: String
        @Serialized var original_name: String
        @Serialized(default: []) var periods: [_Period]
        @Serialized(default: []) var lessons: [_Lesson]
        
        required public init() {}
    }
    
    fileprivate final class _Period: EdulinkBase {
        @Serialized var empty: Bool
        @Serialized var end_time: String
        @Serialized var start_time: String
        @Serialized var name: String
    }
    
    fileprivate final class _Room: EdulinkBase {
        @Serialized(default: false) var moved: Bool
        @Serialized var name: String?
    }
    
    fileprivate final class _TeachingGroup: EdulinkStore {
        @Serialized var subject: String
    }
    
    fileprivate final class _Lesson: Serializable {
        @SerializedTransformable<IDTransformer>(fallback: "-1") var period_id: String!
        @Serialized var room: _Room
        @Serialized var teachers: String
        @Serialized var teaching_group: _TeachingGroup
        
        required public init() {}
    }
    
    public final class Period: Codable, Equatable {
        var empty: Bool
        var end_time: String
        var start_time: String
        var name: String
        var id: String
        
        var moved: Bool
        var subject: String?
        var room: String?
        var teachers: String?
        var group: String?
        
        fileprivate init(lesson: _Lesson?, period: _Period) {
            empty = period.empty
            end_time = period.end_time
            start_time = period.start_time
            name = period.name
            id = period.id
            
            moved = lesson?.room.moved ?? false
            subject = lesson?.teaching_group.subject
            room = lesson?.room.name
            teachers = lesson?.teachers
            group = lesson?.teaching_group.name
        }
        
        public static func == (lhs: Timetable.Period, rhs: Timetable.Period) -> Bool {
            return lhs.empty == rhs.empty &&
            lhs.end_time == rhs.end_time &&
            lhs.start_time == rhs.start_time &&
            lhs.name == rhs.name &&
            lhs.id == rhs.id &&
            lhs.moved == rhs.moved &&
            lhs.subject == rhs.subject &&
            lhs.room == rhs.room &&
            lhs.teachers == rhs.teachers
        }
    }
    
    public final class Day: Codable, Equatable {
        var name: String
        var date: Date
        var periods: [Period]
        
        init(name: String, date: Date, periods: [Period]) {
            self.name = name 
            self.date = date
            self.periods = periods
        }
        
        public static func == (lhs: Timetable.Day, rhs: Timetable.Day) -> Bool {
            return lhs.name == rhs.name &&
            lhs.date == rhs.date &&
            lhs.periods == rhs.periods
        }
    }
    
    public final class Week: Codable, Equatable {
        var name: String
        var days: [Day]
        
        init(name: String, days: [Day]) {
            self.name = name
            self.days = days
        }
        
        public static func == (lhs: Timetable.Week, rhs: Timetable.Week) -> Bool {
            lhs.days == rhs.days && lhs.name == rhs.name
        }
    }
    
    public class func getCurrent(_ weeks: [Week]) -> (Week, Day)? {
        guard !weeks.isEmpty else { return nil }
        let current = Calendar.current
        for week in weeks {
            for day in week.days {
                if current.isDateInToday(day.date) {
                    return (week, day)
                }
            }
        }
        let today = Date()
        for week in weeks {
            for day in week.days {
                if today < day.date {
                    return (week, day)
                }
            }
        }
        let first = weeks.last!
        guard let day = first.days.first else { return nil }
        return (first, day)
    }
    
    private class func convert(_ _weeks: [_Week]) -> [Week] {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM y"
        return _weeks.map { week -> Week in
            let days = week.days.compactMap { day -> Day? in
                guard let date = day.date else { return nil }
                let periods = day.periods.map { period -> Period in
                    Period(lesson: day.lessons.first { $0.period_id == period.id }, period: period)
                }
                return Day(name: day.name, date: date, periods: periods)
            }
            let name: String = {
                if let day = days.first {
                    return formatter.string(from: day.date)
                }
                return week.name
            }()
            return Week(name: name, days: days)
        }
    }
    
    public class func updateTimetable(indexing: Bool = false, for week: Date = Date(), _ completion: @escaping (String?, [Week]?) -> Void) {
        EvanderNetworking.edulinkDict(method: "EduLink.Timetable", params: [
            .learner_id,
            .custom(key: "date", value: date(for: week))
        ]) { _, _, error, result in
            guard let result = result,
                  let _weeks = result["weeks"] as? [[String: Any]],
                  let weeksCurrent = try? JSONSerialization.data(withJSONObject: _weeks) else {
                return completion(error ?? "Unknown Error", nil)
            }
            do {
                let weeks = try JSONDecoder().decode([_Week].self, from: weeksCurrent)
                var convertedWeeks = convert(weeks)
                if !indexing {
                    PersistenceDatabase.TimetableDatabase.changes(newWeeks: &convertedWeeks)
                }
                return completion(nil, convertedWeeks)
            } catch {
                return completion(error.localizedDescription, nil)
            }
        }
    }
}
