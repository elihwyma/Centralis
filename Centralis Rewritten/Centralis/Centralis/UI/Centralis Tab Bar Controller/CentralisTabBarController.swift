//
//  CentralisTabBarController.swift
//  Centralis
//
//  Created by Andromeda on 26/11/2021.
//

import UIKit

final class CentralisTabBarController: UITabBarController {
    
    static let shared = CentralisTabBarController()
    public var errorStackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.distribution = .equalSpacing
        view.backgroundColor = .secondaryBackgroundColor
        view.layer.masksToBounds = true
        view.layer.cornerCurve = .continuous
        view.layer.cornerRadius = 7.5
        return view
    }()
    
    private class ErrorView: UIView {
        
        private let errorLabel: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.numberOfLines = 0
            let heightConstant = label.heightAnchor.constraint(equalToConstant: 0)
            heightConstant.priority = UILayoutPriority(250)
            let heightAdjustable = label.heightAnchor.constraint(greaterThanOrEqualToConstant: 0)
            NSLayoutConstraint.activate([
                heightConstant,
                heightAdjustable
            ])
            label.textAlignment = .left
            label.backgroundColor = .systemRed
            return label
        }()
        
        private let retryButton: UIButton = {
            let button = UIButton()
            button.contentMode = .scaleAspectFill
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: 20).isActive = true
            button.widthAnchor.constraint(equalToConstant: 20).isActive = true
            button.setImage(UIImage(systemName: "arrow.clockwise.circle"), for: .normal)
            return button
        }()
        
        init(error: String, retryBlock: @escaping (() -> Void)) {
            super.init(frame: .zero)
            
            addSubview(errorLabel)
            addSubview(retryButton)
            retryButton.addAction(UIAction(handler: { _ in
                retryBlock()
            }), for: .touchUpInside)
            
            errorLabel.text = error
            translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                errorLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 7.5),
                errorLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
                errorLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
                
                retryButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -7.5),
                retryButton.centerYAnchor.constraint(equalTo: centerYAnchor),
                errorLabel.trailingAnchor.constraint(equalTo: retryButton.leadingAnchor, constant: -7.5)
            ])
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

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
        
        view.addSubview(errorStackView)
        NSLayoutConstraint.activate([
            errorStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            errorStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            errorStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
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
    }
    
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
    
    
    public func error(_ string: String, retry: @escaping (() -> Void)) {
        let view = ErrorView(error: string, retryBlock: retry)
        errorStackView.addArrangedSubview(view)
    }
}
