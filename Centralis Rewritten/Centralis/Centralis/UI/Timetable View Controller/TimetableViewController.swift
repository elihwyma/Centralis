//
//  TimetableViewController.swift
//  Centralis
//
//  Created by Amy While on 31/12/2021.
//

import UIKit

class TimetableViewController: BaseTableViewController {
    
    public var weeks = Timetable.orderWeeks(PersistenceDatabase.shared.timetable)
    public lazy var days = [Timetable.Day]()

    override func viewDidLoad() {
        super.viewDidLoad()
    
        tableView.register(PeriodCell.self, forCellReuseIdentifier: "Centralis.PeriodCell")
        
        index(false)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Choose Week", style: .done, target: self, action: #selector(changeWeek))
        NotificationCenter.default.addObserver(self, selector: #selector(persistenceReload), name: PersistenceDatabase.persistenceReload, object: nil)
    }
    
    private func index(_ reload: Bool = true) {
        let weeks = PersistenceDatabase.shared.timetable
        self.weeks = Timetable.orderWeeks(weeks)
        if let (week, _) = Timetable.getCurrent(weeks) {
            if title != week.name {
                self.title = week.name
            }
            select(week: week)
        }
    }
    
    @objc private func persistenceReload() {
        if !Thread.isMainThread {
            DispatchQueue.main.async { [weak self] in
                self?.persistenceReload()
            }
            return
        }
        index()
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
