//
//  BaseTableViewController.swift
//  Aemulo
//
//  Created by Andromeda on 09/04/2021.
//

import UIKit

class BaseTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = .backgroundColor
        NotificationCenter.default.addObserver(self.tableView!,
                                               selector: #selector(tableView.reloadData),
                                               name: ThemeManager.ThemeUpdate,
                                               object: nil)
    }
    func reusableCell(withStyle style: UITableViewCell.CellStyle, reuseIdentifier: String) -> UITableViewCell {
        self.reusableCell(withStyle: style, reuseIdentifier: reuseIdentifier, cellClass: UITableViewCell.self)
    }

    func reusableCell(withStyle style: UITableViewCell.CellStyle, reuseIdentifier: String, cellClass: AnyClass) -> UITableViewCell {
        var cell: UITableViewCell? = self.tableView.dequeueReusableCell(withIdentifier: reuseIdentifier)
        if cell == nil {
            let myClass = cellClass as? UITableViewCell.Type ?? UITableViewCell.self
            cell = myClass.init(style: style, reuseIdentifier: reuseIdentifier)
            cell?.selectionStyle = UITableViewCell.SelectionStyle.gray
        }
        cell?.backgroundColor = .backgroundColor
        return cell ?? UITableViewCell()
    }
}
