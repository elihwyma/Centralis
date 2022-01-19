//
//  HomeworkCell.swift
//  Centralis
//
//  Created by Amy While on 31/12/2021.
//

import UIKit
import Evander

class HomeworkCell: BasicInfoCell {
    
    public var homework: Homework?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        secondaryImage.image = UIImage(systemName: "person.crop.circle")
        primaryImage.image = UIImage(systemName: "clock")
    }

    public func toggleDescription() {
        if !Thread.isMainThread {
            DispatchQueue.main.async { [weak self] in
                self?.toggleDescription()
            }
            return
        }
        if loadingTopAnchor.constant == -10 {
            loadingTopAnchor.constant = 8
            
            func setDescription(_ text: String) {
                if loadingIndicator.isAnimating {
                    loadingIndicator.stopAnimating()
                    loadingIndicator.isHidden = true
                }
                if !descriptionVariableHeightAnchor.isActive {
                    descriptionHeightAnchor.priority = UILayoutPriority(250)
                    descriptionVariableHeightAnchor.isActive = true
                }
                if let attributedString = try? NSMutableAttributedString(html: text) {
                    descriptionTextView.attributedText = attributedString
                } else {
                    descriptionTextView.text = text
                }
            }
            if let description = homework?.description {
                setDescription(description)
            } else {
                loadingIndicator.isHidden = false
                loadingIndicator.startAnimating()
            }
            let homework = homework
            homework?.retrieveDescription({ [weak self] error, description in
                guard let `self` = self,
                      homework == self.homework else { return }
                DispatchQueue.main.async {
                    self.delegate?.changeContentSize {
                        if let error = error,
                           homework?.description == nil {
                            setDescription("Error When Loading Description: \(error)")
                        } else if let description = description {
                            setDescription(description)
                        }
                    }
                }
            })
        } else {
            loadingTopAnchor.constant = -10
            loadingIndicator.stopAnimating()
            loadingIndicator.isHidden = true
            descriptionTextView.attributedText = nil
            descriptionTextView.text = nil
            descriptionVariableHeightAnchor.isActive = false
            descriptionHeightAnchor.priority = UILayoutPriority(1000)
        }
    }
    
    private func setState(homework: Homework) {
        Thread.mainBlock { [self] in
            if homework.completed {
                tertiaryImage.backgroundColor = .systemGreen
            } else if homework.isDueToday || homework.isDueTomorrow || !homework.isCurrent {
                tertiaryImage.backgroundColor = .systemRed
            } else {
                tertiaryImage.backgroundColor = .systemYellow
            }
        }
    }
    
    public func set(homework: Homework) {
        self.homework = homework
        if loadingTopAnchor.constant != -10 {
            toggleDescription()
        }
        setState(homework: homework)
        
        if homework.isDueToday {
            primaryLabel.text = "Due Today"
        } else if homework.isDueTomorrow {
            primaryLabel.text = "Due Tomorrow"
        } else if homework.isCurrent {
            primaryLabel.text  = "Due in \((homework.due_date?.days(sinceDate: Date()) ?? 0) + 1) days"
        } else {
            primaryLabel.text  = "Due \(abs(homework.due_date?.days(sinceDate: Date()) ?? 0)) days ago"
        }
        secondaryLabel.text = homework.set_by
        title.text = homework.activity
        tertiaryLabel.text = homework.subject
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func trailingSwipeActionsConfiguration() -> UISwipeActionsConfiguration? {
        guard let homework = homework else { return nil }
        let complete = UIContextualAction(style: .normal, title: !homework.completed ? "Complete" : "Un-Complete") { [weak self] _, _, completion in
            guard let `self` = self,
                  self.homework == homework else { return completion(true) }
            homework.complete(complete: !homework.completed) { [weak self] error, completed in
                guard let `self` = self,
                      error == nil,
                      self.homework == homework else { return }
                self.setState(homework: homework)
            }
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [complete])
    }
}
