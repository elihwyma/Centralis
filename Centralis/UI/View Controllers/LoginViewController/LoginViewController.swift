//
//  LoginViewController.swift
//  Centralis
//
//  Created by AW on 28/11/2020.
//

import UIKit
//import libCentralis

class LoginViewController: BaseTableViewController {
    
    var containerView = UIView()
    var logins = [SavedLogin]()
    var workingCover: WorkingCover = .fromNib()
    
    init() {
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        EduLinkAPI.shared.defaults.removeObject(forKey: "SavedLogin")
        EduLinkAPI.shared.defaults.removeObject(forKey: "SavedLogins")
        title = "Centralis"
        organiseLogins()
        tableView.backgroundColor = .centralisViewColor

        tableView.separatorStyle = UITableViewCell.SeparatorStyle.singleLine
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.register(UINib(nibName: "LoginCell", bundle: nil), forCellReuseIdentifier: "Centralis.LoginCell")

        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(LoginViewController.removeLogin))
        tableView.addGestureRecognizer(longPress)

        NotificationCenter.default.addObserver(self, selector: #selector(reauth), name: .ReAuth, object: nil)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "New Login", style: .done, target: self, action: #selector(newLoggin))
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.organiseLogins()
        self.tableView.reloadData()
    }

    private func organiseLogins() {
        self.logins.removeAll()
        let decoder = JSONDecoder()
        let l = EduLinkAPI.shared.defaults.object(forKey: "LoginCache") as? [Data] ?? [Data]()
        for login in l {
            if let a = try? decoder.decode(SavedLogin.self, from: login) {
                self.logins.append(a)
            }
        }
    }

    @objc func newLoggin() {
        let nav = CentralisNavigationController(rootViewController: NewUserSchoolController(nibName: nil, bundle: nil))
        self.present(nav, animated: true)
    }
    
    @objc func removeLogin(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        if longPressGestureRecognizer.state == UIGestureRecognizer.State.began {
            let touchPoint = longPressGestureRecognizer.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                let login = self.logins[indexPath.row]
                let alert = UIAlertController(title: "Remove Login", message: "Do you want to delete the login for \(login.forename) at \(login.schoolName)?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { [weak self] action in
                    guard let `self` = self else { return }
                    self.logins.remove(at: indexPath.row)
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
                    LoginManager.shared.removeLogin(login: login)
                }))
                alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
                self.present(alert, animated: true)
            }
        }
    }
    
    @objc private func reauth() {
        DispatchQueue.main.async {
            self.workingCover.startWorking(self)
            if !LoginManager.shared.username.isEmpty {
                //LoginManager.shared.login()
            }
        }
    }
    
    var magicIndex = 0
    private func showError(_ error: String) {
        let errorView: ErrorView = .fromNib()
        errorView.text.text = error
        errorView.retryButton.addTarget(self, action: #selector(self.loginAtIndex), for: .touchUpInside)
        errorView.startWorking(self)
    }
    
    @objc private func loginAtIndex() {
        self.workingCover.startWorking(self)
        let login = self.logins[magicIndex]
        LoginManager.shared.quickLogin(login, { (success, error) -> Void in
            DispatchQueue.main.async {
                self.workingCover.stopWorking()
                if success {
                    EduLinkAPI.shared.defaults.setValue(login.username, forKey: "PreferredUsername")
                    EduLinkAPI.shared.defaults.setValue(login.schoolCode, forKey: "PreferredSchool")
                    (UIApplication.shared.delegate as! AppDelegate).setRootViewController(CentralisNavigationController(rootViewController: BaseViewController(login: login)))
                } else {
                    self.showError(error!)
                }
            }
        })
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.magicIndex = indexPath.row
        self.loginAtIndex()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        logins.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Centralis.LoginCell", for: indexPath) as! LoginCell
        let savedLogin = self.logins[indexPath.row]
        if let data = savedLogin.image,
           let image = UIImage(data: data) {
            cell.schoolLogo.image = image
        }
        cell.forename.text = "\(savedLogin.forename) \(savedLogin.surname)"
        cell.schoolName.text = savedLogin.schoolName
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 15
        cell.backgroundColor = .centralisBackgroundColor
        return cell
    }
}
