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
    
    private lazy var popupView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(dynamicProvider: { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.00)
            } else {
                return UIColor(red: 0.99, green: 1.00, blue: 1.00, alpha: 1.00)
            }
        })
        
        let labelStackView = UIStackView()
        labelStackView.translatesAutoresizingMaskIntoConstraints = false
        labelStackView.axis = .vertical
        labelStackView.distribution = .fillProportionally
        labelStackView.alignment = .leading
        labelStackView.addArrangedSubview(titleLabel)
        labelStackView.addArrangedSubview(subtitleLabel)
        
        view.addSubview(labelStackView)
        view.addSubview(progressBar)
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 60),
            
            labelStackView.heightAnchor.constraint(equalToConstant: 45),
            labelStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            labelStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            labelStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 6.5),
            
            progressBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressBar.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        return view
    }()
    private var progressBar: UIProgressView = {
        let view = UIProgressView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 0.7).isActive = true
        view.progressViewStyle = .bar
        return view
    }()
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        label.heightAnchor.constraint(equalToConstant: 20).isActive = true
        return label
    }()
    private var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 13)
        label.adjustsFontSizeToFitWidth = true
        label.heightAnchor.constraint(equalToConstant: 15).isActive = true
        return label
    }()
    
    public var currentProgress: Float {
        set {
            Thread.mainBlock { [self] in
                FRUIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut) { [self] in
                    progressBar.progress = newValue
                }
            }
        }
        get {
            if Thread.isMainThread {
                return progressBar.progress
            } else {
                var progress: Float = 0
                DispatchQueue.main.sync(flags: .barrier) {
                    progress = self.progressBar.progress
                }
                return progress
            }
        }
    }
    
    private lazy var popupBottom = popupView.bottomAnchor.constraint(equalTo: tabBar.topAnchor, constant: 60)
    private var tabBarExpanded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewControllers = [homeViewController,
                           messagesViewController,
                           infoViewController]

        view.insertSubview(popupView, belowSubview: tabBar)
        NSLayoutConstraint.activate([
            popupView.widthAnchor.constraint(equalTo: tabBar.widthAnchor),
            popupBottom,
        ])
    }
    
    public func setExpanded(_ expanded: Bool, animated: Bool = true) {
        if !Thread.isMainThread {
            DispatchQueue.main.async { [self] in
                self.setExpanded(expanded, animated: animated)
            }
            return
        }
        if expanded == self.tabBarExpanded && animated { return }
        let animationBlock: () -> Void = { [self] in
            for view in viewControllers ?? [] {
                view.additionalSafeAreaInsets.bottom = expanded ? 60 : 0
            }
            popupBottom.constant = expanded ? 0 : 60
            self.view.layoutIfNeeded()
        }
        self.tabBarExpanded = expanded
        if !expanded {
            currentProgress = 0.0
        }
        if animated {
            FRUIView.animate(withDuration: 0.1,
                           delay: 0,
                           options: .curveEaseInOut,
                           animations: animationBlock)
        } else {
            animationBlock()
        }
    }
    
    public func set(title: String, subtitle: String, progress: Float) {
        if !Thread.isMainThread {
            DispatchQueue.main.async { [self] in
                self.set(title: title, subtitle: subtitle, progress: progress)
            }
            return
        }
        NSLog("Title: \(title), Subtitle: \(subtitle), Progress: \(progress)")
        if !self.tabBarExpanded {
            self.setExpanded(true)
        }
        titleLabel.text = title
        subtitleLabel.text = subtitle
        currentProgress = progress
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
