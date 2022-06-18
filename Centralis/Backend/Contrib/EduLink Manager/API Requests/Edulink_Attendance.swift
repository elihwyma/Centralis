//
//  Edulink_Attendance.swift
//  Centralis
//
//  Created by Somica on 04/04/2022.
//

import SerializedSwift
import Evander
import UIKit

final public class Attendance: Serializable {
    
    enum Colours {
        case present
        case unauthorised
        case absent
        case late
     
        var rawValue: UIColor {
            switch self {
            case .present: return #colorLiteral(red: 0.3568627451, green: 0.5490196078, blue: 0.3529411765, alpha: 1) //5B8C5A
            case .unauthorised: return #colorLiteral(red: 0.2470588235, green: 0.5333333333, blue: 0.7725490196, alpha: 1) //3F88C5
            case .absent: return #colorLiteral(red: 0.9411764706, green: 0.5294117647, blue: 0, alpha: 1) //F08700
            case .late: return #colorLiteral(red: 0.8901960784, green: 0.3960784314, blue: 0.3568627451, alpha: 1) //E3655B 
            }
        }
    }
    
    @Serialized(default: []) var lesson: [Lesson]
    @Serialized(default: []) var statutory: [Lesson]
    
    public var statutoryYear: Lesson {
        let values = Values()
        var exceptions = [Exception]()
        for month in statutory {
            values += month.values
            exceptions += month.exceptions
        }
        return Lesson(from: "Statutory Year", with: exceptions, values: values)
    }
    
    public struct Exception: Serializable {
        @SerializedTransformable<DateConverter> var date: Date?
        @Serialized(default: "Not Provided") var description: String
        @Serialized(default: "Not Provided") var type: String
        @Serialized(default: "Not Provided") var period: String
        
        public init() {}
    }
    
    public struct Values: Serializable {
        @Serialized(default: 0) var present: Int
        @Serialized(default: 0) var absent: Int
        @Serialized(default: 0) var late: Int
        @Serialized(default: 0) var unauthorised: Int
        
        public lazy var total: Int = {
            present + absent + late + unauthorised
        }()
        
        public lazy var fractionalValues: (present: Double, absent: Double, late: Double, unauthorised: Double) = {
            return (Double(present) / Double(total), Double(absent) / Double(total), Double(late) / Double(total), Double(unauthorised) / Double(total))
        }()
        
        public init() {}
        
        public static func +=(lhs: Values, rhs: Values) {
            lhs.present += rhs.present
            lhs.absent += rhs.absent
            lhs.late += rhs.late
            lhs.unauthorised += rhs.unauthorised
        }
    }
    
    public class Lesson: Serializable {
        @Serialized("subject", alternateKey: "month") var lesson: String
        @Serialized(default: []) var exceptions: [Exception]
        @Serialized var values: Values
        
        required public init() {}
        
        public init(from lesson: String, with exceptions: [Exception], values: Values) {
            self.lesson = lesson
            self.exceptions = exceptions
            self.values = values
        }
    }
    
    public class func updateAttendance(_ completion: @escaping (String?, Attendance?) -> Void) {
        guard PermissionManager.contains(.attendance) else { return completion(nil, Attendance()) }
        EvanderNetworking.edulinkDict(method: "EduLink.Attendance", params: [
            .learner_id,
            .format(value: 3)
        ]) { _, _, error, result in
            guard let result = result,
                  let jsonData = try? JSONSerialization.data(withJSONObject: result) else {
                      return completion(error ?? "Unknown Error", nil) }
            do {
                let attendance = try JSONDecoder().decode(Attendance.self, from: jsonData)
                attendance.statutory.sort { $0.lesson < $1.lesson }
                PersistenceDatabase.AttendanceDatabase.saveAttendance(attendance: attendance)
                completion(nil, attendance)
            } catch {
                completion(error.localizedDescription, nil)
            }
        }
    }
    
    public init() {}
    
    public init(lesson: [Lesson] = [], statutory: [Lesson] = []) {
        self.lesson = lesson
        self.statutory = statutory
    }
    
}
