//
//  HomeworkDetailView.swift
//  Centralis
//
//  Created by Amy While on 05/12/2020.
//

import UIKit
import libCentralis

class HomeworkDetailView: UIView {
    
    @IBOutlet weak var completeButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var context: HomeworkContext!
    var homework: Homework!
    var rootSender: CarouselContainerController?
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
        self.sortOutDescription()
        
    }
    
    @objc private func sortOutDescription() {
        if !homework.description.isEmpty { return self.detailResponse() }
        EduLink_Homework.homeworkDetails(self.index, self.homework, self.context, {(success, error) -> Void in
            DispatchQueue.main.async {
                if success {
                    self.fixIndexes()
                } else {
                    self.descriptionError(error!)
                }
            }
        })
    }
    
    @objc private func goBack() {
        self.rootSender?.navigationController?.popViewController(animated: true)
    }
    
    private func descriptionError(_ error: String) {
        let errorView: ErrorView = .fromNib()
        errorView.text.text = error
        errorView.goBackButton.addTarget(self, action: #selector(self.goBack), for: .touchUpInside)
        errorView.retryButton.addTarget(self, action: #selector(self.sortOutDescription), for: .touchUpInside)
        if let nc = self.rootSender?.navigationController { errorView.startWorking(nc) }
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
        
        if !self.homework.description.isEmpty {
            let data = Data(self.homework.description.utf8)
            if let tryToHTML = try? NSMutableAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
                let range = (tryToHTML.string as NSString).range(of: tryToHTML.string)
                tryToHTML.addAttribute((NSAttributedString.Key.font), value: UIFont.systemFont(ofSize: 17), range: range)
                tryToHTML.addAttribute((NSAttributedString.Key.backgroundColor), value: UIColor.clear, range: range)
                att.append(tryToHTML)
            }
        } else {
            att.addPair(bold: "", normal: "No description given")
        }
        
        self.textView.attributedText = att
        self.textView.textColor = .label
    }
    
    private func completeResponse() {
        self.fixIndexes()
        self.completeButton.setTitle("  Mark as \(self.homework.completed ? "Not Completed" : "Completed")  ", for: .normal)
    }

    private func completeError(_ error: String) {
        let errorView: ErrorView = .fromNib()
        errorView.text.text = error
        errorView.changeGoBackLabel("Ignore")
        errorView.retryButton.addTarget(self, action: #selector(self.completeButton(_:)), for: .touchUpInside)
        if let nc = self.rootSender?.navigationController { errorView.startWorking(nc) }
    }
    
    @objc @IBAction func completeButton(_ sender: Any) {
        EduLink_Homework.completeHomework(!homework.completed, self.index, self.context, {(success, error) -> Void in
            DispatchQueue.main.async {
                if success {
                    self.completeResponse()
                } else {
                    self.completeError(error!)
                }
            }
        })
    }
}
