//
//  StudentIDCreator.swift
//  Centralis
//
//  Created by Amy While on 01/09/2022.
//

import UIKit
import PassKit
import Evander

class StudentIDCreator: KeyboardAwareViewController {
    
    private var isWorking = false
    
    private func generateStackView() -> UIStackView {
        let dobStackView = UIStackView(frame: .zero)
        dobStackView.axis = .horizontal
        dobStackView.distribution = .equalSpacing
        dobStackView.alignment = .fill
        dobStackView.spacing = 10
        dobStackView.isUserInteractionEnabled = true
        return dobStackView
    }
    
    private lazy var gradYearPicker: UITextField = {
        let gradYearPicker = RoundedTextField(frame: .zero)
        gradYearPicker.textAlignment = .right
        gradYearPicker.keyboardType = .numberPad
        gradYearPicker.delegate = self
        gradYearPicker.text = "2023"
        gradYearPicker.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        gradYearPicker.backgroundColor = .yellow
        gradYearPicker.layer.masksToBounds = true
        gradYearPicker.layer.cornerRadius = 7.5
        gradYearPicker.translatesAutoresizingMaskIntoConstraints = false
        gradYearPicker.widthAnchor.constraint(equalToConstant: 80).isActive = true
        return gradYearPicker
    }()
    
    private let dobPicker: UIDatePicker = {
        let datePicker = UIDatePicker(frame: .zero)
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        return datePicker
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Student ID"
        
        let hostStackView = UIStackView(frame: .zero)
        hostStackView.translatesAutoresizingMaskIntoConstraints = false
        hostStackView.axis = .vertical
        hostStackView.distribution = .equalSpacing
        hostStackView.alignment = .fill
        hostStackView.spacing = 10
        hostStackView.isUserInteractionEnabled = true
        
        let description = UILabel(frame: .zero)
        description.numberOfLines = 0
        description.text = "This will generate a realistic looking school ID that will be added to your phones wallet. This can be used for getting student discounts in stores and as age verification if you're lucky 🤪"
        description.textAlignment = .center
        hostStackView.addArrangedSubview(description)
        
        
        let dobPickerLabel = UILabel(frame: .zero)
        dobPickerLabel.text = "Date of Birth (No lying 🤨)"
        dobPickerLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        dobPickerLabel.textAlignment = .left
       
        let dobStackView = generateStackView()
        dobStackView.addArrangedSubview(dobPickerLabel)
        dobStackView.addArrangedSubview(dobPicker)
        hostStackView.addArrangedSubview(dobStackView)
        
        let gradYearLabel = UILabel(frame: .zero)
        gradYearLabel.text = "Graduation Year 📅"
        gradYearLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        gradYearLabel.textAlignment = .left
        let gradStackView = generateStackView()
        gradStackView.addArrangedSubview(gradYearLabel)
        gradStackView.addArrangedSubview(gradYearPicker)
        hostStackView.addArrangedSubview(gradStackView)
        
        let addToWallet = PKAddPassButton(addPassButtonStyle: .black)
        addToWallet.transform = addToWallet.transform.rotated(by: .pi)
        addToWallet.addTarget(self, action: #selector(generatePass), for: .touchUpInside)
        hostStackView.addArrangedSubview(addToWallet)
        
        view.addSubview(hostStackView)
        NSLayoutConstraint.activate([
            hostStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
            hostStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            hostStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ])
    }

    @objc public func generatePass() {
        guard !isWorking else { return }
        var localWorking = true
        isWorking = true
        
        let alert = UIAlertController(title: "Downloading ID",
                                              message: nil,
                                              preferredStyle: .alert)
        let closeAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { [weak self] _ in
            self?.isWorking = false
            localWorking = false
            alert.dismiss(animated: true)
        })
        alert.addAction(closeAction)
        self.present(alert, animated: true)
        
        StudentID.generateID(dob: dobPicker.date, graduationYear: gradYearPicker.text ?? "2024") { [weak self] error, data in
            guard localWorking else { return }
            Thread.mainBlock {
                defer {
                    self?.isWorking = false
                }
                if let error = error {
                    alert.title = "Error!!!"
                    alert.message = error
                    return
                }
                guard let data = data else { return }
                let library = PKPassLibrary()
                let pass: PKPass
                do {
                    pass = try PKPass(data: data)
                } catch {
                    alert.title = "Error!!!"
                    alert.message = "Something went wrong! \(error.localizedDescription)"
                    return
                }
                if library.replacePass(with: pass) {
                    alert.dismiss(animated: true)
                    return
                }
                guard let addPassVC = PKAddPassesViewController(pass: pass) else {
                    alert.title = "Error!!!"
                    alert.message = "This time I have no idea what happened!"
                    return
                }
                addPassVC.view.tintColor = .tintColor
                alert.dismiss(animated: true) {
                    self?.present(addPassVC, animated: true)
                }
            }
        }
    }

}

extension StudentIDCreator: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        string == "" ||  CharacterSet(charactersIn: "0123456789").isSuperset(of: CharacterSet(charactersIn: string))
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
