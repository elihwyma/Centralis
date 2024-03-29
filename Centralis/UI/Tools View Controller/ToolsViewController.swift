//
//  ToolsViewController.swift
//  Centralis
//
//  Created by Amy While on 27/08/2022.
//

import UIKit

class ToolsViewController: BaseTableViewController {
    
    private enum Section {
        case mymaths
        case photos
        case studentid
        
        var title: String? {
            switch self {
            case .mymaths: return "MyMaths Haxx"
            case .photos: return "EduLink Photos"
            case .studentid: return "Student ID"
            }
        }
        
        var footer: String? {
            switch self {
            case .studentid: return "This can be used to generate a \"fake\" student ID. This is enough to get a student discount in most stores and prove your definitely real age"
            default: return nil
            }
        }
    }
    
    private func _section(for section: Int) -> Section {
        switch section {
        case 0: return .mymaths
        case 1: return .photos
        case 2: return .studentid
        default: fatalError()
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch _section(for: section) {
        case .mymaths: return 1
        case .photos: return 1
        case .studentid: return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        _section(for: section).title
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        _section(for: section).footer
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch _section(for: indexPath.section) {
        case .mymaths:
            let cell = self.reusableCell(withStyle: .default, reuseIdentifier: "Centralis.DefaultCell")
            cell.textLabel?.text = "MyMaths"
            cell.accessoryType = .disclosureIndicator
            return cell
        case .photos:
            let cell = self.reusableCell(withStyle: .default, reuseIdentifier: "Centralis.DefaultCell")
            cell.accessoryType = .disclosureIndicator
            switch indexPath.row {
            case 0: cell.textLabel?.text = "Teacher Photos"
            default: fatalError()
            }
            return cell
        case .studentid:
            let cell = self.reusableCell(withStyle: .default, reuseIdentifier: "Centralis.DefaultCell")
            cell.textLabel?.text = "Student ID"
            cell.accessoryType = .disclosureIndicator
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch _section(for: indexPath.section) {
        case .mymaths:
            navigationController?.pushViewController(MyMathsLoginViewController(nibName: nil, bundle: nil), animated: true)
        case .photos:
            switch indexPath.row {
            case 0:
                navigationController?.pushViewController(TeacherPictureDumperController(collectionViewLayout: UICollectionViewFlowLayout()), animated: true)
            default: return
            }
        case .studentid:
            navigationController?.pushViewController(StudentIDCreator(nibName: nil, bundle: nil), animated: true)
        }
    }

}
