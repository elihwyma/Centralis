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
    
    public func addPair(bold: String, normal: String) {
        let boldAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 17, weight: .bold)
        ]
        let fontAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 17)
        ]
        
        let boldText = NSAttributedString(string: bold, attributes: boldAttributes)
        let normalText = NSAttributedString(string: normal, attributes: fontAttributes)
        self.att?.append(boldText)
        self.att?.append(normalText)
    }
    
    public func achievement(_ achievement: Achievement) {
        self.att = NSMutableAttributedString()
        self.addPair(bold: "Date: ", normal: "\(achievement.date!)\n")
        for employee in EduLinkAPI.shared.employees where employee.id == achievement.employee_id {
            self.addPair(bold: "Teacher: ", normal: "\(employee.title!) \(employee.forename!) \(employee.surname!)\n")
        }
        self.addPair(bold: "Lesson: ", normal: "\(achievement.lesson_information ?? "Not Given")\n")
        self.addPair(bold: "Points: ", normal: "\(achievement.points!)\n")
        for type in achievement.type_ids {
            for at in EduLinkAPI.shared.achievementBehaviourLookups.achievement_types where at.id == type {
                self.addPair(bold: "Type: ", normal: "\(at.description!)\n")
            }
        }
        self.addPair(bold: "Comment: ", normal: "\(achievement.comments!)")
    }
    
    public func catering(_ transaction: CateringTransaction) {
        self.att = NSMutableAttributedString()
        self.addPair(bold: "Date & Time: ", normal: transaction.date)
        self.addPair(bold: "\nItems & Amount: \n", normal: "")
        for (index, item) in transaction.items.enumerated() {
            let ext: String = ((index == transaction.items.count - 1) ? "" : "\n")
            self.addPair(bold: "", normal: "\(item.item!): \(self.formatPrice(item.price))\(ext)")
        }
    }
    
    public func personal(_ personal: Personal) {
        self.att = NSMutableAttributedString()
        self.addPair(bold: "Forename: ", normal: "\(personal.forename ?? "Not Given")\n")
        self.addPair(bold: "Surname: ", normal: "\(personal.surname ?? "Not Given")\n")
        self.addPair(bold: "Gender: ", normal: "\(personal.gender ?? "Not Given")\n")
        self.addPair(bold: "Admission Number: ", normal: "\(personal.admission_number ?? 0)\n")
        self.addPair(bold: "Pupil Number: ", normal: "\(personal.unique_pupil_number ?? "Not Given")\n")
        self.addPair(bold: "Learner Number: ", normal: "\(personal.unique_learner_number ?? 0)\n")
        self.addPair(bold: "Date of Birth: ", normal: "\(personal.date_of_birth ?? "Not Given")\n")
        self.addPair(bold: "Admission Date: ", normal: "\(personal.admission_date ?? "Not Given")\n")
        self.addPair(bold: "Email: ", normal: "\(personal.email ?? "Not Given")\n")
        self.addPair(bold: "Phone: ", normal: "\(personal.phone ?? "Not Given")\n")
        self.addPair(bold: "Address: ", normal: "\(personal.address ?? "Not Given")\n")
        self.addPair(bold: "Form Group: ", normal: "\(personal.form ?? "Not Given")\n")
        self.addPair(bold: "Form Room: ", normal: "\(personal.room_code ?? "Not Given")\n")
        self.addPair(bold: "Teacher: ", normal: "\(personal.form_teacher ?? "Not Given")\n")
        self.addPair(bold: "House: ", normal: "\(personal.house_group ?? "Not Given")")
    }

}

extension TextViewCell {
    private func formatPrice(_ number: Double) -> String {
        let numstring = String(format: "%03.2f", number)
        return "£\(numstring)"
    }
}
