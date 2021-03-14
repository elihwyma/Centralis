//
//  ErrorView.swift
//  Centralis
//
//  Created by Centralis App on 27/10/2020.
//

import UIKit

class ToastView: UIView {

    @IBOutlet weak var text: UILabel!
    @IBOutlet weak var popup: UIView!
    var heartbeat: Timer?
    var isPresenting = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.popup.layer.masksToBounds = true
        self.popup.layer.cornerRadius = 15
        self.popup.clipsToBounds = true
        //self.popup.backgroundColor = ThemeManager.imageBackground
        self.text.textColor = .white
    }
    
    public func showText(_ sender: UIViewController, _ text: String) {
        self.heartbeat?.invalidate()
        if self.isPresenting {
            self.removeFromSuperview()
        }
        self.removeFromSuperview()
        self.text.text = text
        self.frame = CGRect(x: 0, y: 35, width: sender.view.frame.width, height: self.popup.frame.height)
        let mFrame = self.frame
        let deadframe = CGRect(x: 0, y: 0 - self.frame.height, width: self.frame.width, height: self.frame.height)
        self.frame = deadframe
        sender.view.addSubview(self)
        UIView.animate(withDuration: 0.15,
                         delay: 0,
                         options: .curveEaseInOut, animations: {
                            self.frame = mFrame
                            self.isPresenting = true
                         }, completion: { (value: Bool) in
                            self.heartbeat = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { timer in
                                self.hide()
                            }
                         })
    }
    
    public func hide() {
        let mFrame = self.frame
        let deadframe = CGRect(x: 0, y: 0 - mFrame.height, width: mFrame.width, height: mFrame.height)
        UIView.animate(withDuration: 0.15,
                         delay: 0,
                         options: .curveEaseInOut, animations: {
                            self.frame = deadframe
                         }, completion: { (value: Bool) in
                            self.removeFromSuperview()
                            self.isPresenting = false
                         })
    }
}
