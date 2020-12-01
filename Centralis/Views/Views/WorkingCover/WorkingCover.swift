//
//  WorkingCover.swift
//  Centralis
//
//  Created by Amy While on 01/12/2020.
//

import UIKit

class WorkingCover: UIView {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var backgroundView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }
    
    private func setup() {
        self.backgroundView.alpha = 0.5
    }
}
