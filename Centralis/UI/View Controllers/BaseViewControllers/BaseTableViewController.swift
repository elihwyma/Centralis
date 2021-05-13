//
//  BaseTableViewController.swift
//  Aemulo
//
//  Created by Andromeda on 09/04/2021.
//

import UIKit

public class BaseTableViewController: UITableViewController {
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
        cell?.backgroundColor = UIColor.clear
        return cell ?? UITableViewCell()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.updateCentralisColours()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateCentralisColours),
                                               name: ThemeManager.ThemeUpdate,
                                               object: nil)
    }
    
    @objc private func updateCentralisColours() {
        self.view.backgroundColor = .centralisViewColor
        self.view.tintColor = .centralisTintColor
        self.tableView.reloadData()
    }
}
