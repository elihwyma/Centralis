//
//  SettingsViewController.swift
//  Centralis
//
//  Created by Andromeda on 14/03/2021.
//

import UIKit

class SettingsViewController: BaseTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let pop = UIBarButtonItem(title: "Back", style: .done, target: self, action: #selector(self.pop))
        self.navigationItem.leftBarButtonItem = pop
    }

    @objc private func pop() {
        self.dismiss(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            switch indexPath.row {
            case 0:
                let config = UIColorPickerViewController()
                config.selectedColor = .centralisTintColor
                config.supportsAlpha = false
                config.delegate = self
                self.navigationController?.present(config, animated: true, completion: nil)
            case 1:
                ThemeManager.setTintColor(nil)
            default: break
            }
        case 2:
            switch indexPath.row {
            case 0:
                EduLinkAPI.shared.clear()
                let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                viewController.modalPresentationStyle = .fullScreen
                self.present(viewController, animated: true)
            default: break
            }
        default: break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 2
        case 1: return 2
        case 2: return 1
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = SettingsSwitchTableViewCell()
            switch indexPath.row {
            case 0:
                cell.amyPogLabel.text = "New Homework"
                cell.fallback = true
                cell.defaultKey = "HomeworkChanges"
            case 1:
                cell.amyPogLabel.text = "Room Changes"
                cell.fallback = true
                cell.defaultKey = "RoomChanges"
            default: fatalError("Error")
            }
            return cell
        case 1:
            switch indexPath.row {
            case 0:
                return TintColorPicker()
            case 1:
                let cell = self.reusableCell(withStyle: .default, reuseIdentifier: "DefaultCell")
                cell.textLabel?.textColor = .centralisTintColor
                cell.backgroundColor = .centralisBackgroundColor
                cell.textLabel?.text = "Reset Tint Color"
                return cell
            default: fatalError("Trying to present \(indexPath.section) \(indexPath.row)")
            }
        case 2:
            let cell = self.reusableCell(withStyle: .default, reuseIdentifier: "DefaultCell")
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Logout"
                cell.textLabel?.textColor = .systemRed
                cell.backgroundColor = .centralisBackgroundColor
            default: fatalError("Error")
            }
            return cell
        default: fatalError("Error")
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Notifcations"
        case 1: return "Theme"
        case 2: return "Account"
        default: return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0: return "Notifications require background refresh is active in Settings"
        default: return nil
        }
    }
}

extension SettingsViewController: UIColorPickerViewControllerDelegate {
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        ThemeManager.setTintColor(viewController.selectedColor)
    }
}
