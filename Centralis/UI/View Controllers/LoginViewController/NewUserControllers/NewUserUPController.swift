//
//  NewUserUPController.swift
//  Centralis
//
//  Created by AW on 28/12/2020.
//

import UIKit
//import libCentralis

class NewUserUPController: UIViewController {

    public var schoolImage: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 50),
            view.widthAnchor.constraint(equalToConstant: 50)
        ])
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 25
        return view
    }()
    
    public var schoolName: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.adjustsFontSizeToFitWidth = true
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    public lazy var username: RoundedTextField = {
        let view = RoundedTextField()
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 45).isActive = true
        view.autocorrectionType = .no
        view.placeholder = "Username"
        view.textContentType = .username
        view.backgroundColor = .centralisBackgroundColor
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 10
        view.layer.cornerCurve = .continuous
        return view
    }()
    
    public lazy var password: RoundedTextField = {
        let view = RoundedTextField()
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 45).isActive = true
        view.autocorrectionType = .no
        view.placeholder = "Password"
        view.textContentType = .password
        view.backgroundColor = .centralisBackgroundColor
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 10
        view.layer.cornerCurve = .continuous
        return view
    }()
    
    public var savePassword: UISwitch = {
        let view = UISwitch()
        view.onTintColor = .centralisTintColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isOn = true
        return view
    }()
    
    public var savePasswordLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.adjustsFontSizeToFitWidth = true
        view.setContentHuggingPriority(UILayoutPriority(251), for: .horizontal)
        view.setContentHuggingPriority(UILayoutPriority(251), for: .vertical)
        view.setContentCompressionResistancePriority(UILayoutPriority(749), for: .horizontal)
        view.heightAnchor.constraint(equalToConstant: 30).isActive = true
        view.text = "Save Password"
        return view
    }()
    
    var workingCover: WorkingCover = .fromNib()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let data = EduLinkAPI.shared.authorisedSchool.schoolLogo,
           let image = UIImage(data: data) {
            self.schoolImage.image = image
        }
      
        self.schoolName.text = EduLinkAPI.shared.authorisedUser.school
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Login", style: .done, target: self, action: #selector(login))
        
        view.addSubview(username)
        view.addSubview(schoolImage)
        view.addSubview(schoolName)
        view.addSubview(password)
        view.addSubview(savePassword)
        view.addSubview(savePasswordLabel)
        view.backgroundColor = .centralisViewColor
        
        NSLayoutConstraint.activate([
            username.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15),
            username.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            username.topAnchor.constraint(equalTo: schoolImage.bottomAnchor, constant: 15),
            
            password.leadingAnchor.constraint(equalTo: username.leadingAnchor),
            password.trailingAnchor.constraint(equalTo: username.trailingAnchor),
            password.topAnchor.constraint(equalTo: username.bottomAnchor, constant: 10),
            
            savePasswordLabel.leadingAnchor.constraint(equalTo: username.leadingAnchor),
            savePasswordLabel.topAnchor.constraint(equalTo: password.bottomAnchor, constant: 10),
            savePasswordLabel.trailingAnchor.constraint(equalTo: savePassword.leadingAnchor, constant: -5),
            
            savePassword.topAnchor.constraint(equalTo: savePasswordLabel.topAnchor),
            savePassword.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15),
            
            schoolImage.leadingAnchor.constraint(equalTo: username.leadingAnchor),
            schoolImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
            
            schoolName.trailingAnchor.constraint(equalTo: username.trailingAnchor),
            schoolName.topAnchor.constraint(equalTo: schoolImage.topAnchor),
            schoolName.leadingAnchor.constraint(equalTo: schoolImage.trailingAnchor, constant: 5)
        ])
    }
        
    private func showError(_ error: String) {
        let errorView: ErrorView = .fromNib()
        errorView.text.text = error
        errorView.changeGoBackLabel("Go Back")
        errorView.retryButton.isHidden = true
        if let nc = self.navigationController { errorView.startWorking(nc) }
    }

    @objc func login() {
        guard let username = self.username.text, let password = self.password.text else {
            self.showError("Username and Password can't be empty")
            return
        }
        if username.isEmpty || password.isEmpty {
            self.showError("Username and Password can't be empty")
            return
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
                    let login = LoginManager.shared.currentLogin
                    (UIApplication.shared.delegate as! AppDelegate).setRootViewController(CentralisNavigationController(rootViewController: HomeViewController(login: login)))
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

