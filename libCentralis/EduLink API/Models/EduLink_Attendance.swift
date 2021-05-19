//
//  EduLink_Attendance.swift
//  Centralis
//
//  Created by AW on 19/12/2020.
//

import CoreGraphics
import Foundation

/// A model for working with attendance
public class EduLink_Attendance {
    /// Retrieve the attendance data of the curent user. For more documentation see `Attendance`
    /// - Parameter rootCompletion: The completion handler, for more documentation see `completionHandler`
    class public func attendance(learnerID: String = EduLinkAPI.shared.authorisedUser.id, _ rootCompletion: @escaping completionHandler) {
        let params: [String: AnyEncodable] = [
            "learner_id": AnyEncodable(learnerID),
            "format": AnyEncodable(3)
        ]
        NetworkManager.requestWithDict(url: nil, requestMethod: "EduLink.Attendance", params: params, completion: { (success, dict) -> Void in
            if !success { return rootCompletion(false, "Network Error") }
            guard let result = dict["result"] as? [String : Any] else { return rootCompletion(false, "Unknown Error") }
            if !(result["success"] as? Bool ?? false) { return rootCompletion(false, (result["error"] as? String ?? "Unknown Error")) }
            var attendanceCache = Attendance()
            attendanceCache.show_lesson = result["show_lesson"] as? Bool ?? false
            attendanceCache.show_statutory = result["show_statutory"] as? Bool ?? false
            if let lessons = result["lesson"] as? [[String: Any]] {
                for lessonDict in lessons {
                    if let lesson = AttendanceLesson(lessonDict) {
                        attendanceCache.lessons.append(lesson)
                    }
                }
            }
            if let statutorys = result["statutory"] as? [[String : Any]] {
                for statutoryDict in statutorys {
                    guard let statutory = AttendanceStatutory(statutoryDict) else { continue }
                    attendanceCache.statutory.append(statutory)
                    attendanceCache.statutoryyear.values.present += statutory.values.present
                    attendanceCache.statutoryyear.values.absent += statutory.values.absent
                    attendanceCache.statutoryyear.values.late += statutory.values.late
                    attendanceCache.statutoryyear.values.unauthorised += statutory.values.unauthorised
                    attendanceCache.statutoryyear.exceptions += statutory.exceptions
                }
            }
            attendanceCache.lessons = attendanceCache.lessons.sorted(by: { $0.subject < $1.subject })
            attendanceCache.statutory = attendanceCache.statutory.sorted(by: { $0.month > $1.month })
            if EduLinkAPI.shared.authorisedUser.id == learnerID { EduLinkAPI.shared.attendance = attendanceCache } else {
                if let index = EduLinkAPI.shared.authorisedUser.children.firstIndex(where: {$0.id == learnerID}) {
                    EduLinkAPI.shared.authorisedUser.children[index].attendance = attendanceCache
                }
            }
            rootCompletion(true, nil)
        })
    }
}

/// A container for attendance values
public struct AttendanceValue {
    /// The number of present marks
    public var present: Int
    /// The number of unauthorised absence marks
    public var unauthorised: Int
    /// The number of absenct marks
    public var absent: Int
    /// The number of late marks
    public var late: Int
    
    /// The init method, sets all values to 0
    init(_ dict: [String: Int]? = nil) {
        self.present = dict?["present"] ?? 0
        self.unauthorised = dict?["unauthorised"] ?? 0
        self.absent = dict?["absent"] ?? 0
        self.late = dict?["late"] ?? 0
    }
}

enum AttendanceColours {
    case present
    case unauthorised
    case absent
    case late
 
    var rawValue: CGColor {
        switch self {
        case .present: return #colorLiteral(red: 0.3568627451, green: 0.5490196078, blue: 0.3529411765, alpha: 1) //5B8C5A
        case .unauthorised: return #colorLiteral(red: 0.2470588235, green: 0.5333333333, blue: 0.7725490196, alpha: 1) //3F88C5
        case .absent: return #colorLiteral(red: 0.9411764706, green: 0.5294117647, blue: 0, alpha: 1) //F08700
        case .late: return #colorLiteral(red: 0.8901960784, green: 0.3960784314, blue: 0.3568627451, alpha: 1) //E3655B
        }
    }
}


/// A container for the Stautory Year
public struct StatutoryYear {
    /// The attendance values for that year, for more documenation see `AttendanceValue`
    public var values = AttendanceValue()
    /// An array of attendance exceptions for that year, for more documentation see `AttendanceException`
    public var exceptions = [AttendanceException]()
}

/// A container for an attendance exception
public struct AttendanceException {
    /// The date of the exception
    public var date: Date
    /// The description of the exception
    public var description: String?
    /// The type of exception
    public var type: String
    /// The period of the exception
    public var period: String
    
    init?(_ dict: [String: String]) {
        guard let tmpDate = dict["date"],
              let date = DateTime.date(tmpDate),
              let type = dict["type"],
              let period = dict["period"] else { return nil }
        self.date = date
        self.type = type
        self.period = period
        self.description = dict["description"]
    }
}

/// A container for an AttendanceLesson.
public struct AttendanceLesson {
    /// The subject for the attendance
    public var subject: String
    /// The attendance values for the lesson, for more documentation see `AttendanceValue`
    public var values: AttendanceValue
    /// An array of exceptions for that lesson, for more documentation see `AttendanceException`
    public var exceptions = [AttendanceException]()
    
    init?(_ dict: [String: Any]) {
        guard let subject = dict["subject"] as? String,
              let values = dict["values"] as? [String: Int] else { return nil }
        self.subject = subject
        self.values = AttendanceValue(values)
        if let exceptions = dict["exceptions"] as? [[String: String]] {
            for exceptionDict in exceptions {
                if let exception = AttendanceException(exceptionDict) {
                    self.exceptions.append(exception)
                }
            }
        }
    }
}

/// A container for an Attendance Statutory Month
public struct AttendanceStatutory {
    /// The name of the month
    public var month: String
    /// The attendance values for that month, for more documentation see `AttendanceValue`
    public var values: AttendanceValue
    /// An array of attendance exceptions for that month, for more documenation see `AttendanceException`
    public var exceptions = [AttendanceException]()
    
    init?(_ dict: [String: Any]) {
        guard let month = dict["month"] as? String,
              let values = dict["values"] as? [String: Int] else { return nil }
        self.month = month
        self.values = AttendanceValue(values)
        if let exceptions = dict["exceptions"] as? [[String: String]] {
            for exceptionDict in exceptions {
                if let exception = AttendanceException(exceptionDict) {
                    self.exceptions.append(exception)
                }
            }
        }
    }
}

/// A container for Attendance
public struct Attendance {
    /// An array of subject attendance records
    public var lessons = [AttendanceLesson]()
    /// An array of statutory month attendance record
    public var statutory = [AttendanceStatutory]()
    /// The current attendance for the statutory year
    public var statutoryyear = StatutoryYear()
    /// Should show statutory data
    public var show_statutory = false
    /// Should show lesson attendance
    public var show_lesson = false
}
