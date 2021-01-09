//
//  AmyChartCell.swift
//  Centralis
//
//  Created by AW on 17/12/2020.
//

import UIKit
import libCentralis

class AmyChartCell: UITableViewCell {

    @IBOutlet weak var topTitle: UILabel!
    @IBOutlet weak var chart: AmyChart!
    @IBOutlet weak var chartOverlay: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var noData: UILabel!
    
    var att: NSMutableAttributedString?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.chartOverlay.layer.cornerRadius = self.chartOverlay.frame.height / 2
        self.chart.backgroundColor = .clear
    }
    
    private func setup() {
        self.chartOverlay.layer.masksToBounds = true
        self.topTitle.adjustsFontSizeToFitWidth = true
    }
    
    public func lessonBehaviour(_ b4l: BehaviourForLesson) {
        self.textView.textColor = .label
        var points = [AmyChartDataPoint]()
        var total: Double = 0
        for v in b4l.values {
            if let i = EduLinkAPI.shared.authorisedSchool.schoolInfo.lesson_codes.first(where: { $0.code == v.name }) {
                let point = AmyChartDataPoint(number: v.count, colour: i.colour!)
                points.append(point)
                total += Double(v.count)
            }
        }
        if points.isEmpty {
            self.chartOverlay.isHidden = true
            self.noData.isHidden = false
        } else {
            self.chartOverlay.isHidden = false
            self.noData.isHidden = true
        }
        self.chart.data = points
        self.topTitle.text = b4l.subject
        self.att = NSMutableAttributedString()
        for (index, v) in b4l.values.enumerated() {
            if let i = EduLinkAPI.shared.authorisedSchool.schoolInfo.lesson_codes.first(where: { $0.code == v.name }) {
                self.att?.addBoldColour(bold: "\(i.name!): ", colour: i.colour!)
                self.att?.addPair(bold: "", normal: "\((Double(Double(Double(v.count) / total)) * 100.0).rounded(toPlaces: 1))%\(index == b4l.values.count - 1 ? "" : "\n")")
            }
        }
    }
    
    public func lessonAttendance(_ values: AttendanceValue, text: String) {
        self.textView.textColor = .label
        var points = [AmyChartDataPoint]()
        points.append(AmyChartDataPoint(number: values.present, colour: EduLinkAPI.shared.attendance.attendance_colours.present))
        points.append(AmyChartDataPoint(number: values.late, colour: EduLinkAPI.shared.attendance.attendance_colours.late))
        points.append(AmyChartDataPoint(number: values.unauthorised, colour: EduLinkAPI.shared.attendance.attendance_colours.unauthorised))
        points.append(AmyChartDataPoint(number: values.absent, colour: EduLinkAPI.shared.attendance.attendance_colours.absent))
        self.chart.data = points
        self.topTitle.text = text
        let total: Double = Double(values.present) + Double(values.absent) + Double(values.unauthorised) + Double(values.late)
        if total == 0 {
            self.chartOverlay.isHidden = true
            self.noData.isHidden = false
        } else {
            self.chartOverlay.isHidden = false
            self.noData.isHidden = true
        }
        self.att = NSMutableAttributedString()
        self.att?.addBoldColour(bold: "Present: ", colour: EduLinkAPI.shared.attendance.attendance_colours.present)
        self.att?.addPair(bold: "", normal: "\((Double(Double(Double(values.present) / total)) * Double(100)).rounded(toPlaces: 1))%\n")
        self.att?.addBoldColour(bold: "Late: ", colour: EduLinkAPI.shared.attendance.attendance_colours.late)
        self.att?.addPair(bold: "", normal: "\((Double(Double(Double(values.late) / total)) * Double(100)).rounded(toPlaces: 1))%\n")
        self.att?.addBoldColour(bold: "Unauthorised: ", colour: EduLinkAPI.shared.attendance.attendance_colours.unauthorised)
        self.att?.addPair(bold: "", normal: "\((Double(Double(Double(values.unauthorised) / total)) * Double(100)).rounded(toPlaces: 1))%\n")
        self.att?.addBoldColour(bold: "Absent: ", colour: EduLinkAPI.shared.attendance.attendance_colours.absent)
        self.att?.addPair(bold: "", normal: "\((Double(Double(Double(values.absent) / total)) * Double(100)).rounded(toPlaces: 1))%")
    }
}
