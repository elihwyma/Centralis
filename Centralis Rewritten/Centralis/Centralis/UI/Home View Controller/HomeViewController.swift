//
//  HomeViewController.swift
//  Centralis
//
//  Created by Andromeda on 26/11/2021.
//

import UIKit

class HomeViewController: BaseTableViewController {
    
    public var homework = [Homework]()
    public var today: Timetable.Day?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(HomeworkCell.self, forCellReuseIdentifier: "Centralis.HomeworkCell")
        tableView.register(PeriodCell.self, forCellReuseIdentifier: "Centralis.PeriodCell")
        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(persistenceReload), name: PersistenceDatabase.persistenceReload, object: nil)
    }
    
    private func index(_ reload: Bool = true) {
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
            tableView.endUpdates()
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
        switch section {
        case 0: return homework.count + 1
        case 1: return (today?.periods.count ?? 0) + 1
        case 2: return 1
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Current Homework"
        case 1: return "\(today?.name ?? "Today")'s Lessons"
        case 2: return "More"
        default: return nil
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
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
        case 1:
            if indexPath.row == (today?.periods.count ?? 0) {
                let cell = self.reusableCell(withStyle: .default, reuseIdentifier: "Centralis.DefaultCell")
                cell.accessoryType = .disclosureIndicator
                cell.textLabel?.text = "See all lessons"
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "Centralis.PeriodCell", for: indexPath) as! PeriodCell
            cell.set(period: today!.periods[indexPath.row])
            return cell
        case 2:
            switch indexPath.row {
            case 0:
                let cell = self.reusableCell(withStyle: .default, reuseIdentifier: "Centralis.DefaultCell")
                cell.accessoryType = .disclosureIndicator
                cell.textLabel?.text = "Documents"
                return cell
            default: return UITableViewCell()
            }
        default: return UITableViewCell()
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let homeworkCell = tableView.cellForRow(at: indexPath) as? HomeworkCell {
            tableView.beginUpdates()
            homeworkCell.toggleDescription()
            tableView.endUpdates()
        } else if indexPath.section == 0 && indexPath.row == homework.count {
            navigationController?.pushViewController(HomeworkViewController(style: .insetGrouped), animated: true)
        } else if indexPath.section == 1 && indexPath.row == (today?.periods.count ?? 0) {
            navigationController?.pushViewController(TimetableViewController(style: .insetGrouped), animated: true)
        } else if indexPath.section == 2 {
            switch indexPath.row {
            case 0:
                navigationController?.pushViewController(DocumentsViewController(style: .insetGrouped), animated: true)
            default: return
            }
        }
    }
}
