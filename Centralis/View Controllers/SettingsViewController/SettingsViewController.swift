//
//  SettingsViewController.swift
//  Centralis
//
//  Created by Andromeda on 14/03/2021.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var toShow: [[AmyCellData]] = [
        [
            AmyCellData(identifier: .Notification, data: NotificationSwitchData(defaultName: "HomeworkChanges", title: "New Homework", defaultState: true)),
            AmyCellData(identifier: .Notification, data: NotificationSwitchData(defaultName: "RoomChanges", title: "Room Changes", defaultState: true))
        ],
        [
            AmyCellData(identifier: .Button, data: ButtonCellData(title: "Logout", notificationName: "Settings.Logout"))
        ]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UINib(nibName: "ButtonCell", bundle: nil), forCellReuseIdentifier: "libAmy.ButtonCell")
        self.tableView.register(UINib(nibName: "SettingsSwitchCell", bundle: nil), forCellReuseIdentifier: "libAmy.SettingsSwitchCell")
        self.tableView.register(UINib(nibName: "NotificationSwitchCell", bundle: nil), forCellReuseIdentifier: "libAmy.NotificationSwitchCell")
        //self.tableView.register(UINib(nibName: "SocialCell", bundle: nil), forCellReuseIdentifier: "libAmy.SocialCell")
        //self.tableView.register(UINib(nibName: "AppIconCell", bundle: nil), forCellReuseIdentifier: "libAmy.AppIconCell")
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.layer.cornerRadius = 10
        self.tableView.layer.masksToBounds = true
        self.tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = .clear
        self.tableView.layer.masksToBounds = true
        self.tableView.layer.cornerRadius = 10
        // Do any additional setup after loading the view.
        let pop = UIBarButtonItem(title: "Back", style: .done, target: self, action: #selector(self.pop))
        self.navigationItem.leftBarButtonItem = pop
        
        NotificationCenter.default.addObserver(forName: .SettingsSignOut, object: nil, queue: nil) { notification in
            EduLinkAPI.shared.clear()
            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            viewController.modalPresentationStyle = .fullScreen
            self.present(viewController, animated: true)
        }
    }
    
    @objc private func pop() {
        self.dismiss(animated: true)
    }
}

extension SettingsViewController: UITableViewDelegate {}

extension SettingsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int { self.toShow.count }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { self.toShow[section].count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let id = self.toShow[indexPath.section][indexPath.row]
        var cell: AmyCell!
        switch id.identifier {
            case .Switch: do {
                let b = tableView.dequeueReusableCell(withIdentifier: "libAmy.SettingsSwitchCell", for: indexPath) as! SettingsSwitchCell
                b.data = id.data as? SettingsSwitchData
                cell = b
            }
            case .Notification: do {
                let b = tableView.dequeueReusableCell(withIdentifier: "libAmy.NotificationSwitchCell", for: indexPath) as! NotificationSwitchCell
                b.data = id.data as? NotificationSwitchData
                b.data.vc = self
                cell = b
            }
            case .Button: do {
                let b = tableView.dequeueReusableCell(withIdentifier: "libAmy.ButtonCell", for: indexPath) as! ButtonCell
                b.data = id.data as? ButtonCellData
                if b.data.title == "Logout" {
                    b.label.textColor = .systemRed
                } else {
                    b.label.textColor = .label
                }
                cell = b
            }
            /*
            case .Social: do {
                let b = tableView.dequeueReusableCell(withIdentifier: "libAmy.SocialCell", for: indexPath) as! SocialCell
                b.data = id.data as? SocialCellData
                b.label.textColor = .white
                cell = b
            }
            case .AppIcon: do {
                let b = tableView.dequeueReusableCell(withIdentifier: "libAmy.AppIconCell", for: indexPath) as! AppIconCell
                b.data = id.data as? AppIconCellData
                b.iconName.textColor = .white
                cell = b
            }
            */
            default: fatalError("Quite frankly how the fuck has this happened")
        }
            
        //cell.backgroundColor = ThemeManager.imageBackground
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let vw = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 40))
        let label = UILabel(frame: CGRect(x: 0, y: 10, width: tableView.frame.width, height: 20))
        label.adjustsFontSizeToFitWidth = true
        let boldAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 20, weight: .bold),
        ]
        switch section {
        case 0: label.attributedText = NSAttributedString(string: "Notifications", attributes: boldAttributes)
        case 1: label.attributedText = NSAttributedString(string: "Account", attributes: boldAttributes)
        default: break
        }
        vw.addSubview(label)
        return vw
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            return "Notifications require background refresh is active in Settings"
        } else {
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cornerRadius = 10
        var corners: UIRectCorner = []

        if indexPath.row == 0 {
            corners.update(with: .topLeft)
            corners.update(with: .topRight)
        }

        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            corners.update(with: .bottomLeft)
            corners.update(with: .bottomRight)
        }

        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(roundedRect: cell.bounds,
                                      byRoundingCorners: corners,
                                      cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)).cgPath
        cell.layer.mask = maskLayer
    }
}
