//
//  CentralisNavigationController.swift
//  Centralis
//
//  Created by Andromeda on 26/11/2021.
//

import UIKit

class CentralisNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.updateCentralisColours()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateCentralisColours),
                                               name: ThemeManager.ThemeUpdate,
                                               object: nil)
    }
    
    @objc private func updateCentralisColours() {
        view.tintColor = .tintColor
    }
   
}
