//
//  HomeworkCell.swift
//  Centralis
//
//  Created by AW on 05/12/2020.
//

import UIKit
//import libCentralis

class HomeworkCell: UITableViewCell {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var completedLabel: UILabel!
    @IBOutlet weak var completedView: UIView!
    var att: NSMutableAttributedString?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setup()
    }
    
    private func setup() {
        self.completedView.layer.masksToBounds = true
        self.completedView.layer.cornerRadius = self.completedView.frame.height / 2
    }
    
    public func homework(_ homework: Homework) {
        self.att = NSMutableAttributedString()
        self.att?.addPair(bold: "Due: ", normal: "\(homework.due_text!) : \(homework.due_date!)\n")
        self.att?.addPair(bold: "Name: ", normal: "\(homework.activity!)\n")
        self.att?.addPair(bold: "Subject: ", normal: "\(homework.subject!)\n")
        self.att?.addPair(bold: "Set: ", normal: "\(homework.available_text!) : \(homework.available_date!)")
        self.completedLabel.text = ((homework.completed!) ? "Completed" : "Not Completed")
        self.completedView.backgroundColor = homework.completed! ? .systemGreen : (isTomorrow(homework.due_date!) ? .systemOrange : .systemRed)
    }
    
    private func isTomorrow(_ due_date: String!) -> Bool {
        let dateFormatter = DateFormatter()
        let calendar = Calendar.current
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'"
        guard let dueDate = dateFormatter.date(from: due_date) else {
            return false
        }
        let dueDay = calendar.component(.day, from: dueDate)
        let currentDay = calendar.component(.day, from: Date())
        if dueDay + 1 == currentDay && currentDay < dueDay {
            return true
        } 
        return false
    }
}

