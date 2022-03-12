//
//  ZViewController.swift
//  Centralis
//
//  Created by Andromeda on 26/11/2021.
//

import UIKit
import Evander

class UserPasswordViewController: KeyboardAwareViewController {
    
    private let server: URL
    private let schoolCode: String
    private let schoolID: String
    
    init(details: SchoolDetails) {
        self.server = details.server
        self.schoolCode = details.code
        self.schoolID = details.school_id
        super.init(nibName: nil, bundle: nil)
    }
    
    init(login: UserLogin) {
        self.server = login.server
        self.schoolCode = login.schoolCode
        self.schoolID = login.schoolID
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Now Enter your Username and Password"
        label.font = UIFont.systemFont(ofSize: 25, weight: .bold)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var usernameField: RoundedTextField = {
        let field = RoundedTextField()
        field.delegate = self
        field.translatesAutoresizingMaskIntoConstraints = false
        field.heightAnchor.constraint(equalToConstant: 45).isActive = true
        field.autocorrectionType = .no
        field.textContentType  = .username
        field.placeholder = "Username"
        field.layer.masksToBounds = true
        field.layer.cornerRadius = 10
        field.layer.cornerCurve = .continuous
        field.backgroundColor = .secondaryBackgroundColor
        return field
    }()
    
    private lazy var passwordField: RoundedTextField = {
        let field = RoundedTextField()
        field.delegate = self
        field.translatesAutoresizingMaskIntoConstraints = false
        field.heightAnchor.constraint(equalToConstant: 45).isActive = true
        field.autocorrectionType = .no
        field.textContentType  = .password
        field.isSecureTextEntry = true
        field.placeholder = "Password"
        field.layer.masksToBounds = true
        field.layer.cornerRadius = 10
        field.layer.cornerCurve = .continuous
        field.backgroundColor = .secondaryBackgroundColor
        return field
    }()
    
    public var errorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .systemRed
        label.numberOfLines = 2
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private lazy var loginButtonAnchor = loginButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -25)
    private lazy var loginButton: LoadingButton = {
        let button = LoadingButton(primaryAction: UIAction(handler: { [weak self] _ in
            guard let `self` = self,
                  !self.loginButton.isLoading,
                  let username = self.usernameField.text,
                  !username.isEmpty,
                  let password = self.passwordField.text,
                  !password.isEmpty else {
                      self?.errorLabel.text = "Username/Password cannot be empty"
                      return
            }
            self.loginButton.isLoading = true
            let login = UserLogin(server: self.server, schoolID: self.schoolID, schoolCode: self.schoolCode, username: username, password: password)
            self.loginButton.isLoading = true
            LoginManager.login(login, _indexBypass: true) { [weak self] error, authenticatedUser in
                guard let `self` = self else { return }
                Thread.mainBlock {
                    if let user = authenticatedUser {
                        let status = LoginManager.save(login: login)
                        if status != noErr {
                            self.errorLabel.text = SecCopyErrorMessageString(status, nil) as String? ?? "Unknown Error When Saving Login"
                            self.loginButton.isLoading = false
                            return
                        }
                        (UIApplication.shared.delegate as! AppDelegate).setRootViewController(IndexingViewController())
                    } else {
                        self.errorLabel.text = error ?? "Unknown Error"
                        self.loginButton.isLoading = false
                    }
                }
            }
        }))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .tintColor
        button.setTitle("Login", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.layer.masksToBounds = true
        button.layer.cornerCurve = .continuous
        button.layer.cornerRadius = 25
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        view.addGestureRecognizer(tapGesture)

        view.addSubview(label)
        view.addSubview(usernameField)
        view.addSubview(passwordField)
        view.addSubview(loginButton)
        view.addSubview(errorLabel)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 25),
            label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            label.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
            
            usernameField.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 10),
            usernameField.leadingAnchor.constraint(equalTo: label.leadingAnchor),
            usernameField.trailingAnchor.constraint(equalTo: label.trailingAnchor),
            
            passwordField.topAnchor.constraint(equalTo: usernameField.bottomAnchor, constant: 5),
            passwordField.leadingAnchor.constraint(equalTo: label.leadingAnchor),
            passwordField.trailingAnchor.constraint(equalTo: label.trailingAnchor),
            
            loginButtonAnchor,
            loginButton.leadingAnchor.constraint(equalTo: label.leadingAnchor),
            loginButton.trailingAnchor.constraint(equalTo: label.trailingAnchor),
            
            errorLabel.leadingAnchor.constraint(equalTo: label.leadingAnchor),
            errorLabel.trailingAnchor.constraint(equalTo: label.trailingAnchor),
            errorLabel.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 5)
        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        usernameField.becomeFirstResponder()
    }
    
    override func keyboardWillShow(with size: CGRect) {
        if loginButtonAnchor.constant == -25 {
            loginButtonAnchor.constant -= size.height
        }
    }
    
    override func keyboardWillHide() {
        if loginButtonAnchor.constant != -25 {
            loginButtonAnchor.constant = -25
        }
    }

}

extension UserPasswordViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
     @objc private func dismissKeyboard (_ sender: Any) {
         usernameField.resignFirstResponder()
         passwordField.resignFirstResponder()
    }
}
