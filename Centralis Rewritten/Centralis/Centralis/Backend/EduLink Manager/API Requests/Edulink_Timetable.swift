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
    
    fileprivate final class _Room: EdulinkStore {
        @Serialized(default: false) var moved: Bool
    }
    
    fileprivate final class _TeachingGroup: EdulinkStore {
        @Serialized var subject: String
    }
    
    fileprivate final class _Lesson: Serializable {
        @SerializedTransformable<IDTransformer> var period_id: String!
        @Serialized var room: _Room
        @Serialized var teachers: String
        @Serialized var teaching_group: _TeachingGroup
        
        required public init() {}
        
        required public convenience init(from decoder: Decoder) throws {
            self.init()
            try decode(from: decoder)
            
            if period_id == nil {
                period_id = "-1"
            }
        }
    }
    
    public final class Period: Codable {
        var empty: Bool
        var end_time: String
        var start_time: String
        var name: String
        var id: String
        
        var moved: Bool?
        var subject: String?
        var room: String?
        var teachers: String?
        
        fileprivate init(lesson: _Lesson?, period: _Period) {
            empty = period.empty
            end_time = period.end_time
            start_time = period.start_time
            name = period.name
            id = period.id
            
            moved = lesson?.room.moved
            subject = lesson?.teaching_group.subject
            room = lesson?.room.name
            teachers = lesson?.teachers
        }
    }
    
    public final class Day: Codable {
        var name: String
        var date: Date
        var periods: [Period]
        
        init(name: String, date: Date, periods: [Period]) {
            self.name = name 
            self.date = date
            self.periods = periods
        }
    }
    
    public final class Week: Codable {
        var name: String
        var days: [Day]
        
        init(name: String, days: [Day]) {
            self.name = name
            self.days = days
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
        let first = weeks[0]
        guard let day = first.days.first else { return nil }
        return (first, day)
    }
    
    private class func convert(_ _weeks: [_Week]) -> [Week] {
        _weeks.map { week -> Week in
            let days = week.days.compactMap { day -> Day? in
                guard let date = day.date else { return nil }
                let periods = day.periods.map { period -> Period in
                    Period(lesson: day.lessons.first { $0.period_id == period.id }, period: period)
                }
                return Day(name: day.name, date: date, periods: periods)
            }
            return Week(name: week.name, days: days)
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
                let convertedWeeks = convert(weeks)
                if !indexing {
                    
                }
                return completion(nil, convert(weeks))
            } catch {
                return completion(error.localizedDescription, nil)
            }
        }
    }
}
