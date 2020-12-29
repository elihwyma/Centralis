//
//  HomeworkDetailView.swift
//  Centralis
//
//  Created by Amy While on 05/12/2020.
//

import UIKit

class HomeworkDetailView: UIView {
    
    @IBOutlet weak var completeButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var context: HomeworkContext!
    var homework: Homework!
    var index: Int!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    public func setup() {
        self.completeButton.layer.masksToBounds = true
        self.completeButton.layer.borderColor = UIColor.label.cgColor
        self.completeButton.layer.borderWidth = 2
        self.completeButton.layer.cornerRadius = 15
        self.completeButton.setTitle("  Mark as \(homework.completed ? "Not Completed" : "Completed")  ", for: .normal)
        if homework.description == nil {
            EduLink_Homework.homeworkDetails(self.index, self.homework, self.context, {(success, error) -> Void in
                #warning("Error handling here would be nice")
                self.fixIndexes()
            })
        } else {
            self.detailResponse()
        }
    }
    
    private func fixIndexes() {
        switch self.context {
        case .current: self.homework = EduLinkAPI.shared.homework.current[self.index]
        case .past: self.homework = EduLinkAPI.shared.homework.past[self.index]
        case .none: fatalError("wtf")
        }
        self.detailResponse()
    }
    
    private func detailResponse() {
        self.activityIndicator.isHidden = true
        
        let att = NSMutableAttributedString()
        att.addPair(bold: "Due: ", normal: "\(self.homework.due_text!) : \(self.homework.due_date!)\n")
        att.addPair(bold: "Name: ", normal: "\(self.homework.activity!)\n")
        att.addPair(bold: "Subject: ", normal: "\(self.homework.subject!)\n")
        att.addPair(bold: "Set: ", normal: "\(self.homework.available_text!) : \(self.homework.available_date!)\n")
        att.addPair(bold: "Set by: ", normal: "\(self.homework.set_by!)\n")
        att.addPair(bold: "Description: \n", normal: "")
        
        let data = Data(self.homework.description.utf8)
        if let tryToHTML = try? NSMutableAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
            let range = (tryToHTML.string as NSString).range(of: tryToHTML.string)
            tryToHTML.addAttribute((NSAttributedString.Key.font), value: UIFont.systemFont(ofSize: 17), range: range)
            tryToHTML.addAttribute((NSAttributedString.Key.backgroundColor), value: UIColor.clear, range: range)
            att.append(tryToHTML)
        }
        self.textView.attributedText = att
        self.textView.textColor = .label
    }
    
    @objc private func completeResponse() {
        DispatchQueue.main.async {
            self.homework.completed = !self.homework.completed
            self.completeButton.setTitle("  Mark as \(self.homework.completed ? "Not Completed" : "Completed")  ", for: .normal)
        }
        
    }
    
    @IBAction func completeButton(_ sender: Any) {
        EduLink_Homework.completeHomework(!homework.completed, self.index, self.context, {(success, error) -> Void in
            #warning("Error :clap: Handling :clap:")
            DispatchQueue.main.async {
                self.detailResponse()
            }
        })
    }
}
