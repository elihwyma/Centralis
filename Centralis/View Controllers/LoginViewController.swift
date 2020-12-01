//
//  LoginViewController.swift
//  Centralis
//
//  Created by Amy While on 28/11/2020.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var dynamicColourView: DynamicColourView!
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
        self.dynamicColourView.setup()
        self.newLoggin.layer.masksToBounds = true
        self.newLoggin.layer.borderColor = UIColor.label.cgColor
        self.newLoggin.layer.borderWidth = 2
        self.newLoggin.layer.cornerRadius = 15
    
        //Make it transparent
        self.tableView.backgroundColor = .none
        //Removes cells that don't exist
        self.tableView.tableFooterView = UIView()
        //Disable the seperator lines, make it look nice :)
        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        //Disable the scroll indicators
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.showsHorizontalScrollIndicator = false
        //Register the cell from nib
        self.tableView.register(UINib(nibName: "LoginCell", bundle: nil), forCellReuseIdentifier: "Centralis.LoginCell")
        //Set the delegate/source
        self.tableView.delegate = self
        self.tableView.dataSource = self
        //Bouncy Boi
        self.tableView.alwaysBounceVertical = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(hidePopup), name: .HidePopup, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(goHome), name: .SuccesfulLogin, object: nil)
    }
    
    private func organiseLogins() {
        let decoder = JSONDecoder()
        let l = UserDefaults.standard.object(forKey: "SavedLogins") as? [Data] ?? [Data]()
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
}


extension LoginViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.startWorking()
        let login = self.logins[indexPath.row]
        EduLinkAPI.shared.login(schoolCode: login.schoolCode!, username: login.username!, password: login.password!)
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
        cell.forename.text = savedLogin.forename
        cell.schoolName.text = savedLogin.schoolName
        return cell
    }
}
