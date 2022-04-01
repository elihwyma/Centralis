//
//  UIAlertController+Extensions.swift
//  Centralis
//
//  Created by Somica on 28/03/2022.
//

import UIKit

extension UIAlertController {
    
    func label(with string: String) -> UILabel? {
        @discardableResult func findTheFuckingLabel(_ view: UIView) -> UILabel? {
            for view in view.subviews {
                if let label = view as? UILabel,
                   label.text == string {
                    return label
                }
                if let label = findTheFuckingLabel(view) {
                    return label
                }
            }
            return nil
        }
        return findTheFuckingLabel(view)
    }
    
}
