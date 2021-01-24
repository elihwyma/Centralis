//
//  ErrorView.swift
//  Centralis
//
//  Created by Amy While on 27/10/2020.
//

import UIKit

class ErrorView: UIView {

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var text: UILabel!
    @IBOutlet weak var goBackButton: UIButton!
    @IBOutlet weak var retryButton: UIButton!
    @IBOutlet weak var popup: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.text.adjustsFontSizeToFitWidth = true
        self.popup.layer.masksToBounds = true
        self.popup.layer.cornerRadius = 15
        self.popup.clipsToBounds = true
        self.retryButton.addTarget(self, action: #selector(self.stopWorking), for: .touchUpInside)
        self.goBackButton.addTarget(self, action: #selector(self.stopWorking), for: .touchUpInside)
    }
    
    public func startWorking(_ sender: UIViewController) {
        self.frame = sender.view.frame
        let mFrame = self.popup.frame
        let deadframe = CGRect(x: 0, y: 0 - mFrame.width, width: mFrame.width, height: mFrame.height)
        self.popup.frame = deadframe
        self.backgroundView.alpha = 0
        sender.view.addSubview(self)
        UIView.animate(withDuration: 0.5,
                         delay: 0, usingSpringWithDamping: 1.0,
                         initialSpringVelocity: 1.0,
                         options: .curveEaseInOut, animations: {
                            self.backgroundView.alpha = 0.5
                            self.popup.frame = mFrame
                         }, completion: { (value: Bool) in
          })
    }
    
    @objc public func stopWorking() {
        let mFrame = self.popup.frame
        let deadframe = CGRect(x: 0, y: 0 - mFrame.width, width: mFrame.width, height: mFrame.height)
        UIView.animate(withDuration: 0.5,
                         delay: 0, usingSpringWithDamping: 1.0,
                         initialSpringVelocity: 1.0,
                         options: .curveEaseInOut, animations: {
                            self.backgroundView.alpha = 0
                            self.popup.frame = deadframe
                         }, completion: { (value: Bool) in
                            self.removeFromSuperview()
                         })
    }
    
    public func changeGoBackLabel(_ label: String!) {
        self.goBackButton.setTitle(label, for: .normal)
        self.goBackButton.setTitle(label, for: .selected)
    }
}
