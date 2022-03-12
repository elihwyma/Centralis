//
//  MyMathsLoginViewController.swift
//  Centralis
//
//  Created by Amy While on 11/03/2022.
//

import UIKit
import Evander

final class MyMathsLoginViewController: KeyboardAwareViewController {
    
    private func genericField(name: String) -> RoundedTextField {
        let field = RoundedTextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.heightAnchor.constraint(equalToConstant: 37.5).isActive = true
        field.autocorrectionType = .no
        field.textContentType  = .username
        field.placeholder = name
        field.layer.masksToBounds = true
        field.layer.cornerRadius = 10
        field.layer.cornerCurve = .continuous
        field.backgroundColor = .secondaryBackgroundColor
        field.isSecureTextEntry = true
        field.delegate = self
        return field
    }
    
    private lazy var textFieldList: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.distribution = .equalSpacing
        view.spacing = 7.5
        
        view.addArrangedSubview(schoolUser)
        view.addArrangedSubview(schoolPass)
        view.addArrangedSubview(username)
        view.addArrangedSubview(password)
        
        return view
    }()
    
    private var textView: UITextView = {
        let textView = UITextView(frame: .zero)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.isSelectable = false
        textView.backgroundColor = .clear
        textView.textContainerInset = UIEdgeInsets.zero
        textView.textContainer.lineFragmentPadding = 0
        textView.font = UIFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        textView.textColor = .label
        textView.layoutManager.allowsNonContiguousLayout = false
        return textView
    }()
    
    private lazy var schoolUser: RoundedTextField = genericField(name: "School Username")
    private lazy var schoolPass: RoundedTextField = genericField(name: "School Password")
    private lazy var username: RoundedTextField = genericField(name: "Username")
    private lazy var password: RoundedTextField = genericField(name: "Password")

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(textFieldList)
        view.addSubview(textView)
        title = "MyMaths"
        
        NSLayoutConstraint.activate([
            textFieldList.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
            textFieldList.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            textFieldList.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            textView.topAnchor.constraint(equalTo: textFieldList.bottomAnchor, constant: 15),
            textView.leadingAnchor.constraint(equalTo: textFieldList.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: textFieldList.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -5)
        ])
        
        if let currentLogin = LoginManager.loadMyMathsLogin().1 {
            schoolUser.text = currentLogin.schoolUser
            schoolPass.text = currentLogin.schoolPass
            username.text = currentLogin.username
            password.text = currentLogin.password
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Login", style: .done, target: self, action: #selector(loadTasks))
    }
    
    @objc private func loadTasks() {
        guard let currentLogin = currentLogin else { return }
        textView.text = ""
        navigationItem.rightBarButtonItem?.isEnabled = false
        dismissKeyboard(nil)
        MyMaths.shared.getTasks(login: currentLogin) { [weak self] log in
            self?.add(text: log)
        } _: { [weak self] error, currentTasks, pastTasks in
            if let error = error {
                self?.add(text: "[x] \(error)")
            } else if let currentTasks = currentTasks,
                let pastTasks = pastTasks {
                guard !currentTasks.isEmpty || !pastTasks.isEmpty else {
                    self?.add(text: "[x] Could not get find any current or past tasks, maybe try again?")
                    return
                }
                self?.add(text: "[*] Got \(currentTasks.count) current tasks and \(pastTasks.count) past tasks")
                Thread.mainBlock {
                    self?.navigationController?.pushViewController(MyMathsTaskList(currentTasks: currentTasks, pastTasks: pastTasks), animated: true)
                }
            } else {
                self?.add(text: "[x] Unknown Error")
            }
            Thread.mainBlock {
                self?.navigationItem.rightBarButtonItem?.isEnabled = true
            }
        }
    }
    
    private var currentLogin: MyMaths.MyMathsLogin? {
        guard let schoolUser = schoolUser.text,
              let schoolPass = schoolPass.text,
              let username = username.text,
              let password = password.text else { return nil }
        return MyMaths.MyMathsLogin(schoolUser: schoolUser, schoolPass: schoolPass, username: username, password: password)
    }
    
    private func saveLogin() {
        if let currentLogin = currentLogin {
            LoginManager.saveMyMaths(login: currentLogin)
        }
    }
    
    public func add(text: String) {
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.add(text: text)
            }
            return
        }
        textView.text = (textView.text ?? "") + "\(text)\n"
        let point = CGPoint(x: 0, y: textView.contentSize.height - textView.bounds.size.height)
        textView.setContentOffset(point, animated: false)
    }

}

extension MyMathsLoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
     @objc private func dismissKeyboard (_ sender: Any?) {
         schoolUser.resignFirstResponder()
         schoolPass.resignFirstResponder()
         username.resignFirstResponder()
         password.resignFirstResponder()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        saveLogin()
    }
    
}
