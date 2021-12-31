//
//  TimetableViewController.swift
//  Centralis
//
//  Created by Amy While on 31/12/2021.
//

import UIKit

class TimetableViewController: BaseTableViewController {
    
    public var weeks = PersistenceDatabase.shared.timetable
    public lazy var days = [Timetable.Day]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let first = weeks.first {
            days = first.days
            title = first.name
        }
        tableView.register(PeriodCell.self, forCellReuseIdentifier: "Centralis.PeriodCell")
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Choose Week", style: .done, target: self, action: #selector(changeWeek))
    }
    
    public func select(week: Timetable.Week) {
        if week.days == days { return }
        let originalCount = days.count
        days = week.days
        let newCount = days.count
        if originalCount == newCount {
            tableView.reloadSections(IndexSet(integersIn: 0..<newCount), with: .automatic)
        } else if originalCount > newCount {
            tableView.deleteSections(IndexSet(integersIn: newCount..<originalCount), with: .automatic)
            tableView.reloadSections(IndexSet(integersIn: 0..<newCount), with: .automatic)
        } else if newCount > originalCount {
            let diff = newCount - originalCount
            tableView.insertSections(IndexSet(integersIn: originalCount..<newCount), with: .automatic)
            tableView.reloadSections(IndexSet(integersIn: 0..<diff), with: .automatic)
        }
        title = week.name
    }
    
    @objc public func changeWeek() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.popoverPresentationController?.sourceView = self.view
        for week in weeks {
            alert.addAction(UIAlertAction(title: week.name, style: .default, handler: { [weak self] _ in
                guard let self = self else { return }
                self.select(week: week)
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { [weak self] _ in
            self?.dismiss(animated: true)
        }))
        alert.view.tintColor = .tintColor
        self.present(alert, animated: true)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        days.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        days[section].periods.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        days[section].name
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Centralis.PeriodCell", for: indexPath) as! PeriodCell
        cell.set(period: days[indexPath.section].periods[indexPath.row])
        return cell
    }
    
}
