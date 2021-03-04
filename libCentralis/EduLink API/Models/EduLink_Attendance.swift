//
//  EduLink_Attendance.swift
//  Centralis
//
//  Created by AW on 19/12/2020.
//

import UIKit

/// A model for working with attendance
public class EduLink_Attendance {
    /// Retrieve the attendance data of the curent user. For more documentation see `Attendance`
    /// - Parameter rootCompletion: The completion handler, for more documentation see `completionHandler`
    class public func attendance(learnerID: String = EduLinkAPI.shared.authorisedUser.id, _ rootCompletion: @escaping completionHandler) {
        let params: [String : String] = [
            "learner_id" : learnerID
        ]
        NetworkManager.requestWithDict(url: nil, requestMethod: "EduLink.Attendance", params: params, completion: { (success, dict) -> Void in
            if !success { return rootCompletion(false, "Network Error") }
            guard let result = dict["result"] as? [String : Any] else { return rootCompletion(false, "Unknown Error") }
            if !(result["success"] as? Bool ?? false) { return rootCompletion(false, (result["error"] as? String ?? "Unknown Error")) }
            var attendanceCache = Attendance()
            attendanceCache.show_lesson = result["show_lesson"] as? Bool ?? false
            attendanceCache.show_statutory = result["show_statutory"] as? Bool ?? false
            if let lesson = result["lesson"] as? [[String : Any]] {
                for lesson in lesson {
                    var l = AttendanceLesson()
                    l.subject = lesson["subject"] as? String ?? "Not Given"
                    var av = AttendanceValue()
                    av.present = lesson["present"] as? Int ?? 0
                    av.late = lesson["late"] as? Int ?? 0
                    av.unauthorised = lesson["unauthorised"] as? Int ?? 0
                    av.absent = lesson["absent"] as? Int ?? 0
                    l.values = av
                    if let exceptions = lesson["exceptions"] as? [[String : Any]] {
                        for exception in exceptions {
                            var e = AttendanceException()
                            e.date = exception["date"] as? String ?? "Not Given"
                            e.description = exception["description"] as? String ?? "Not Given"
                            e.type = exception["type"] as? String ?? "Not Given"
                            e.period = exception["period"] as? String ?? "Not Given"
                            l.exceptions.append(e)
                        }
                    }
                    attendanceCache.lessons.append(l)
                }
            }
            if let statutory = result["statutory"] as? [[String : Any]] {
                for statutory in statutory {
                    var s = AttendanceStatutory()
                    s.month = statutory["month"] as? String ?? "Not Given"
                    var av = AttendanceValue()
                    av.present = statutory["present"] as? Int ?? 0
                    av.late = statutory["late"] as? Int ?? 0
                    av.unauthorised = statutory["unauthorised"] as? Int ?? 0
                    av.absent = statutory["absent"] as? Int ?? 0
                    s.values = av
                    EduLinkAPI.shared.attendance.statutoryyear.values.present += av.present
                    EduLinkAPI.shared.attendance.statutoryyear.values.absent += av.absent
                    EduLinkAPI.shared.attendance.statutoryyear.values.late += av.late
                    EduLinkAPI.shared.attendance.statutoryyear.values.unauthorised += av.unauthorised
                    if let exceptions = statutory["exceptions"] as? [[String : Any]] {
                        for exception in exceptions {
                            var e = AttendanceException()
                            e.date = exception["date"] as? String ?? "Not Given"
                            e.description = exception["description"] as? String ?? "Not Given"
                            e.type = exception["type"] as? String ?? "Not Given"
                            e.period = exception["period"] as? String ?? "Not Given"
                            s.exceptions.append(e)
                            attendanceCache.statutoryyear.exceptions.append(e)
                        }
                    }
                    attendanceCache.statutory.append(s)
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
    public var present: Int!
    /// The number of unauthorised absence marks
    public var unauthorised: Int!
    /// The number of absenct marks
    public var absent: Int!
    /// The number of late marks
    public var late: Int!
    
    /// The init method, sets all values to 0
    init() {
        self.present = 0
        self.unauthorised = 0
        self.absent = 0
        self.late = 0
    }
}

/// A container for `AttendanceValue` colours. The colours are generated based on their string name.
public struct AttendanceColours {
    /// The colour for present marks
    public var present: CGColor!
    /// The colour for unauthorised marks
    public var unauthorised: CGColor!
    /// The colour for absent marks
    public var absent: CGColor!
    /// The colour for late marks
    public var late: CGColor!
    
    /// Sets the colour of all the values, based on their string names
    public init() {
        let c = ColourConverter()
        self.present = c.colourFromString("Present")
        self.unauthorised = c.colourFromString("Unauthorised")
        self.late = c.colourFromString("Late")
        self.absent = c.colourFromString("Absent")
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
    public var date: String!
    /// The description of the exception
    public var description: String!
    /// The type of exception
    public var type: String!
    /// The period of the exception
    public var period: String!
}

/// A container for an AttendanceLesson.
public struct AttendanceLesson {
    /// The subject for the attendance
    public var subject: String!
    /// The attendance values for the lesson, for more documentation see `AttendanceValue`
    public var values = AttendanceValue()
    /// An array of exceptions for that lesson, for more documentation see `AttendanceException`
    public var exceptions = [AttendanceException]()
}

/// A container for an Attendance Statutory Month
public struct AttendanceStatutory {
    /// The name of the month
    public var month: String!
    /// The attendance values for that month, for more documentation see `AttendanceValue`
    public var values = AttendanceValue()
    /// An array of attendance exceptions for that month, for more documenation see `AttendanceException`
    public var exceptions = [AttendanceException]()
}

/// A container for Attendance
public struct Attendance {
    /// A shared container for AttendanceColours, for more documenation see `AttendanceColours`
    public var attendance_colours = AttendanceColours()
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
