//
//  ChartProgressView.swift
//  Centralis
//
//  Created by Somica on 16/05/2022.
//

import UIKit

public final class ChartedProgressView: UIView {
    
    public init(regions: [(UIColor, Float)]) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerCurve = .continuous
        layer.masksToBounds = true
        
        setRegions(regions: regions)
    }
    
    public func setRegions(regions: [(UIColor, Float)]) {
        subviews.forEach { $0.removeFromSuperview() }
        
        var lastView: UIView?
        for region in regions {
            let view = UIView(frame: .zero)
            view.backgroundColor = region.0
            view.translatesAutoresizingMaskIntoConstraints = false
            view.clipsToBounds = true
            addSubview(view)
            NSLayoutConstraint.activate([
                view.topAnchor.constraint(equalTo: topAnchor),
                view.bottomAnchor.constraint(equalTo: bottomAnchor),
                view.leadingAnchor.constraint(equalTo: lastView?.trailingAnchor ?? leadingAnchor),
                view.widthAnchor.constraint(equalTo: widthAnchor, multiplier: CGFloat(region.1))
            ])
            lastView = view
        }
    }
    

    public override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = bounds.height / 2
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

