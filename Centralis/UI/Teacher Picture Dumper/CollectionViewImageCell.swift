//
//  CollectionViewImageCell.swift
//  Centralis
//
//  Created by Amy While on 27/08/2022.
//

import UIKit
import Evander

class CollectionViewImageCell: UICollectionViewCell {
    
    var imageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(imageView)
        imageView.pinTo(view: self)
        
        layer.masksToBounds = true
        layer.cornerCurve = .continuous
        layer.cornerRadius = 12.5
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
