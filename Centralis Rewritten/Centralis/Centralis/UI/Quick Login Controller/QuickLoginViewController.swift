//
//  QuickLoginViewController.swift
//  Centralis
//
//  Created by Andromeda on 26/11/2021.
//

import UIKit

class QuickLoginViewController: UIViewController {
    
    private let login: UserLogin
    
    private var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.hidesWhenStopped = true
        return view
    }()
    
    private var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Connecting to EduLink"
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 2
        return label
    }()
    
    private var errorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .systemRed
        label.numberOfLines = 2
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        return label
    }()
    
    private lazy var logoutButton: LoadingButton = {
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
    
    private lazy var retryButton: LoadingButton = {
        let button = LoadingButton(primaryAction: UIAction(handler: { [weak self] _ in
            guard let `self` = self else { return }
            self.retryButton.isEnabled = false
            self.logoutButton.isEnabled = false
            self.loginToAccount()
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
    
    init(login: UserLogin) {
        self.login = login
        super.init(nibName: nil, bundle: nil)
        self.loginToAccount()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
    
    private func set(error: String?) {
        UIView.animate(withDuration: 0.3) { [weak self] in
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
    
    private func loginToAccount() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        LoginManager.login(login) { [weak self] error, authenticatedUser in
            DispatchQueue.main.async {
                if authenticatedUser != nil {
                    (UIApplication.shared.delegate as! AppDelegate).setRootViewController(CentralisTabBarController.shared)
                    return
                }
                self?.set(error: error ?? "Unknown Error")
            }
            
        }
    }
    
}
