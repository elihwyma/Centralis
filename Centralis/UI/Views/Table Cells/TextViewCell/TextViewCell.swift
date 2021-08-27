//
//  CateringCell.swift
//  Centralis
//
//  Created by AW on 02/12/2020.
//

import UIKit
//import libCentralis

class TextViewCell: UITableViewCell {

    @IBOutlet weak var transactionsView: UITextView!
    var att: NSMutableAttributedString?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    public func achievement(_ achievement: Achievement) {
        self.att = NSMutableAttributedString()
        self.att?.addPair(bold: "Date: ", normal: "\(achievement.date.shortDate)\n")
        if let employee = EduLinkAPI.shared.authorisedSchool.schoolInfo.employees[achievement.employee_id ?? "-1"] {
            self.att?.addPair(bold: "Teacher: ", normal: "\(employee.title) \(employee.forename) \(employee.surname)\n")
        }
        if let lesson = achievement.lesson_information {
            self.att?.addPair(bold: "Lesson: ", normal: "\(lesson)\n")
        }
        self.att?.addPair(bold: "Points: ", normal: "\(achievement.points)\n")
        for type in achievement.type_ids ?? [] {
            for at in EduLinkAPI.shared.achievementBehaviourLookups.achievement_types where at.id == "\(type)" {
                self.att?.addPair(bold: "Type: ", normal: "\(at.description)\n")
            }
        }
        if let comment = achievement.comments {
            self.att?.addPair(bold: "Comment: ", normal: "\(comment)")
        }
    }
    
    public func behaviour(_ behaviour: Behaviour) {
        self.att = NSMutableAttributedString()
        self.att?.addPair(bold: "Date: ", normal: "\(behaviour.date.shortDate)\n")
        if let employee = EduLinkAPI.shared.authorisedSchool.schoolInfo.employees[behaviour.recorded_id ?? "-1"] {
            self.att?.addPair(bold: "Teacher: ", normal: "\(employee.title) \(employee.forename) \(employee.surname)\n")
        }
        if let lesson = behaviour.lesson_information {
            self.att?.addPair(bold: "Lesson: ", normal: "\(lesson)\n")
        }
        self.att?.addPair(bold: "Points: ", normal: "\(behaviour.points)\n")
        for type in behaviour.type_ids ?? [] {
            for bt in EduLinkAPI.shared.achievementBehaviourLookups.behaviour_types where bt.id == "\(type)" {
                self.att?.addPair(bold: "Type: ", normal: "\(bt.description)\n")
            }
        }
        if let comment = behaviour.comments {
            self.att?.addPair(bold: "Comment: ", normal: "\(comment)")
        }
    }
 
    public func detention(_ detention: Detention) {
        self.att = NSMutableAttributedString()
        self.att?.addPair(bold: "Date: ", normal: "\(detention.date.shortDate)\n")
        self.att?.addPair(bold: "Start Time: ", normal: "\(detention.start_time.time)\n")
        self.att?.addPair(bold: "End Time: ", normal: "\(detention.end_time.time)\n")
        if let location = detention.location {
            self.att?.addPair(bold: "Location: ", normal: "\(location)\n")
        }
        if let attended = detention.attended {
            self.att?.addPair(bold: "Attended: ", normal: "\(attended)\n")
        }
        if let non_attendance_reason = detention.non_attendance_reason {
            self.att?.addPair(bold: "Not Attended Reason: ", normal: "\(non_attendance_reason)\n")
        }
        self.att?.addPair(bold: "Description: ", normal: "\(detention.description!)")
    }
        
    public func catering(_ transaction: CateringTransaction) {
        self.att = NSMutableAttributedString()
        self.att?.addPair(bold: "Date & Time: ", normal: transaction.date.dateTime)
        self.att?.addPair(bold: "\nItems & Amount: \n", normal: "")
        for (index, item) in transaction.items.enumerated() {
            let ext: String = ((index == transaction.items.count - 1) ? "" : "\n")
            self.att?.addPair(bold: "", normal: "\(item.item): \(self.formatPrice(item.price))\(ext)")
        }
    }
    
    public func timetable(_ period: Period) {
        self.att = NSMutableAttributedString()
        self.att?.addPair(bold: "Period: ", normal: "\(period.name)\n")
        if let lesson = period.lesson {
            self.att?.addPair(bold: "Subject: ", normal: "\(lesson.subject) : \(lesson.group)\n")
            if let room_name = lesson.room_name,
               !room_name.isEmpty {
                self.att?.addPair(bold: "Room: ", normal: "\(room_name)\n")
            }
            if let employee = lesson.teacher,
               !employee.name.isEmpty {
                self.att?.addPair(bold: "Teacher: ", normal: "\(employee.name)\n")
            }
        }
        self.att?.addPair(bold: "Start: ", normal: "\(period.start_time.time)\n")
        self.att?.addPair(bold: "End: ", normal: period.end_time.time)
    }
    
    public func document(_ document: Document) {
        self.att = NSMutableAttributedString()
        self.att?.addPair(bold: "Summary: ", normal: "\(document.summary)\n")
        self.att?.addPair(bold: "Type: ", normal: "\(document.type)\n")
        self.att?.addPair(bold: "Date: ", normal: "\(document.last_updated.shortDate)")
    }

    public func exception(_ exception: AttendanceException) {
        self.att = NSMutableAttributedString()
        self.att?.addPair(bold: "Data: ", normal: "\(exception.date)\n")
        self.att?.addPair(bold: "Type: ", normal: "\(exception.type)\n")
        self.att?.addPair(bold: "Period: ", normal: "\(exception.period)\n")
        self.att?.addPair(bold: "Description: ", normal: "\(exception.description ?? "None")")
    }
}

extension TextViewCell {
    private func formatPrice(_ number: Double) -> String {
        let numstring = String(format: "%03.2f", number)
        return "£\(numstring)"
    }
}
