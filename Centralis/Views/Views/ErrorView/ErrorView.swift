//
//  FirstTimeView.swift
//  Shade
//
//  Created by Amy While on 27/10/2020.
//

import UIKit

class ErrorView: UIView {

    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var text: UILabel!
    
    var notification: NSNotification.Name!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.setupBlur()
    }

    private func setupBlur() {
        if !UIAccessibility.isReduceTransparencyEnabled {
            let blurEffect = UIBlurEffect(style: .systemMaterial)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)

            blurEffectView.frame = self.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

            self.blurView.addSubview(blurEffectView)
        }
        
        self.blurView.alpha = 0.5
    }
    
    @IBAction func hideButton(_ sender: Any) {
        NotificationCenter.default.post(name: notification, object: nil)
    }
    
}
