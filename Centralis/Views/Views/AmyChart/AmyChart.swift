//
//  AmyChart.swift
//  Centralis
//
//  Created by Amy While on 17/12/2020.
//

import UIKit

class AmyChart: UIView {
    
    var data = [AmyChartDataPoint]() {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isOpaque = false
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }
        
    override func draw(_ rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        let radius = min(frame.size.width, frame.size.height) * 0.5
        let viewCenter = CGPoint(x: bounds.size.width * 0.5, y: bounds.size.height * 0.5)
        let valueCount = self.data.reduce(0, {$0 + Float($1.number)})
        var startAngle = -CGFloat.pi * 0.5

        for segment in self.data {
            ctx?.setFillColor(segment.colour.cgColor)
            ctx?.setStrokeColor(UIColor.clear.cgColor)
            ctx?.setLineWidth(3)
            let endAngle = startAngle + 2 * .pi * (CGFloat(segment.number!) / CGFloat(valueCount))
            ctx?.move(to: viewCenter)
            ctx?.addArc(center: viewCenter, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
            ctx?.fillPath()
            ctx?.strokePath()
            startAngle = endAngle
        }
        self.backgroundColor = .none
   }
}

struct AmyChartDataPoint {
    var number: Int!
    var colour: UIColor!
}
