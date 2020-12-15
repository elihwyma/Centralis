//
//  TimetableTableViewController.swift
//  Centralis
//
//  Created by Amy While on 09/12/2020.
//

import UIKit

enum EmbeddedControllerContext {
    case timetable
    case behaviour
}

class EmbeddedTableViewController: UIView {

    @IBOutlet weak var tableView: UITableView!
    var day: Day?
    var context: EmbeddedControllerContext?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }
    
    private func setup() {
        self.tableView.backgroundColor = .none
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.singleLine
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.showsHorizontalScrollIndicator = false
        self.tableView.register(UINib(nibName: "TextViewCell", bundle: nil), forCellReuseIdentifier: "Centralis.TextViewCell")
        self.tableView.alwaysBounceVertical = false
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
}

extension EmbeddedTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension EmbeddedTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.context {
        case .timetable: do {
            guard let day = day else {
                return 0
            }
            return day.periods.count
        }
        case .behaviour: do {
            return EduLinkAPI.shared.achievementBehaviourLookups.behaviours.count
        }
        default: fatalError("fuck")
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Centralis.TextViewCell", for: indexPath) as! TextViewCell
        let period = day!.periods[indexPath.row]
        cell.timetable(period)
        cell.transactionsView.attributedText = cell.att
        cell.transactionsView.textColor = .label
        return cell
    }
}
