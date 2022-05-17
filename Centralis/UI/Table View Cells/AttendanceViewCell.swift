//
//  AttendanceViewCell.swift
//  Centralis
//
//  Created by Amy While on 17/05/2022.
//

import UIKit

class AttendanceViewCell: UITableViewCell {
    
    public var title: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.heightAnchor.constraint(equalToConstant: 20).isActive = true
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    public var chart: ChartedProgressView = {
        let view = ChartedProgressView(regions: [])
        view.heightAnchor.constraint(equalToConstant: 25).isActive = true
        return view
    }()
    
    public var descriptionText: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 4
        label.font = UIFont.systemFont(ofSize: 14)
        label.heightAnchor.constraint(equalToConstant: 72).isActive = true
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(chart)
        contentView.addSubview(title)
        contentView.addSubview(descriptionText)
        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            title.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            title.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            
            chart.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            chart.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            chart.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 10),
            
            descriptionText.topAnchor.constraint(equalTo: chart.bottomAnchor, constant: 10),
            descriptionText.leadingAnchor.constraint(equalTo: chart.leadingAnchor),
            descriptionText.trailingAnchor.constraint(equalTo: chart.trailingAnchor),
            descriptionText.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    public func setRecord(record: Attendance.Lesson) {
        title.text = record.lesson
        let values = record.values.fractionalValues
        chart.setRegions(regions: [
            (Attendance.Colours.present.rawValue, values.present),
            (Attendance.Colours.late.rawValue, values.late),
            (Attendance.Colours.unauthorised.rawValue, values.unauthorised),
            (Attendance.Colours.absent.rawValue, values.absent)
        ])
        
        let descriptionText = NSMutableAttributedString()
        var attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: Attendance.Colours.present.rawValue,
        ]
        descriptionText.append(NSAttributedString(string: "Present: \(String(format: "%.2f", values.present * 100))%\n", attributes: attributes))
        attributes[.foregroundColor] = Attendance.Colours.late.rawValue
        descriptionText.append(NSAttributedString(string: "Late: \(String(format: "%.2f", values.late * 100))%\n", attributes: attributes))
        attributes[.foregroundColor] = Attendance.Colours.unauthorised.rawValue
        descriptionText.append(NSAttributedString(string: "Unauthorised: \(String(format: "%.2f", values.unauthorised * 100))%\n", attributes: attributes))
        attributes[.foregroundColor] = Attendance.Colours.absent.rawValue
        descriptionText.append(NSAttributedString(string: "Absent: \(String(format: "%.2f", values.absent * 100))%", attributes: attributes))
        self.descriptionText.attributedText = descriptionText
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
