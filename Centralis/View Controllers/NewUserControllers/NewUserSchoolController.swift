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
    }

    @IBAction func continueButton(_ sender: Any) {
        guard let code = self.schoolCode.text else {
            //TODO: Handle if text is empty
            return
        }
        self.workingCover.startWorking(self)
        LoginManager.shared.schoolProvisioning(schoolCode: code, rootCompletion: { (success, error) -> Void in
            DispatchQueue.main.async {
                if success {
                    self.workingCover.stopWorking()
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
    
     private func dismissKeyboard (_ sender: Any) {
        self.schoolCode.resignFirstResponder()
    }
}
