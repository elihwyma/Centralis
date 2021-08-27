//
//  NewUserSchoolController.swift
//  Centralis
//
//  Created by AW on 28/12/2020.
//

import UIKit
//import libCentralis

class NewUserSchoolController: UIViewController {

    public lazy var schoolCode: RoundedTextField = {
        let view = RoundedTextField()
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 45).isActive = true
        view.autocorrectionType = .no
        view.placeholder = "School Code"
        view.textContentType = .username
        view.backgroundColor = .centralisBackgroundColor
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 10
        view.layer.cornerCurve = .continuous
        return view
    }()
    
    var workingCover: WorkingCover = .fromNib()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        EduLinkAPI.shared.clear()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
        
        title = "New User"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Continue", style: .done, target: self, action: #selector(continueButton))
        view.backgroundColor = .centralisViewColor
        
        view.addSubview(schoolCode)
        NSLayoutConstraint.activate([
            schoolCode.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
            schoolCode.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            schoolCode.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15),
        ])
    }
    
    private func showError(_ error: String) {
        let errorView: ErrorView = .fromNib()
        errorView.text.text = error
        errorView.changeGoBackLabel("Go Back")
        errorView.retryButton.isHidden = true
        if let nc = self.navigationController { errorView.startWorking(nc) }
    }

    @objc func continueButton() {
        guard let code = self.schoolCode.text else {
            self.showError("School Code can't be empty")
            return
        }
        if code.isEmpty {
            self.showError("School Code can't be empty")
            return
        }
        if let nc = self.navigationController { self.workingCover.startWorking(nc) }
        self.dismissKeyboard(self)
        LoginManager.shared.schoolProvisioning(schoolCode: code, { (success, error) -> Void in
            DispatchQueue.main.async {
                self.workingCover.stopWorking()
                if success {
                    self.navigationController?.pushViewController(NewUserUPController(), animated: true)
                } else {
                    self.showError(error ?? "Fuck")
                }
            }
        })
    }
    
    @objc func cancel() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension NewUserSchoolController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
     @objc private func dismissKeyboard (_ sender: Any) {
        self.schoolCode.resignFirstResponder()
    }
}


final public class RoundedTextField: UITextField {
    
    public override func textRect(forBounds bounds: CGRect) -> CGRect {
        bounds.insetBy(dx: 15, dy: 0)
    }
    
    public override func editingRect(forBounds bounds: CGRect) -> CGRect {
        bounds.insetBy(dx: 15, dy: 0)
    }
    
}
