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
    }
    
    public func lessonBehaviour(_ b4l: BehaviourForLesson) {
        var points = [AmyChartDataPoint]()
        for v in b4l.values {
            let point = AmyChartDataPoint(number: v.count, colour: .randomColor())
            points.append(point)
        }
        self.chart.data = points
        self.topTitle.text = b4l.subject
        self.att = NSMutableAttributedString()
    }
    
}
