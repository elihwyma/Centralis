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
        let date = Date()
        let calendar = Calendar.current

        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        return "\(year)-\(String(format: "%02d", month))-\(String(format: "%02d", day))"
    }
    
    public final class Week: Serializable {
        @Serialized var name: String
        @Serialized(default: false) var is_current: Bool
        @Serialized(default: []) var days: [Day]
        
        required public init() {}
    }
    
    public final class Day: Serializable {
        @SerializedTransformable<DateConverter> var date: Date?
        @Serialized(default: false) var is_current: Bool
        @Serialized var name: String
        @Serialized var original_name: String
        @Serialized(default: []) var periods: [Period]
        @Serialized(default: []) var lessons: [Lesson]
        
        required public init() {}
    }
    
    public final class Period: EdulinkBase {
        @Serialized var empty: Bool
        @Serialized var end_time: String
        @Serialized var start_time: String
        @Serialized var name: String
    }
    
    public final class Room: EdulinkStore {
        @Serialized(default: false) var moved: Bool
    }
    
    public final class TeachingGroup: EdulinkStore {
        @Serialized var subject: String
    }
    
    public final class Lesson: Serializable {
        @SerializedTransformable<IDTransformer> var period_id: String!
        @Serialized var room: Room
        @Serialized var teachers: String
        @Serialized var teaching_group: TeachingGroup
        
        required public init() {}
        
        required public convenience init(from decoder: Decoder) throws {
            self.init()
            try decode(from: decoder)
            
            if period_id == nil {
                period_id = "-1"
            }
        }
    }
    
    public class func updateTimetable(indexing: Bool = false, _ completion: @escaping (String?, [Week]?) -> Void) {
        EvanderNetworking.edulinkDict(method: "EduLink.Timetable", params: [
            .learner_id,
            .custom(key: "date", value: current)
        ]) { _, _, error, result in
            guard let result = result,
                  let _weeks = result["weeks"] as? [[String: Any]],
                  let weeksCurrent = try? JSONSerialization.data(withJSONObject: _weeks) else {
                return completion(error ?? "Unknown Error", nil)
            }
            do {
                let weeks = try JSONDecoder().decode([Week].self, from: weeksCurrent)
                return completion(nil, weeks)
            } catch {
                return completion(error.localizedDescription, nil)
            }
        }
    }
}
