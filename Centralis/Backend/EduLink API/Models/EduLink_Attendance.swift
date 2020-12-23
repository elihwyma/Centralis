//
//  EduLink_Attendance.swift
//  Centralis
//
//  Created by Amy While on 19/12/2020.
//

import UIKit

class EduLink_Attendance {
    public func attendance() {
        let url = URL(string: "\(EduLinkAPI.shared.authorisedSchool.server!)?method=EduLink.Attendance")!
        let headers: [String : String] = ["Content-Type" : "application/json;charset=utf-8"]
        let body = "{\"jsonrpc\":\"2.0\",\"method\":\"EduLink.Attendance\",\"params\":{\"learner_id\":\"\(EduLinkAPI.shared.authorisedUser.id!)\",\"authtoken\":\"\(EduLinkAPI.shared.authorisedUser.authToken!)\",\"format\":\"3\"},\"uuid\":\"\(UUID.shared.uuid)\",\"id\":\"1\"}"
        NetworkManager.shared.requestWithDict(url: url, method: "POST", headers: headers, jsonbody: body, completion: { (success, dict) -> Void in
            if success {
                if let result = dict["result"] as? [String : Any] {
                    if !(result["success"] as! Bool) {
                        NotificationCenter.default.post(name: .FailedAttendance, object: nil)
                    }
                    EduLinkAPI.shared.attendance.show_lesson = result["show_lesson"] as? Bool ?? false
                    EduLinkAPI.shared.attendance.show_statutory = result["show_statutory"] as? Bool ?? false
                    if let lesson = result["lesson"] as? [[String : Any]] {
                        EduLinkAPI.shared.attendance.lessons.removeAll()
                        for lesson in lesson {
                            var l = AttendanceLesson()
                            l.subject = lesson["subject"] as? String ?? "Not Given"
                            if let values = lesson["values"] as? [String : Any] {
                                var av = AttendanceValue()
                                av.present = values["present"] as? Int ?? 0
                                av.late = values["late"] as? Int ?? 0
                                av.unauthorised = values["unauthorised"] as? Int ?? 0
                                av.absent = values["absent"] as? Int ?? 0
                                l.values = av
                            }
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
                            EduLinkAPI.shared.attendance.lessons.append(l)
                        }
                    }
                    if let statutory = result["statutory"] as? [[String : Any]] {
                        EduLinkAPI.shared.attendance.statutory.removeAll()
                        for statutory in statutory {
                            var s = AttendanceStatutory()
                            s.month = statutory["month"] as? String ?? "Not Given"
                            if let values = statutory["values"] as? [String : Any] {
                                var av = AttendanceValue()
                                av.present = values["present"] as? Int ?? 0
                                av.late = values["late"] as? Int ?? 0
                                av.unauthorised = values["unauthorised"] as? Int ?? 0
                                av.absent = values["absent"] as? Int ?? 0
                                s.values = av
                                EduLinkAPI.shared.attendance.statutoryyear.values.present += av.present
                                EduLinkAPI.shared.attendance.statutoryyear.values.absent += av.absent
                                EduLinkAPI.shared.attendance.statutoryyear.values.late += av.late
                                EduLinkAPI.shared.attendance.statutoryyear.values.unauthorised += av.unauthorised
                            }
                            if let exceptions = statutory["exceptions"] as? [[String : Any]] {
                                for exception in exceptions {
                                    var e = AttendanceException()
                                    e.date = exception["date"] as? String ?? "Not Given"
                                    e.description = exception["description"] as? String ?? "Not Given"
                                    e.type = exception["type"] as? String ?? "Not Given"
                                    e.period = exception["period"] as? String ?? "Not Given"
                                    s.exceptions.append(e)
                                    EduLinkAPI.shared.attendance.statutoryyear.exceptions.append(e)
                                }
                            }
                            EduLinkAPI.shared.attendance.statutory.append(s)
                        }
                    }
                    EduLinkAPI.shared.attendance.lessons = EduLinkAPI.shared.attendance.lessons.sorted(by: { $0.subject < $1.subject })
                    EduLinkAPI.shared.attendance.statutory = EduLinkAPI.shared.attendance.statutory.sorted(by: { $0.month > $1.month })
                    NotificationCenter.default.post(name: .SuccesfulAttendance, object: nil)
                }
            } else {
                NotificationCenter.default.post(name: .NetworkError, object: nil)
            }
        })
    }
}

struct AttendanceValue {
    var present: Int!
    var unauthorised: Int!
    var absent: Int!
    var late: Int!
    
    init() {
        self.present = 0
        self.unauthorised = 0
        self.absent = 0
        self.late = 0
    }
}

struct AttendanceColours {
    var present: UIColor!
    var unauthorised: UIColor!
    var absent: UIColor!
    var late: UIColor!
    
    init() {
        let c = ColourConverter()
        self.present = c.colourFromString("Present")
        self.unauthorised = c.colourFromString("Unauthorised")
        self.late = c.colourFromString("Late")
        self.absent = c.colourFromString("Absent")
    }
}

struct StatutoryYear {
    var values = AttendanceValue()
    var exceptions = [AttendanceException]()
}

struct AttendanceException {
    var date: String!
    var description: String!
    var type: String!
    var period: String!
}

struct AttendanceLesson {
    var subject: String!
    var values = AttendanceValue()
    var exceptions = [AttendanceException]()
}

struct AttendanceStatutory {
    var month: String!
    var values = AttendanceValue()
    var exceptions = [AttendanceException]()
}

struct Attendance {
    var attendance_colours = AttendanceColours()
    var lessons = [AttendanceLesson]()
    var statutory = [AttendanceStatutory]()
    var statutoryyear = StatutoryYear()
    var show_statutory = false
    var show_lesson = false
}
