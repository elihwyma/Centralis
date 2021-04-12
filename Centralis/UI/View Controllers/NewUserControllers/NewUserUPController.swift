//
//  NewUserUPController.swift
//  Centralis
//
//  Created by AW on 28/12/2020.
//

import UIKit
//import libCentralis

class NewUserUPController: UIViewController {

    @IBOutlet weak var schoolImage: UIImageView!
    @IBOutlet weak var schoolName: UILabel!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var savePassword: UISwitch!
    var workingCover: WorkingCover = .fromNib()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
    private func setup() {
        if let image = UIImage(data: EduLinkAPI.shared.authorisedSchool.schoolLogo) { self.schoolImage.image = image }
        self.schoolImage.layer.masksToBounds = true
        self.schoolImage.layer.cornerRadius = 25
        self.schoolName.adjustsFontSizeToFitWidth = true
        self.schoolName.text = EduLinkAPI.shared.authorisedUser.school
        self.username.delegate = self
        self.password.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    private func showError(_ error: String) {
        let errorView: ErrorView = .fromNib()
        errorView.text.text = error
        errorView.changeGoBackLabel("Go Back")
        errorView.retryButton.isHidden = true
        if let nc = self.navigationController { errorView.startWorking(nc) }
    }

    @IBAction func login(_ sender: Any) {
        guard let username = self.username.text, let password = self.password.text else {
            self.showError("Username and Password can't be empty")
            return
        }
        if username.isEmpty || password.isEmpty {
            self.showError("Username and Password can't be empty")
            return
        }
        // You're welcome Sullivan
        if username == "Cheese" && password == "Cheese" {
            return UIApplication.shared.open(URL(string: "https://www.youtube.com/watch?v=SyimUCBIo6c")!)
        }
        if let nc = self.navigationController { self.workingCover.startWorking(nc) }
        self.dismissKeyboard(self)
        LoginManager.shared.loginz(username: username, password: password, { (success, error) -> Void in
            DispatchQueue.main.async {
                self.workingCover.stopWorking()
                if success {
                    if self.savePassword.isOn {
                        LoginManager.shared.saveLogin()
                        EduLinkAPI.shared.defaults.setValue(LoginManager.shared.username, forKey: "PreferredUsername")
                        EduLinkAPI.shared.defaults.setValue(LoginManager.shared.schoolCode, forKey: "PreferredSchool")
                    }
                    self.performSegue(withIdentifier: "Centralis.Login", sender: nil)
                } else {
                    self.showError(error ?? "Fuck")
                }
            }
        })
    }
}

extension NewUserUPController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
     @objc private func dismissKeyboard (_ sender: Any) {
        self.username.resignFirstResponder()
        self.password.resignFirstResponder()
    }
}

