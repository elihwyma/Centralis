//
//  RoundedTextField.swift
//  Centralis
//
//  Created by Andromeda on 26/11/2021.
//

import UIKit

final public class RoundedTextField: UITextField {
    
    public override func textRect(forBounds bounds: CGRect) -> CGRect {
        bounds.insetBy(dx: 15, dy: 0)
    }
    
    public override func editingRect(forBounds bounds: CGRect) -> CGRect {
        bounds.insetBy(dx: 15, dy: 0)
    }
    
}
