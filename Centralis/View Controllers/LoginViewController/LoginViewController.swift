//
//  LoginViewController.swift
//  Centralis
//
//  Created by Amy While on 28/11/2020.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: ResizedTableView!
    @IBOutlet weak var newLoggin: UIButton!
    
    var containerView = UIView()
    var popupView: LoginPopup = .fromNib()
    var logins = [SavedLogin]()
    var workingCover: WorkingCover = .fromNib()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
    }
    
    private func setup() {
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(hidePopup), name: .HidePopup, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(goHome), name: .SuccesfulLogin, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reauth), name: .ReAuth, object: nil)
    }
    
    private func organiseLogins() {
        self.logins.removeAll()
        let decoder = JSONDecoder()
        let l = UserDefaults.standard.object(forKey: "SavedLogin") as? [Data] ?? [Data]()
        for login in l {
            if let a = try? decoder.decode(SavedLogin.self, from: login) {
                self.logins.append(a)
            }
        }
        
    }

    @IBAction func newLoggin(_ sender: Any) {
        self.showPopup()
    }
    
    @objc private func goHome() {
        DispatchQueue.main.async {
            self.stopWorking()
            self.performSegue(withIdentifier: "Centralis.Login", sender: nil)
        }
    }
    
    private func startWorking() {
        self.workingCover.frame = self.view.frame
        self.workingCover.alpha = 0
        self.view.addSubview(workingCover)
        UIView.animate(withDuration: 0.5,
                         delay: 0, usingSpringWithDamping: 1.0,
                         initialSpringVelocity: 1.0,
                         options: .curveEaseInOut, animations: {
                            self.workingCover.alpha = 1
                         }, completion: { (value: Bool) in
          })
    }
    
    private func stopWorking() {
        UIView.animate(withDuration: 0.5,
                         delay: 0, usingSpringWithDamping: 1.0,
                         initialSpringVelocity: 1.0,
                         options: .curveEaseInOut, animations: {
                            self.workingCover.alpha = 0
                         }, completion: { (value: Bool) in
                            self.workingCover.removeFromSuperview()
          })
    }
    
    @objc private func hidePopup() {
        let deadBounds = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: self.view.frame.height)
        
        UIView.animate(withDuration: 1.0,
                         delay: 0, usingSpringWithDamping: 1.0,
                         initialSpringVelocity: 1.0,
                         options: .curveEaseInOut, animations: {
                            self.containerView.alpha = 0
                            self.popupView.frame = deadBounds
                         }, completion: { (value: Bool) in
                            self.popupView.removeFromSuperview()
                            self.containerView.removeFromSuperview()
          })
    }

    private func showPopup() {
        self.containerView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        self.containerView.frame = self.view.frame
        self.containerView.alpha = 0
        self.view.addSubview(containerView)

        let deadBounds = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: self.view.frame.height)
                    
        self.popupView.frame = deadBounds
        self.view.addSubview(popupView)

        UIView.animate(withDuration: 0.5,
                         delay: 0, usingSpringWithDamping: 1.0,
                         initialSpringVelocity: 1.0,
                         options: .curveEaseInOut, animations: {
                            self.containerView.alpha = 0.8
                            self.popupView.frame = self.view.bounds
          }, completion: nil)
    }
    
    @IBAction func logout( _ seg: UIStoryboardSegue) {
        EduLinkAPI.shared.clear()
        self.organiseLogins()
        self.tableView.reloadData()
    }
    
    @objc func removeLogin(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        if longPressGestureRecognizer.state == UIGestureRecognizer.State.began {
            let touchPoint = longPressGestureRecognizer.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                let login = self.logins[indexPath.row]
                let alert = UIAlertController(title: "Remove Login", message: "Do you want to delete the login for \(login.forename!) at \(login.schoolName!)?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { action in
                    let loginManager = LoginManager()
                    loginManager.removeLogin(uwuIn: login)
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
            self.startWorking()
            if !LoginManager.shared.username.isEmpty {
                LoginManager.shared.login()
            }
        }
    }
}


extension LoginViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.startWorking()
        let login = self.logins[indexPath.row]
        EduLinkAPI.shared.quickLogin(login)
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
