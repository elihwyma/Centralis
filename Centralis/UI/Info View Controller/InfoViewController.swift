//
//  InfoViewController.swift
//  Centralis
//
//  Created by Andromeda on 05/12/2021.
//

import UIKit
import Evander

class InfoViewController: BaseTableViewController {
    
    private enum Section {
        case notifications
        case account
        case message
        case theme
    }
    
    private func _section(for section: Int) -> Section {
        switch section {
        case 0: return .notifications
        case 1: return .theme
        case 2: return .message
        case 3: return .account
        default: fatalError()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(ClosureSwitchTableViewCell.self, forCellReuseIdentifier: "Centralis.ClosureSwitchTableViewCell")
        tableView.register(SettingsSwitchTableViewCell.self, forCellReuseIdentifier: "Centralis.SettingsSwitchTableViewCell")
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch _section(for: section) {
        case .notifications: return 3
        case .theme: return 1
        case .account: return 1
        case .message: return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch _section(for: indexPath.section) {
        case .notifications:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Centralis.ClosureSwitchTableViewCell") as! ClosureSwitchTableViewCell
            switch indexPath.row {
            case 0:
                cell.amyPogLabel.text = "Homework"
                cell.control.isOn = UserDefaults.standard.optionalBool("Notifications.Homework", fallback: true)
                cell.callback = { state in
                    UserDefaults.standard.set(state, forKey: "Notifications.Homework")
                    if !state {
                        NotificationManager.shared.deleteAllHomework()
                    } else {
                        NotificationManager.shared.scheduleAllHomework()
                    }
                }
            case 1:
                cell.amyPogLabel.text = "Room Changes"
                cell.control.isOn = UserDefaults.standard.optionalBool("Notifications.RoomChange", fallback: true)
                cell.callback = { state in
                    UserDefaults.standard.set(state, forKey: "Notifications.RoomChange")
                    if !state {
                        NotificationManager.shared.deleteAllRoomChange()
                    }
                }
            case 2:
                cell.amyPogLabel.text = "New Messages"
                cell.control.isOn = UserDefaults.standard.optionalBool("Notifications.NewMessages", fallback: true)
                cell.callback = { state in
                    UserDefaults.standard.set(state, forKey: "Notifications.NewMessages")
                }
            default: fatalError()
            }
            return cell
        case .account:
            let cell = self.reusableCell(withStyle: .default, reuseIdentifier: "Centralis.DefaultCell")
            cell.textLabel?.text = "Sign Out"
            cell.accessoryType = .disclosureIndicator
            return cell
        case .message:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Centralis.SettingsSwitchTableViewCell") as! SettingsSwitchTableViewCell
            switch indexPath.row {
            case 0:
                cell.amyPogLabel.text = "Archive Old Messages"
                cell.defaultKey = "Messages.AutoArchive"
                return cell
            default: fatalError()
            }
        case .theme:
            let cell = self.reusableCell(withStyle: .default, reuseIdentifier: "Centralis.DefaultCell")
            cell.textLabel?.text = "Theme Settings"
            cell.accessoryType = .disclosureIndicator
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch _section(for: section) {
        case .notifications: return "Notification Settings"
        case .account: return "Account"
        case .message: return "Message Settings"
        case .theme: return "Theme"
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch _section(for: indexPath.section) {
        case .account:
            switch indexPath.row {
            case 0:
                EdulinkManager.shared.signout()
                (UIApplication.shared.delegate as! AppDelegate).setRootViewController(CentralisNavigationController(rootViewController: OnboardingViewController()))
                CentralisTabBarController.shared.selectedIndex = 0
            default: return
            }
        case .theme:
            navigationController?.pushViewController(ThemeViewController(style: .insetGrouped), animated: true)
        default: return
        }
    }
    
}
