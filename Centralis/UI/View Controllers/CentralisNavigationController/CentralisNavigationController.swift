//
//  CentralisNavigationController.swift
//  Centralis
//
//  Created by Charlie While on 22/04/2021.
//

import UIKit

class CentralisNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.updateColours()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateColours),
                                               name: ThemeManager.ThemeUpdate,
                                               object: nil)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        NotificationCenter.default.post(name: ThemeManager.ThemeUpdate, object: nil)
    }
    
    @objc private func updateColours() {
        self.view.tintColor = .centralisTintColor
    }
}
