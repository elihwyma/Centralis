//
//  TodayLessonCell.swift
//  Centralis
//
//  Created by Andromeda on 27/08/2021.
//

import UIKit

class TodayLessonCell: UITableViewCell {
    
    public var lessonImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 65),
            view.widthAnchor.constraint(equalToConstant: 65)
        ])
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 37.5
        view.layer.cornerCurve = .continuous
        return view
    }()
    
    public var descriptionLabel: UILabel = {
        let view = UILabel()
        view.adjustsFontSizeToFitWidth = true
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 15)
        ])
        view.font = UIFont.systemFont(ofSize: 13, weight: .light)
        return view
    }()
    
    public var primaryLabel: UILabel = {
        let view = UILabel()
        view.adjustsFontSizeToFitWidth = true
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 22.5)
        ])
        view.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        return view
    }()
    
    public var secondaryLabel: UILabel = {
        let view = UILabel()
        view.adjustsFontSizeToFitWidth = true
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 22.5)
        ])
        view.font = UIFont.systemFont(ofSize: 14)
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        backgroundColor = .centralisBackgroundColor
        
        contentView.addSubview(lessonImageView)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(primaryLabel)
        contentView.addSubview(secondaryLabel)
        
        NSLayoutConstraint.activate([
            lessonImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            lessonImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            lessonImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            
            descriptionLabel.topAnchor.constraint(equalTo: lessonImageView.topAnchor),
            descriptionLabel.leadingAnchor.constraint(equalTo: lessonImageView.trailingAnchor, constant: 5),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            
            primaryLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 2.5),
            primaryLabel.leadingAnchor.constraint(equalTo: descriptionLabel.leadingAnchor),
            primaryLabel.trailingAnchor.constraint(equalTo: descriptionLabel.trailingAnchor),
            
            secondaryLabel.topAnchor.constraint(equalTo: primaryLabel.bottomAnchor, constant: 0.5),
            secondaryLabel.leadingAnchor.constraint(equalTo: descriptionLabel.leadingAnchor),
            secondaryLabel.trailingAnchor.constraint(equalTo: descriptionLabel.trailingAnchor)
        ])
        
        tintColor = .centralisTintColor
    }
    
    var lesson: TodayView.LessonCell? {
        didSet {
            guard let lesson = lesson else { return }
            switch lesson.context {
            case .current: descriptionLabel.text = "Current Lesson"; lessonImageView.image = UIImage(systemName: "clock")
            case .upcoming: descriptionLabel.text = "Upcoming Lesson"; lessonImageView.image = UIImage(systemName: "clock.arrow.circlepath")
            }
            primaryLabel.text = lesson.subject
            secondaryLabel.text = "\(lesson.location) - \(lesson.teacher)"
        }
    }
    
    var homework: TodayView.HomeworkCell? {
        didSet {
            guard let homework = homework else { return }
            descriptionLabel.text = homework.due_text
            primaryLabel.text = homework.activity
            secondaryLabel.text = homework.subject
            lessonImageView.image = UIImage(systemName: "book.circle")
        }
    }
    
    var catering: TodayView.CateringCell? {
        didSet {
            guard let catering = catering else { return }
            descriptionLabel.text = "Current Balance"
            primaryLabel.text = "£\(String(format: "%03.2f", catering.balance))"
            secondaryLabel.text = "\(catering.transactions) transactions"
            lessonImageView.image = UIImage(systemName: "sterlingsign.circle")
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
