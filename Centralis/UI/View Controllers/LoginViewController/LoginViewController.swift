//
//  LoginViewController.swift
//  Centralis
//
//  Created by AW on 28/11/2020.
//

import UIKit
//import libCentralis

class LoginViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: ResizedTableView!
    @IBOutlet weak var newLoggin: UIButton!
    
    var containerView = UIView()
    var logins = [SavedLogin]()
    var workingCover: WorkingCover = .fromNib()
    var magicIndex = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.organiseLogins()
        self.tableView.reloadData()
    }
    
    private func setup() {
        EduLinkAPI.shared.defaults.removeObject(forKey: "SavedLogin")
        EduLinkAPI.shared.defaults.removeObject(forKey: "SavedLogins")
        self.organiseLogins()
        self.newLoggin.layer.masksToBounds = true
        self.newLoggin.layer.borderColor = UIColor.label.cgColor
        self.newLoggin.layer.borderWidth = 2
        self.newLoggin.layer.cornerRadius = 15
        self.tableView.backgroundColor = .systemGray5
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.singleLine
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.showsHorizontalScrollIndicator = false
        self.tableView.register(UINib(nibName: "LoginCell", bundle: nil), forCellReuseIdentifier: "Centralis.LoginCell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.alwaysBounceVertical = false
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(LoginViewController.removeLogin))
        self.tableView.addGestureRecognizer(longPress)
        self.tableView.layer.masksToBounds = true
        self.tableView.layer.cornerRadius = 15
        
        NotificationCenter.default.addObserver(self, selector: #selector(reauth), name: .ReAuth, object: nil)
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

    @IBAction func newLoggin(_ sender: Any) {
        self.performSegue(withIdentifier: "Centralis.ShowNewUser", sender: nil)
    }
    
    @objc func removeLogin(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        if longPressGestureRecognizer.state == UIGestureRecognizer.State.began {
            let touchPoint = longPressGestureRecognizer.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                let login = self.logins[indexPath.row]
                let alert = UIAlertController(title: "Remove Login", message: "Do you want to delete the login for \(login.forename!) at \(login.schoolName!)?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { action in
                    LoginManager.shared.removeLogin(login: login)
                    self.organiseLogins()
                    self.tableView.reloadData()
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
    
    private func showError(_ error: String) {
        let errorView: ErrorView = .fromNib()
        errorView.text.text = error
        errorView.retryButton.addTarget(self, action: #selector(self.loginAtIndex), for: .touchUpInside)
        errorView.startWorking(self)
    }
    
    @objc private func loginAtIndex() {
        self.workingCover.startWorking(self)
        let login = self.logins[self.magicIndex]
        LoginManager.shared.quickLogin(login, { (success, error) -> Void in
            DispatchQueue.main.async {
                self.workingCover.stopWorking()
                if success {
                    EduLinkAPI.shared.defaults.setValue(login.username, forKey: "PreferredUsername")
                    EduLinkAPI.shared.defaults.setValue(login.schoolCode, forKey: "PreferredSchool")
                    self.performSegue(withIdentifier: "Centralis.Login", sender: nil)
                } else {
                    self.showError(error!)
                }
            }
        })
    }
}


extension LoginViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.magicIndex = indexPath.row
        self.loginAtIndex()
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension LoginViewController : UITableViewDataSource {
    
    //This is just meant to be
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.logins.count
    }

    //This is what handles all the images and text etc, using the class mainScreenTableCells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Centralis.LoginCell", for: indexPath) as! LoginCell
        let savedLogin = self.logins[indexPath.row]
        if let image = UIImage(data: savedLogin.image) {
            cell.schoolLogo.image = image
        }
        cell.forename.text = "\(savedLogin.forename!) \(savedLogin.surname!)"
        cell.schoolName.text = savedLogin.schoolName
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 15
        return cell
    }
}
