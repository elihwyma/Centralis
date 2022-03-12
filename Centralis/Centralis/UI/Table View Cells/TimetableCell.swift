//
//  TimetableCell.swift
//  Centralis
//
//  Created by Amy While on 31/12/2021.
//

import UIKit

class PeriodCell: BasicInfoCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        primaryImage.image = UIImage(systemName: "clock")
        secondaryImage.image = UIImage(systemName: "building.2.crop.circle")
        tertiaryImage.image = UIImage(systemName: "person.crop.circle")
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func set(period: Timetable.Period) {
        if let subject = period.subject {
            title.text = "\(subject) - \(period.group ?? "Unknown Group")"
        } else {
            title.text = "Free Period"
        }
        primaryLabel.text = "\(period.start_time) - \(period.end_time)"
        if period.moved {
            secondaryImage.image = nil
            secondaryImage.backgroundColor = .systemRed
        } else {
            secondaryImage.backgroundColor = .clear
            secondaryImage.image = UIImage(systemName: "building.2.crop.circle")
        }
        secondaryLabel.text = period.room ?? "Literally Anywhere"
        if let teachers = period.teachers,
           !teachers.isEmpty && teachers != "  " {
            tertiaryLabel.text = teachers
        } else {
            tertiaryLabel.text = "Literally Nobody"
        }
    }
    
}
