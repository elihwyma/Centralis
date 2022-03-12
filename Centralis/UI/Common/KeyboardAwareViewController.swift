//
//  KeyboardAwareViewController.swift
//  Centralis
//
//  Created by Andromeda on 26/11/2021.
//

import UIKit

public class KeyboardAwareViewController: UIViewController {

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .backgroundColor
        view.tintColor = .tintColor
        navigationController?.navigationBar.tintColor = .tintColor
        
        NotificationCenter.default.addObserver(self, selector: #selector(_keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(_keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func _keyboardWillShow(notification: NSNotification) {
        if var keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                keyboardSize.size.height += 40.0
                keyboardWillShow(with: keyboardSize)
            }
        }
    }

    @objc private func _keyboardWillHide(notification: NSNotification) {
        keyboardWillHide()
    }
    
    public func keyboardWillShow(with size: CGRect) {
        
    }
    
    public func keyboardWillHide() {
        
    }
    
}
