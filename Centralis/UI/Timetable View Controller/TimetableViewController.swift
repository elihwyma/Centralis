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
    private var selectedName: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        emptyLabel.text = "No Lessons This Week 🎉"
        tableView.register(PeriodCell.self, forCellReuseIdentifier: "Centralis.PeriodCell")
        
        index(false)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Choose Week", style: .done, target: self, action: #selector(changeWeek))
        NotificationCenter.default.addObserver(self, selector: #selector(persistenceReload), name: PersistenceDatabase.persistenceReload, object: nil)
    }
    
    private func index(_ reload: Bool = true) {
        let weeks = PersistenceDatabase.shared.timetable
        self.weeks = Timetable.orderWeeks(weeks)
        if let selectedName = selectedName,
           let selectedWeek = self.weeks.first(where: { $0.name == selectedName }) {
            select(week: selectedWeek)
        } else if let (week, _) = Timetable.getCurrent(weeks) {
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
        //tableView.beginUpdates()
        //let originalDays = days
        //let originalCount = tableView.numberOfSections
        days = week.days
        days.removeAll { $0.periods.count == 0 }
        emptyLabel.isHidden = !days.isEmpty
        
        /*
        let newCount = days.count
        func addCells(bounding: Int) {
            for k in 0...bounding {
                let originalCount = originalDays[safe: k]?.periods.count ?? 0
                let newCount = week.days[safe: k]?.periods.count ?? 0
                if originalCount == newCount { continue }
                
                var rows = [IndexPath]()
                if originalCount > newCount {
                    for i in newCount..<originalCount {
                        rows.append(IndexPath(row: i, section: k))
                    }
                    tableView.deleteRows(at: rows, with: .automatic)
                } else {
                    for i in originalCount..<newCount {
                        rows.append(IndexPath(row: i, section: k))
                    }
                    tableView.insertRows(at: rows, with: .automatic)
                }
            }
        }
        addCells(bounding: newCount)
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
        tableView.endUpdates()
         */
        tableView.reloadData()
        title = week.name
    }
    
    @objc public func changeWeek() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.popoverPresentationController?.sourceView = self.view
        for week in weeks {
            alert.addAction(UIAlertAction(title: week.name, style: .default, handler: { [weak self] _ in
                guard let self = self else { return }
                self.selectedName = week.name
                self.select(week: week)
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { [weak self] _ in
            self?.dismiss(animated: true)
        }))
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

extension Collection {
    subscript (safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
