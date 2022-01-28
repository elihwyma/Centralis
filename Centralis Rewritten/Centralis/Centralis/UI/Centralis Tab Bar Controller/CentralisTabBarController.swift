//
//  CentralisTabBarController.swift
//  Centralis
//
//  Created by Andromeda on 26/11/2021.
//

import UIKit
import Evander

final class CentralisTabBarController: UITabBarController {
    
    static let shared = CentralisTabBarController()
    
    private let popupView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .red
        return view
    }()
    private lazy var popupBottom = popupView.bottomAnchor.constraint(equalTo: tabBar.topAnchor, constant: 60)
    private var tabBarExpanded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewControllers = [homeViewController,
                           messagesViewController,
                           infoViewController]

        self.updateCentralisColours()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateCentralisColours),
                                               name: ThemeManager.ThemeUpdate,
                                               object: nil)
        
        view.insertSubview(popupView, belowSubview: tabBar)
        NSLayoutConstraint.activate([
            popupView.widthAnchor.constraint(equalTo: tabBar.widthAnchor),
            popupBottom,
            popupView.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.setExpanded(true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.setExpanded(false)
            }
        }
    }
    
    public func setExpanded(_ expanded: Bool, animated: Bool = true) {
        if expanded == self.tabBarExpanded && animated { return }
        let animationBlock: () -> Void = { [self] in
            for view in viewControllers ?? [] {
                view.additionalSafeAreaInsets.bottom = expanded ? 0 : 60
            }
            popupBottom.constant = expanded ? 0 : 60
            self.view.layoutIfNeeded()
        }
        self.tabBarExpanded = expanded
        if animated {
            FRUIView.animate(withDuration: 0.1,
                           delay: 0,
                           options: .curveEaseInOut,
                           animations: animationBlock)
        } else {
            animationBlock()
        }
    }
    
    public func set(message: String, progress: Float) {
        
        if !self.tabBarExpanded {
            
        }
    }
    
    @objc private func updateCentralisColours() {
        view.tintColor = .tintColor
    }
    
    public var homeViewController: CentralisNavigationController = {
        let viewController = HomeViewController(style: .insetGrouped)
        let navController = CentralisNavigationController(rootViewController: viewController)
        let image = UIImage(systemName: "house")
        let tabBarItem = UITabBarItem(title: "Home", image: image, selectedImage: image)
        navController.tabBarItem = tabBarItem
        viewController.title = "Home"
        navController.navigationBar.prefersLargeTitles = true
        return navController
    }()
    
    public var messagesViewController: CentralisNavigationController = {
        let viewController = MessagesViewController(style: .insetGrouped)
        let navController = CentralisNavigationController(rootViewController: viewController)
        let image = UIImage(systemName: "envelope")
        let tabBarItem = UITabBarItem(title: "Messages", image: image, selectedImage: image)
        navController.tabBarItem = tabBarItem
        viewController.title = "Messages"
        navController.navigationBar.prefersLargeTitles = true
        return navController
    }()
    
    public var infoViewController: CentralisNavigationController = {
        let viewController = InfoViewController(style: .insetGrouped)
        let navController = CentralisNavigationController(rootViewController: viewController)
        let image = UIImage(systemName: "i.circle")
        let tabBarItem = UITabBarItem(title: "Info", image: image, selectedImage: image)
        navController.tabBarItem = tabBarItem
        viewController.title = "Info"
        navController.navigationBar.prefersLargeTitles = true
        return navController
    }()
    
}
