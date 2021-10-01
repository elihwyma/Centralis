//
//  BaseViewController.swift
//  Centralis
//
//  Created by Andromeda on 27/08/2021.
//

import UIKit

protocol MenuTableViewDelegate: AnyObject {
    func selectedView(view: UIViewController)
    func selectedView(view: UIView)
    func setTitle(title: String)
}

class BaseViewController: UIViewController {
    
    public var referencedViewController: UIViewController?
    public var displayedView: UIView = TodayView.shared
    public lazy var menuTableView: MenuTableView = {
        let view = MenuTableView()
        view.menuDelegate = self
        return view
    }()
    public var workingCover: WorkingCover = .fromNib()
    public var login: SavedLogin
    private var animateLock = false
    private var expanded = false
    
    public lazy var displayViewLeading = view.leadingAnchor.constraint(equalTo: displayedView.leadingAnchor, constant: -1)
    public lazy var displayViewTrailing = view.trailingAnchor.constraint(equalTo: displayedView.trailingAnchor, constant: -1)
    
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
                    if let todayView = self.displayedView as? TodayView {
                        todayView.dataPull()
                    }
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
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Test", style: .done, target: self, action: #selector(_toggleDisplayMode))
    
        title = "Today"
        setDisplayedView(TodayView.shared, false)
        // Do any additional setup after loading the view.
    }
    
    @objc public func _toggleDisplayMode() {
        toggleDisplayMode(true)
    }
    
    public func toggleDisplayMode(_ animated: Bool = true) {
        guard !animateLock else { return }
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.toggleDisplayMode()
            }
            return
        }
        func changeConstants() {
            if !expanded {
                displayViewLeading.constant = -MenuTableView.width
                displayViewTrailing.constant = -MenuTableView.width
            } else {
                displayViewLeading.constant = 0
                displayViewTrailing.constant = 0
            }
        }
        if !animated {
            animateLock = true
            UIView.animate(withDuration: 0.3) { [self] in
                changeConstants()
                view.layoutIfNeeded()
                displayedView.layoutIfNeeded()
            } completion: { _ in
                self.animateLock = false
                self.expanded = !self.expanded
            }
        } else {
            changeConstants()
            expanded = !expanded
        }
        displayedView.backgroundColor = .systemPink
    }
    
    public func setDisplayedView(_ next: UIView, _ animated: Bool = true) {
        displayedView.removeFromSuperview()
        displayedView = next
        view.addSubview(next)
        displayViewLeading = view.leadingAnchor.constraint(equalTo: displayedView.leadingAnchor, constant: displayViewLeading.constant)
        displayViewTrailing = view.trailingAnchor.constraint(equalTo: displayedView.trailingAnchor, constant: displayViewTrailing.constant)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: next.topAnchor),
            view.bottomAnchor.constraint(equalTo: next.bottomAnchor),
            displayViewLeading,
            displayViewTrailing
        ])
        toggleDisplayMode(animated)
    }
    
}

extension BaseViewController: MenuTableViewDelegate {
    
    func selectedView(view: UIViewController) {
        referencedViewController = view
        setDisplayedView(view.view, true)
    }
    
    func selectedView(view: UIView) {
        referencedViewController = nil
        setDisplayedView(view, true)
    }
    
    func setTitle(title: String) {
        self.title = title
    }
    
}
