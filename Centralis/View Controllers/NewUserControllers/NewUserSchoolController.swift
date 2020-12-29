//
//  NewUserSchoolController.swift
//  Centralis
//
//  Created by Amy While on 28/12/2020.
//

import UIKit

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

    @IBAction func continueButton(_ sender: Any) {
        guard let code = self.schoolCode.text else {
            //TODO: Empty field
            return
        }
        if code.isEmpty {
            //TODO: Empty field
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
                    //TODO: More error handling here
                }
            }
        })
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
