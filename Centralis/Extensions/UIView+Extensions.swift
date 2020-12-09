//
//  UIView+Extensions.swift
//  Shade
//
//  Created by Amy While on 27/10/2020.
//

import UIKit

extension UIView {
    class func fromNib<T: UIView>() -> T {
        return Bundle(for: T.self).loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
    
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder?.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
    
    class func embed(parent: UIViewController, container: UIView, child: UIViewController) {
        child.willMove(toParent: parent)
        parent.addChild(child)
        container.addSubview(child.view)
        child.didMove(toParent: parent)
        child.view.frame = CGRect(x: 0, y: 0, width: container.frame.size.width, height: container.frame.size.height)
    }
}
