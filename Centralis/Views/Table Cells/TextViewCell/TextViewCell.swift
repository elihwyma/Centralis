//
//  CateringCell.swift
//  Centralis
//
//  Created by Amy While on 02/12/2020.
//

import UIKit

class TextViewCell: UITableViewCell {

    @IBOutlet weak var transactionsView: UITextView!
    var att: NSMutableAttributedString?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    public func achievement(_ achievement: Achievement) {
        self.att = NSMutableAttributedString()
        self.att?.addPair(bold: "Date: ", normal: "\(achievement.date!)\n")
        for employee in EduLinkAPI.shared.employees where employee.id == achievement.employee_id {
            self.att?.addPair(bold: "Teacher: ", normal: "\(employee.title!) \(employee.forename!) \(employee.surname!)\n")
        }
        self.att?.addPair(bold: "Lesson: ", normal: "\(achievement.lesson_information ?? "Not Given")\n")
        self.att?.addPair(bold: "Points: ", normal: "\(achievement.points!)\n")
        for type in achievement.type_ids {
            for at in EduLinkAPI.shared.achievementBehaviourLookups.achievement_types where at.id == type {
                self.att?.addPair(bold: "Type: ", normal: "\(at.description!)\n")
            }
        }
        self.att?.addPair(bold: "Comment: ", normal: "\(achievement.comments!)")
    }
    
    public func catering(_ transaction: CateringTransaction) {
        self.att = NSMutableAttributedString()
        self.att?.addPair(bold: "Date & Time: ", normal: transaction.date)
        self.att?.addPair(bold: "\nItems & Amount: \n", normal: "")
        for (index, item) in transaction.items.enumerated() {
            let ext: String = ((index == transaction.items.count - 1) ? "" : "\n")
            self.att?.addPair(bold: "", normal: "\(item.item!): \(self.formatPrice(item.price))\(ext)")
        }
    }
    
    public func personal(_ personal: Personal) {
        self.att = NSMutableAttributedString()
        self.att?.addPair(bold: "Forename: ", normal: "\(personal.forename ?? "Not Given")\n")
        self.att?.addPair(bold: "Surname: ", normal: "\(personal.surname ?? "Not Given")\n")
        self.att?.addPair(bold: "Gender: ", normal: "\(personal.gender ?? "Not Given")\n")
        self.att?.addPair(bold: "Admission Number: ", normal: "\(personal.admission_number ?? 0)\n")
        self.att?.addPair(bold: "Pupil Number: ", normal: "\(personal.unique_pupil_number ?? "Not Given")\n")
        self.att?.addPair(bold: "Learner Number: ", normal: "\(personal.unique_learner_number ?? 0)\n")
        self.att?.addPair(bold: "Date of Birth: ", normal: "\(personal.date_of_birth ?? "Not Given")\n")
        self.att?.addPair(bold: "Admission Date: ", normal: "\(personal.admission_date ?? "Not Given")\n")
        self.att?.addPair(bold: "Email: ", normal: "\(personal.email ?? "Not Given")\n")
        self.att?.addPair(bold: "Phone: ", normal: "\(personal.phone ?? "Not Given")\n")
        self.att?.addPair(bold: "Address: ", normal: "\(personal.address ?? "Not Given")\n")
        self.att?.addPair(bold: "Form Group: ", normal: "\(personal.form ?? "Not Given")\n")
        self.att?.addPair(bold: "Form Room: ", normal: "\(personal.room_code ?? "Not Given")\n")
        self.att?.addPair(bold: "Teacher: ", normal: "\(personal.form_teacher ?? "Not Given")\n")
        self.att?.addPair(bold: "House: ", normal: "\(personal.house_group ?? "Not Given")")
    }

}

extension TextViewCell {
    private func formatPrice(_ number: Double) -> String {
        let numstring = String(format: "%03.2f", number)
        return "£\(numstring)"
    }
}
