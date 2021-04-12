//
//  SettingsViewController.swift
//  Centralis
//
//  Created by Andromeda on 14/03/2021.
//

import UIKit

class SettingsViewController: BaseTableViewController {

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

    
    override func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 2
        case 1: return 1
        default: fatalError("fuck")
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
            default: fatalError("Quite frankly how the fuck has this happened")
        }
            
        //cell.backgroundColor = ThemeManager.imageBackground
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0: return "Notifications require background refresh is active in Settings"
        default: return nil
        }
    }
}
