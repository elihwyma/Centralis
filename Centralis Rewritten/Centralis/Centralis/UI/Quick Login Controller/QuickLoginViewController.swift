//
//  QuickLoginViewController.swift
//  Centralis
//
//  Created by Andromeda on 26/11/2021.
//

import UIKit
import Evander

class ProcessingViewController: UIViewController {
    
    public var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.hidesWhenStopped = true
        return view
    }()
    
    public var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 2
        return label
    }()
    
    public var errorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .systemRed
        label.numberOfLines = 2
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        return label
    }()
    
    public lazy var logoutButton: LoadingButton = {
        let button = LoadingButton(primaryAction: UIAction(handler: { [weak self] _ in
            guard let `self` = self else { return }
            self.retryButton.isEnabled = false
            self.logoutButton.isEnabled = false
            LoginManager.save(login: nil)
            (UIApplication.shared.delegate as! AppDelegate).setRootViewController(CentralisNavigationController(rootViewController: OnboardingViewController()))
        }))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .tintColor
        button.setTitle("Signout", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.layer.masksToBounds = true
        button.layer.cornerCurve = .continuous
        button.layer.cornerRadius = 25
        return button
    }()
    
    public lazy var retryButton: LoadingButton = {
        let button = LoadingButton(primaryAction: UIAction(handler: { [weak self] _ in
            guard let `self` = self else { return }
            self.retryButton.isEnabled = false
            self.logoutButton.isEnabled = false
        }))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .tintColor
        button.setTitle("Retry", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.layer.masksToBounds = true
        button.layer.cornerCurve = .continuous
        button.layer.cornerRadius = 25
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .backgroundColor
        view.addSubview(label)
        view.addSubview(activityIndicator)
        view.addSubview(retryButton)
        view.addSubview(logoutButton)
        view.addSubview(errorLabel)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            label.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
            label.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 10),
            
            errorLabel.trailingAnchor.constraint(equalTo: label.trailingAnchor),
            errorLabel.leadingAnchor.constraint(equalTo: label.leadingAnchor),
            errorLabel.bottomAnchor.constraint(equalTo: activityIndicator.topAnchor, constant: -10),
            
            logoutButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -25),
            logoutButton.leadingAnchor.constraint(equalTo: label.leadingAnchor),
            logoutButton.trailingAnchor.constraint(equalTo: label.trailingAnchor),
            
            retryButton.bottomAnchor.constraint(equalTo: logoutButton.topAnchor, constant: -25),
            retryButton.leadingAnchor.constraint(equalTo: label.leadingAnchor),
            retryButton.trailingAnchor.constraint(equalTo: label.trailingAnchor),
        ])
        
        retryButton.alpha = 0
        logoutButton.alpha = 0
    }
    
    public func set(error: String?) {
        FRUIView.animate(withDuration: 0.3) { [weak self] in
            guard let `self` = self else { return }
            if let error = error {
                self.retryButton.isEnabled = true
                self.logoutButton.isEnabled = true
                self.retryButton.alpha = 1
                self.logoutButton.alpha = 1
                self.activityIndicator.alpha = 0
                self.label.alpha = 0
                self.errorLabel.text = error
            } else {
                self.retryButton.isEnabled = false
                self.logoutButton.isEnabled = false
                self.retryButton.alpha = 0
                self.logoutButton.alpha = 0
                self.activityIndicator.alpha = 1
                self.label.alpha = 1
                self.errorLabel.text = nil
            }
        }
    }
    
    
    public func retryAction() {
        
    }
}

class QuickLoginViewController: ProcessingViewController {
    private let login: UserLogin
    
    private func loginToAccount() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        LoginManager.login(login) { [weak self] error, authenticatedUser in
            DispatchQueue.main.async {
                if authenticatedUser != nil {
                    if self != nil {
                        if PersistenceDatabase.shared.hasIndexed {
                            (UIApplication.shared.delegate as! AppDelegate).setRootViewController(CentralisTabBarController.shared)
                        } else {
                            (UIApplication.shared.delegate as! AppDelegate).setRootViewController(IndexingViewController())
                        }
                    }
                    return
                }
                self?.set(error: error ?? "Unknown Error")
            }
        }
    }
    
    public class func viewController(for login: UserLogin) -> UIViewController {
        if PersistenceDatabase.shared.hasIndexed {
            _ = QuickLoginViewController(login: login)
            return CentralisTabBarController.shared
        } else {
            return CentralisNavigationController(rootViewController: QuickLoginViewController(login: login))
        }
    }
    
    init(login: UserLogin) {
        self.login = login
        super.init(nibName: nil, bundle: nil)
        label.text = "Connecting to EduLink"
        self.loginToAccount()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func retryAction() {
        self.loginToAccount()
    }
    
}

class IndexingViewController: ProcessingViewController {
    
    override public func retryAction() {
        indexAccount()
    }
    
    public func indexAccount() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        PersistenceDatabase.persistenceIndex { [weak self] error, success in
            Thread.mainBlock {
                if success {
                    (UIApplication.shared.delegate as! AppDelegate).setRootViewController(CentralisTabBarController.shared)
                    return
                }
                self?.set(error: error ?? "Unknown Error")
            }
        }
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        label.text = "Indexing your account"
        indexAccount()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
