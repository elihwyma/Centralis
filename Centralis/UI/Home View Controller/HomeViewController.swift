//
//  HomeViewController.swift
//  Centralis
//
//  Created by Andromeda on 26/11/2021.
//

import UIKit
import Evander

class HomeViewController: BaseTableViewController {
    
    private var currentPermissions: [PermissionManager.Permission] = []
    
    public var homework = [Homework]()
    public var today: Timetable.Day?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(HomeworkCell.self, forCellReuseIdentifier: "Centralis.HomeworkCell")
        tableView.register(PeriodCell.self, forCellReuseIdentifier: "Centralis.PeriodCell")
  
        NotificationCenter.default.addObserver(self, selector: #selector(persistenceReload), name: PersistenceDatabase.persistenceReload, object: nil)
    }
    
    public func iCalendar() {
        let alert = UIAlertController(title: "iCalendar", message: "Loading Calendars", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            
        }))
    }
    
    enum Section {
        case homework
        case timetable
        case other
    }
    
    enum MoreSection {
        case documents
        case links
        case catering
        case icalendar
    }
    
    public var moreCount: Int {
        let document = currentPermissions.contains(.documents)
        let links = currentPermissions.contains(.links)
        let catering = currentPermissions.contains(.catering)
        
        var count = 1
        if document {
            count++
        }
        if links {
            count++
        }
        if catering {
            count++
        }
        return count
    }
    
    public func moreSection(for section: Int) -> MoreSection {
        var sections: [MoreSection] = []
        if currentPermissions.contains(.documents) {
            sections.append(.documents)
        }
        if currentPermissions.contains(.links) {
            sections.append(.links)
        }
        if currentPermissions.contains(.catering) {
            sections.append(.catering)
        }
        sections.append(.icalendar)
        return sections[section]
    }
    
    public var sectionCount: Int {
        let homework = currentPermissions.contains(.homework)
        let timetable = currentPermissions.contains(.timetable)
        let more = currentPermissions.contains(.documents) || currentPermissions.contains(.links) || currentPermissions.contains(.catering)
        
        var count = 0
        if homework {
            count++
        }
        if timetable {
            count++
        }
        if more {
            count++
        }
        return count
    }
    
    public func which(for section: Int) -> Section {
        let homework = currentPermissions.contains(.homework)
        let timetable = currentPermissions.contains(.timetable)
        let more = moreCount != 0
        
        var sections: [Section] = []
        if homework {
            sections.append(.homework)
        }
        if timetable {
            sections.append(.timetable)
        }
        if more {
            sections.append(.other)
        }
        return sections[section]
    }
    
    private func index(_ reload: Bool = true) {
        var reload = reload
        let newCurrentPermissions = PermissionManager.shared.permissions
        let override = newCurrentPermissions != currentPermissions
        currentPermissions = newCurrentPermissions
        if override {
            reload = false
        }
        if reload {
            tableView.beginUpdates()
        }
        var homework = PersistenceDatabase.shared.homework.map { $0.1 }
        homework = homework.filter { $0.isCurrent }
        homework.sort { one, two -> Bool in
            if let one = one.due_date,
               let two = two.due_date {
                return one < two
            }
            return false
        }
        self.homework = homework
        if reload {
            tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        }
        
        let timetable = PersistenceDatabase.shared.timetable
        if let (_, today) = Timetable.getCurrent(timetable) {
            if today != self.today {
                self.today = today
                if reload {
                    tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
                }
            }
        }
        if reload {
            tableView.reloadSections(IndexSet(integer: 2), with: .automatic)
        }
        if reload {
            tableView.endUpdates()
        }
        if override {
            tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        index()
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch which(for: section) {
        case .timetable: return (today?.periods.count ?? 0) + 1
        case .homework: return homework.count + 1
        case .other: return moreCount
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch which(for: section) {
        case .homework: return "Current Homework"
        case .timetable: return "\(today?.name ?? "Today")'s Lessons"
        case .other: return "More"
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        sectionCount
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch which(for: indexPath.section) {
        case .homework:
            if indexPath.row == homework.count {
                let cell = self.reusableCell(withStyle: .default, reuseIdentifier: "Centralis.DefaultCell")
                cell.accessoryType = .disclosureIndicator
                cell.textLabel?.text = "See all homework"
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "Centralis.HomeworkCell", for: indexPath) as! HomeworkCell
            cell.delegate = self
            cell.set(homework: homework[indexPath.row])
            return cell
        case .timetable:
            if indexPath.row == (today?.periods.count ?? 0) {
                let cell = self.reusableCell(withStyle: .default, reuseIdentifier: "Centralis.DefaultCell")
                cell.accessoryType = .disclosureIndicator
                cell.textLabel?.text = "See all lessons"
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "Centralis.PeriodCell", for: indexPath) as! PeriodCell
            cell.set(period: today!.periods[indexPath.row])
            return cell
        case .other:
            let cell = self.reusableCell(withStyle: .default, reuseIdentifier: "Centralis.DefaultCell")
            cell.accessoryType = .disclosureIndicator
            switch moreSection(for: indexPath.row) {
            case .documents:
                cell.textLabel?.text = "Documents"
            case .links:
                cell.textLabel?.text = "Links"
            case .catering:
                cell.textLabel?.text = "Catering - \(PersistenceDatabase.shared.catering.stringBalance)"
            case .icalendar:
                cell.textLabel?.text = "iCalendar"
            }
            return cell
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let section = which(for: indexPath.section)
        if let homeworkCell = tableView.cellForRow(at: indexPath) as? HomeworkCell {
            tableView.beginUpdates()
            homeworkCell.toggleDescription()
            tableView.endUpdates()
        } else if section == .homework && indexPath.row == homework.count {
            navigationController?.pushViewController(HomeworkViewController(style: .insetGrouped), animated: true)
        } else if section == .timetable && indexPath.row == (today?.periods.count ?? 0) {
            navigationController?.pushViewController(TimetableViewController(style: .insetGrouped), animated: true)
        } else if section == .other {
            switch moreSection(for: indexPath.row) {
            case .documents:
                navigationController?.pushViewController(DocumentsViewController(style: .insetGrouped), animated: true)
            case .links:
                navigationController?.pushViewController(LinksViewController(style: .insetGrouped), animated: true)
            case .catering:
                navigationController?.pushViewController(CateringViewController(style: .insetGrouped), animated: true)
            case .icalendar:
                self.iCalendar()
            }
        }
    }
}
