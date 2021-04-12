//
//  WorkingCover.swift
//  Centralis
//
//  Created by AW on 01/12/2020.
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
    
    public func startWorking(_ sender: UIViewController) {
        self.frame = sender.view.frame
        self.alpha = 0
        sender.view.addSubview(self)
        UIView.animate(withDuration: 0.5,
                         delay: 0, usingSpringWithDamping: 1.0,
                         initialSpringVelocity: 1.0,
                         options: .curveEaseInOut, animations: {
                            self.alpha = 1
                         }, completion: { (value: Bool) in
          })
    }
    
    public func stopWorking() {
        UIView.animate(withDuration: 0.5,
                         delay: 0, usingSpringWithDamping: 1.0,
                         initialSpringVelocity: 1.0,
                         options: .curveEaseInOut, animations: {
                            self.alpha = 0
                         }, completion: { (value: Bool) in
                            self.removeFromSuperview()
          })
    }
}
