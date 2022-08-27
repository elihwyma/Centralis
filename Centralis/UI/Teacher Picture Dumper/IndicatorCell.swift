//
//  IndicatorCell.swift
//  Centralis
//
//  Created by Amy While on 27/08/2022.
//

import UIKit
import Evander

class IndicatorCell: UICollectionViewCell {
    
    var indicator : UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.style = .large
        view.translatesAutoresizingMaskIntoConstraints = false
        view.hidesWhenStopped = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(indicator)
        indicator.pinTo(view: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
