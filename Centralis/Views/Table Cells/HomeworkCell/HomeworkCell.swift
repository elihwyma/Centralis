//
//  HomeworkCell.swift
//  Centralis
//
//  Created by Amy While on 05/12/2020.
//

import UIKit

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
        self.completedView.backgroundColor = homework.completed! ? .systemGreen : .systemRed
    }
}

