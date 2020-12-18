//
//  AmyChartCell.swift
//  Centralis
//
//  Created by Amy While on 17/12/2020.
//

import UIKit

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
        var points = [AmyChartDataPoint]()
        var total = 0
        for v in b4l.values {
            let point = AmyChartDataPoint(number: v.count, colour: v.colour)
            points.append(point)
            total += v.count
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
    }
}
