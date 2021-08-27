//
//  BaseViewController.swift
//  Centralis
//
//  Created by Andromeda on 27/08/2021.
//

import UIKit

class BaseViewController: UIViewController {
    
    public weak var referencedViewController: UIViewController?
    public var menuTableView = MenuTableView()
    public var workingCover: WorkingCover = .fromNib()
    public var login: SavedLogin
    
    init(login: SavedLogin, auth: Bool = false) {
        self.login = login
        super.init(nibName: nil, bundle: nil)
        
        if auth {
            quickLogin()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if EduLinkAPI.shared.authorisedUser.authToken != nil {
            
        }
    }
    
    private func delegateLoginError(_ error: String) {
        let errorView: ErrorView = .fromNib()
        errorView.text.text = error
        errorView.goBackButton.addTarget(self, action: #selector(self.logout), for: .touchUpInside)
        errorView.retryButton.addTarget(self, action: #selector(self.quickLogin), for: .touchUpInside)
        if let nc = self.navigationController { errorView.startWorking(nc) }
    }
    
    @objc private func quickLogin() {
        if let nc = self.navigationController { self.workingCover.startWorking(nc) }
        LoginManager.shared.quickLogin(self.login, { (success, error) -> Void in
            DispatchQueue.main.async {
                self.workingCover.stopWorking()
                if success {
                    self.menuTableView.reloadData()
                } else {
                    self.delegateLoginError(error!)
                }
            }
        })
    }
    
    @objc private func logout() {
        EduLinkAPI.shared.clear()
        (UIApplication.shared.delegate as! AppDelegate).setRootViewController(CentralisNavigationController(rootViewController: LoginViewController()))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(menuTableView)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: menuTableView.topAnchor),
            view.bottomAnchor.constraint(equalTo: menuTableView.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: menuTableView.leadingAnchor)
        ])
        // Do any additional setup after loading the view.
    }
    
}
