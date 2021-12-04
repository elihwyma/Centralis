//
//  HomeworkCell.swift
//  Centralis
//
//  Created by Andromeda on 28/11/2021.
//

import UIKit

class HomeworkCell: UITableViewCell {
    
    public var homework: Homework?
    
    private class DescriptionLabel: UILabel {
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            font = UIFont.systemFont(ofSize: 12)
            textColor = .darkGray
            translatesAutoresizingMaskIntoConstraints = false
            heightAnchor.constraint(equalToConstant: 15).isActive = true
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
    
    private class DescriptionImage: UIImageView {
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            NSLayoutConstraint.activate([
                heightAnchor.constraint(equalToConstant: 10),
                widthAnchor.constraint(equalToConstant: 10)
            ])
            layer.masksToBounds = true
            layer.cornerCurve = .continuous
            layer.cornerRadius = 10 / 2
            contentMode = .scaleAspectFill
            tintColor = .lightGray
            translatesAutoresizingMaskIntoConstraints = false
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
    
    private let title: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        label.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 751), for: .vertical)
        let variableHeight = label.heightAnchor.constraint(equalToConstant: 20)
        variableHeight.priority = UILayoutPriority(rawValue: 750)
        NSLayoutConstraint.activate([
            variableHeight,
            label.heightAnchor.constraint(greaterThanOrEqualToConstant: 20)
        ])
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let timeLabel = DescriptionLabel(frame: .zero)
    private let timeImage = DescriptionImage(frame: .zero)
    
    private let teacherLabel = DescriptionLabel(frame: .zero)
    private let teacherImage = DescriptionImage(frame: .zero)
    
    private let subjectLabel = DescriptionLabel(frame: .zero)
    private let subjectImage = DescriptionImage(frame: .zero)
    
    private let loadingIndicator: UIActivityIndicatorView = {
        var indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.heightAnchor.constraint(equalToConstant: 15).isActive = true
        indicator.widthAnchor.constraint(equalToConstant: 15).isActive = true
        indicator.isHidden = true
        return indicator
    }()
    private lazy var loadingTopAnchor: NSLayoutConstraint = {
        var anchor = loadingIndicator.topAnchor.constraint(equalTo: subjectImage.bottomAnchor, constant: -10)
        anchor.priority = UILayoutPriority(rawValue: 750)
        return anchor
    }()
    
    private lazy var descriptionTextView: UITextView = {
        let view = UITextView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isEditable = false
        view.isSelectable = false
        view.isScrollEnabled = false
        view.backgroundColor = .clear
        view.textContainerInset = UIEdgeInsets.zero
        view.textContainer.lineFragmentPadding = 0
        view.textColor = .label
        return view
    }()
    private lazy var descriptionHeightAnchor: NSLayoutConstraint = {
        let heightConstant = descriptionTextView.heightAnchor.constraint(equalToConstant: 0)
        heightConstant.priority = UILayoutPriority(250)
        return heightConstant
    }()
    private lazy var descriptionVariableHeightAnchor = descriptionTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 0)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(timeLabel)
        contentView.addSubview(timeImage)
        contentView.addSubview(teacherLabel)
        contentView.addSubview(teacherImage)
        contentView.addSubview(subjectLabel)
        contentView.addSubview(subjectImage)
        contentView.addSubview(title)
        contentView.addSubview(loadingIndicator)
        contentView.addSubview(descriptionTextView)
        
        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            title.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            title.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            
            timeImage.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            timeImage.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 8),
            
            timeLabel.leadingAnchor.constraint(equalTo: timeImage.trailingAnchor, constant: 5),
            timeLabel.trailingAnchor.constraint(equalTo: title.trailingAnchor),
            timeLabel.centerYAnchor.constraint(equalTo: timeImage.centerYAnchor),
            
            teacherImage.topAnchor.constraint(equalTo: timeImage.bottomAnchor, constant: 8),
            teacherImage.leadingAnchor.constraint(equalTo: timeImage.leadingAnchor),
            
            teacherLabel.trailingAnchor.constraint(equalTo: timeLabel.trailingAnchor),
            teacherLabel.leadingAnchor.constraint(equalTo: timeLabel.leadingAnchor),
            teacherLabel.centerYAnchor.constraint(equalTo: teacherImage.centerYAnchor),
            
            subjectLabel.leadingAnchor.constraint(equalTo: timeLabel.leadingAnchor),
            subjectLabel.trailingAnchor.constraint(equalTo: timeLabel.trailingAnchor),
            subjectLabel.centerYAnchor.constraint(equalTo: subjectImage.centerYAnchor),
            
            subjectImage.topAnchor.constraint(equalTo: teacherImage.bottomAnchor, constant: 8),
            subjectImage.trailingAnchor.constraint(equalTo: timeImage.trailingAnchor),
            subjectImage.leadingAnchor.constraint(equalTo: timeImage.leadingAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            loadingTopAnchor,
 
            descriptionTextView.topAnchor.constraint(equalTo: loadingIndicator.bottomAnchor),
            descriptionTextView.leadingAnchor.constraint(equalTo: subjectImage.leadingAnchor),
            descriptionTextView.trailingAnchor.constraint(equalTo: timeLabel.trailingAnchor),
            descriptionTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            descriptionHeightAnchor,
            descriptionVariableHeightAnchor
        ])
        
        descriptionVariableHeightAnchor.isActive = false
        descriptionHeightAnchor.priority = UILayoutPriority(1000)
        teacherImage.image = UIImage(systemName: "person.crop.circle")
        timeImage.image = UIImage(systemName: "clock")
    }
    
    public func toggleDescription() {
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
                    if let error = error {
                        NSLog("[Centralis] Error = \(error)")
                        setDescription("Error When Loading Description: \(error)")
                    } else if let description = description {
                        setDescription(description)
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
    
    public func set(homework: Homework) {
        self.homework = homework
        if loadingTopAnchor.constant != -10 {
            toggleDescription()
        }
        if homework.completed {
            subjectImage.backgroundColor = .systemGreen
        } else if homework.isDueToday || homework.isDueTomorrow {
            subjectImage.backgroundColor = .systemRed
        } else {
            subjectImage.backgroundColor = .systemYellow
        }
        
        if homework.isDueToday {
            timeLabel.text = "Due Today"
        } else if homework.isDueTomorrow {
            timeLabel.text = "Due Tomorrow"
        } else if homework.isCurrent {
            timeLabel.text  = "Due in \(homework.due_date?.days(sinceDate: Date()) ?? 0) days"
        } else {
            timeLabel.text  = "Due \(homework.due_date?.days(sinceDate: Date()) ?? 0) days ago"
        }
        teacherLabel.text = homework.set_by
        title.text = homework.activity
        subjectLabel.text = homework.subject
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
