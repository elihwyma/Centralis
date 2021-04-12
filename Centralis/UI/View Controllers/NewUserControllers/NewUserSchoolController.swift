//
//  NewUserSchoolController.swift
//  Centralis
//
//  Created by AW on 28/12/2020.
//

import UIKit
//import libCentralis

class NewUserSchoolController: UIViewController {

    @IBOutlet weak var schoolCode: UITextField!
    var workingCover: WorkingCover = .fromNib()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        EduLinkAPI.shared.clear()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
    private func setup() {
        self.schoolCode.delegate = self
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

    @IBAction func continueButton(_ sender: Any) {
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
                    self.performSegue(withIdentifier: "Centralis.ShowUP", sender: nil)
                } else {
                    self.showError(error ?? "Fuck")
                }
            }
        })
    }
    
    @IBAction func cancel(_ sender: Any) {
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
