//
//  LoginViewController.swift
//  Centralis
//
//  Created by Amy While on 28/11/2020.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var dynamicColourView: DynamicColourView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: ResizedTableView!
    @IBOutlet weak var newLoggin: UIButton!
    
    var containerView = UIView()
    var popupView: LoginPopup = .fromNib()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
    }
    
    private func setup() {
        self.dynamicColourView.setup()
        self.newLoggin.layer.masksToBounds = true
        self.newLoggin.layer.borderColor = UIColor.label.cgColor
        self.newLoggin.layer.borderWidth = 2
        self.newLoggin.layer.cornerRadius = 15
        
        NotificationCenter.default.addObserver(self, selector: #selector(hidePopup), name: .HidePopup, object: nil)
    }

    @IBAction func newLoggin(_ sender: Any) {
        self.showPopup()
    }
    
    @objc private func hidePopup() {
        let deadBounds = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: self.view.frame.height)
        
        UIView.animate(withDuration: 1.0,
                         delay: 0, usingSpringWithDamping: 1.0,
                         initialSpringVelocity: 1.0,
                         options: .curveEaseInOut, animations: {
                            self.containerView.alpha = 0
                            self.popupView.frame = deadBounds
                         }, completion: { (value: Bool) in
                            self.popupView.removeFromSuperview()
                            self.containerView.removeFromSuperview()
          })
    }

    private func showPopup() {
        self.containerView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        self.containerView.frame = self.view.frame
        self.containerView.alpha = 0
        self.view.addSubview(containerView)

        let deadBounds = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: self.view.frame.height)
                    
        self.popupView.frame = deadBounds
        self.view.addSubview(popupView)

        UIView.animate(withDuration: 0.5,
                         delay: 0, usingSpringWithDamping: 1.0,
                         initialSpringVelocity: 1.0,
                         options: .curveEaseInOut, animations: {
                            self.containerView.alpha = 0.8
                            self.popupView.frame = self.view.bounds
          }, completion: nil)
        
    }

}
