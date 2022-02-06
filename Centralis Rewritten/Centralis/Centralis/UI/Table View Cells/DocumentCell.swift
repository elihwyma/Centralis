//
//  DocumentCell.swift
//  Centralis
//
//  Created by Amy While on 06/02/2022.
//

import UIKit

class DocumentCell: BasicInfoCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        primaryImage.image = UIImage(systemName: "doc.plaintext")
        secondaryImage.image = UIImage(systemName: "calendar")
        tertiaryImage.image = UIImage(systemName: "arrow.down.doc")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func set(document: Document) {
        title.text = document.summary
        primaryLabel.text = document.type
        if let date = document.last_updated {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            secondaryLabel.text = formatter.string(from: date)
        } else {
            secondaryLabel.text = "No Date Available"
        }
        tertiaryLabel.text = document.filename
    }

}

/*
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

 */
