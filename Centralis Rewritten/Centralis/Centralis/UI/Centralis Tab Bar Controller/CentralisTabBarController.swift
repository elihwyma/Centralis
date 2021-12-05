//
//  CentralisTabBarController.swift
//  Centralis
//
//  Created by Andromeda on 26/11/2021.
//

import UIKit

final class CentralisTabBarController: UITabBarController {
    
    static let shared = CentralisTabBarController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewControllers = [homeViewController, infoViewController]

        self.updateCentralisColours()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateCentralisColours),
                                               name: ThemeManager.ThemeUpdate,
                                               object: nil)
    }
    
    @objc private func updateCentralisColours() {
        self.view.tintColor = .tintColor
    }
    
    public var homeViewController: CentralisNavigationController = {
        let viewController = HomeViewController(style: .insetGrouped)
        let navController = CentralisNavigationController(rootViewController: viewController)
        let tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), selectedImage: UIImage(systemName: "house"))
        navController.tabBarItem = tabBarItem
        viewController.title = "Home"
        navController.navigationBar.prefersLargeTitles = true
        return navController
    }()
    
    public var infoViewController: CentralisNavigationController = {
        let viewController = InfoViewController(style: .insetGrouped)
        let navController = CentralisNavigationController(rootViewController: viewController)
        let tabBarItem = UITabBarItem(title: "Info", image: UIImage(systemName: "i.circle"), selectedImage: UIImage(systemName: "i.circle"))
        navController.tabBarItem = tabBarItem
        viewController.title = "Info"
        navController.navigationBar.prefersLargeTitles = true
        return navController
    }()
    
}
