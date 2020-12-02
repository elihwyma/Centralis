//
//  LoginPopup.swift
//  Centralis
//
//  Created by Amy While on 28/11/2020.
//

import UIKit

class LoginPopup: UIView {

    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var schoolCode: UITextField!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var saveLogin: UISwitch!
    @IBOutlet weak var login: UIButton!
    @IBOutlet weak var cancel: UIButton!
    @IBOutlet weak var popover: UIView!
    
    var workingCover: WorkingCover = .fromNib()
        
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }
    
    private func setup() {
        if !UIAccessibility.isReduceTransparencyEnabled {
            let blurEffect = UIBlurEffect(style: .light)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)

            blurEffectView.frame = self.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

            self.blurView.addSubview(blurEffectView)
        }
        self.blurView.alpha = 0.5
        
        self.login.layer.masksToBounds = true
        self.login.layer.borderColor = UIColor.systemGreen.cgColor
        self.login.layer.borderWidth = 2
        self.login.layer.cornerRadius = 15
        
        self.cancel.layer.masksToBounds = true
        self.cancel.layer.borderColor = UIColor.systemRed.cgColor
        self.cancel.layer.borderWidth = 2
        self.cancel.layer.cornerRadius = 15
        
        self.popover.layer.masksToBounds = true
        self.popover.layer.borderColor = UIColor.label.cgColor
        self.popover.layer.borderWidth = 2
        self.popover.layer.cornerRadius = 15
        
        self.schoolCode.delegate = self
        self.username.delegate = self
        self.password.delegate = self
    
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.addGestureRecognizer(tapGesture)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(succesfulLogin), name: .SuccesfulLogin, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.frame.origin.y == 0 {
                self.frame.origin.y -= keyboardSize.height
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.frame.origin.y != 0 {
            self.frame.origin.y = 0
        }
    }
    
    @objc private func succesfulLogin() {
        DispatchQueue.main.async {
            if let schoolCode = self.schoolCode.text, let username = self.username.text, let password = self.password.text {
                if self.saveLogin.isOn {
                    let loginManager = LoginManager()
                    loginManager.saveLogins(schoolCode: schoolCode, username: username, password: password)
                    self.stopWorking()
                }
            }
        }
    }
    
    @IBAction func hideView(_ sender: Any) {
        self.dismissKeyboard(self)
        NotificationCenter.default.post(name: .HidePopup, object: nil)
    }
    
    @IBAction func login(_ sender: Any) {
        if let schoolCode = self.schoolCode.text, let username = self.username.text, let password = self.password.text {
            self.startWorking()
            EduLinkAPI.shared.login(schoolCode: schoolCode, username: username, password: password)
        }
    }
    
    private func startWorking() {
        self.workingCover.frame = self.frame
        self.workingCover.alpha = 0
        self.addSubview(workingCover)
        UIView.animate(withDuration: 0.5,
                         delay: 0, usingSpringWithDamping: 1.0,
                         initialSpringVelocity: 1.0,
                         options: .curveEaseInOut, animations: {
                            self.workingCover.alpha = 1
                         }, completion: { (value: Bool) in
          })
    }
    
    private func stopWorking() {
        UIView.animate(withDuration: 0.5,
                         delay: 0, usingSpringWithDamping: 1.0,
                         initialSpringVelocity: 1.0,
                         options: .curveEaseInOut, animations: {
                            self.workingCover.alpha = 0
                         }, completion: { (value: Bool) in
                            self.workingCover.removeFromSuperview()
          })
    }
}

extension LoginPopup: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc private func dismissKeyboard (_ sender: Any) {
        self.schoolCode.resignFirstResponder()
        self.username.resignFirstResponder()
        self.password.resignFirstResponder()
    }
}
