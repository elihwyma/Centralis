//
//  SchoolCodeViewController.swift
//  Centralis
//
//  Created by Andromeda on 26/11/2021.
//

import UIKit
import SafariServices

class SchoolCodeViewController: KeyboardAwareViewController {
    
    private let easterEggs: [String: String] = [
        "heat from fire": "Fire from heat",
        "sw1a 1aa": "Stop doxxing the queen!!!!",
        "is anyone there?": "【=◈︿◈=】♡"
    ]
    
    private var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "To get started enter your school code or postcode"
        label.font = UIFont.systemFont(ofSize: 25, weight: .bold)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var field: RoundedTextField = {
        let field = RoundedTextField()
        field.delegate = self
        field.translatesAutoresizingMaskIntoConstraints = false
        field.heightAnchor.constraint(equalToConstant: 45).isActive = true
        field.autocorrectionType = .no
        field.textContentType  = .username
        field.placeholder = "School Code"
        field.layer.masksToBounds = true
        field.layer.cornerRadius = 10
        field.layer.cornerCurve = .continuous
        field.backgroundColor = .secondaryBackgroundColor
        return field
    }()
    
    private var errorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .systemRed
        label.numberOfLines = 2
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private lazy var nextButtonAnchor = nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -25)
    private lazy var nextButton: LoadingButton = {
        let button = LoadingButton(primaryAction: UIAction(handler: { [weak self] _ in
            guard let `self` = self,
                  !self.nextButton.isLoading,
                  let text = self.field.text,
                  !text.isEmpty else {
                      self?.errorLabel.text = "Code cannot be empty"
                      return
            }
            if let easerEgg = self.easterEggs[text.lowercased()] {
                self.errorLabel.text = easerEgg
                return
            }
            self.nextButton.isLoading = true
            LoginManager.loadSchool(from: text) { [weak self] error, details in
                guard let `self` = self else { return }
                DispatchQueue.main.async {
                    if let details = details {
                        self.navigationController?.pushViewController(UserPasswordViewController(details: details), animated: true)
                    } else {
                        self.errorLabel.text = error ?? "Unknown Error"
                        self.nextButton.isLoading = false
                    }
                }
                
            }
        }))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .tintColor
        button.setTitle("Next", for: .normal)
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
        view.addSubview(field)
        view.addSubview(nextButton)
        view.addSubview(errorLabel)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 25),
            label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            label.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
            
            field.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 10),
            field.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            field.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
            
            nextButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            nextButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
            nextButtonAnchor,
            
            errorLabel.leadingAnchor.constraint(equalTo: field.leadingAnchor),
            errorLabel.trailingAnchor.constraint(equalTo: field.trailingAnchor),
            errorLabel.topAnchor.constraint(equalTo: field.bottomAnchor, constant: 5)
        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        field.becomeFirstResponder()
    }

    override func keyboardWillShow(with size: CGRect) {
        if nextButtonAnchor.constant == -25 {
            nextButtonAnchor.constant -= size.height
        }
    }
    
    override func keyboardWillHide() {
        if nextButtonAnchor.constant != -25 {
            nextButtonAnchor.constant = -25
        }
    }

}

extension SchoolCodeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
     @objc private func dismissKeyboard (_ sender: Any) {
        field.resignFirstResponder()
    }
}
