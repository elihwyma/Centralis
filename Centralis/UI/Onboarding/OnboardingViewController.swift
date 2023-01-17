//
//  OnboardingViewController.swift
//  Centralis
//
//  Created by Andromeda on 26/11/2021.
//

import UIKit
import AuthenticationServices

class OnboardingViewController: UIViewController {
    
    private var isWorking = false
    
    private var iconNavBarIconView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: 32, height: 32)))
    private lazy var iconNavBarIconViewController: UIView = {
        let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 50, height: 32)))
        view.addSubview(iconNavBarIconView)
        iconNavBarIconView.center = view.center
        iconNavBarIconView.image = UIImage(named: Bundle.main.iconFileName) ?? UIImage(named: "AppIcon60x60")
        iconNavBarIconView.contentMode = .scaleAspectFill
        iconNavBarIconView.layer.masksToBounds = true
        iconNavBarIconView.layer.cornerRadius = 32 / 4
        iconNavBarIconView.layer.cornerCurve = .continuous
        return view
    }()
    
    private var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "The best way to use EduLink"
        label.font = UIFont.systemFont(ofSize: 35, weight: .bold)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var loginButton: UIButton = {
        let button = UIButton(primaryAction: UIAction(handler: { [weak self] _ in
            guard !(self?.isWorking ?? false) else { return }
            self?.presentLoginController()
        }))
        button.backgroundColor = .tintColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Login", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.layer.masksToBounds = true
        button.layer.cornerCurve = .continuous
        button.layer.cornerRadius = 25
        return button
    }()
    
    private lazy var myMathsButton: UIButton = {
        let button = UIButton(primaryAction: UIAction(handler: { [weak self] _ in
            guard !(self?.isWorking ?? false) else { return }
            self?.navigationController?.pushViewController(MyMathsLoginViewController(nibName: nil, bundle: nil), animated: true)
        }))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .tintColor
        button.setTitle("MyMaths", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.layer.masksToBounds = true
        button.layer.cornerCurve = .continuous
        button.layer.cornerRadius = 25
        return button
    }()
 
    override func viewDidLoad() {
        if let login = LoginManager.loadLogin().1 {
            (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController = CentralisTabBarController.shared
            LoginMiddleware.shared.login(with: login)
            return
        }
        
        super.viewDidLoad()
        
        view.backgroundColor = .backgroundColor
        
        navigationItem.titleView = iconNavBarIconViewController
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.isTranslucent = true
        
        view.addSubview(label)
        view.addSubview(loginButton)
        view.addSubview(myMathsButton)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            label.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
            
            loginButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            loginButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
            loginButton.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 50),
            
            myMathsButton.leadingAnchor.constraint(equalTo: loginButton.leadingAnchor),
            myMathsButton.trailingAnchor.constraint(equalTo: loginButton.trailingAnchor),
            myMathsButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 12.5)
        ])
    }
    
    private func presentLoginController() {
        navigationController?.pushViewController(SchoolCodeViewController(), animated: true)
    }
    
}
