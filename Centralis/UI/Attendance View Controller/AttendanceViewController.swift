//
//  AttendanceViewController.swift
//  Centralis
//
//  Created by Amy While on 17/05/2022.
//

import UIKit

class AttendanceViewController: CentralisDataViewController {
    
    public var records: [Attendance.Lesson] = [] {
        didSet {
            expanded = [Bool](repeating: false, count: records.count)
        }
    }
    public var expanded: [Bool] = [Bool]()
    
    public var selectedMonth: Attendance.Lesson?
    
    enum State {
        case lesson
        case statutoryMonth
        case statutoryYear
        
        var title: String {
            switch self {
            case .lesson: return "Lesson Attendance"
            case .statutoryMonth: return "Statutory Month"
            case .statutoryYear: return "Statutory Year"
            }
        }
    }
    
    public var state: State = .lesson {
        didSet {
            title = state.title
            if state != .statutoryMonth {
                selectedMonth = nil
            }
            
            switch state {
            case .lesson: navigationItem.rightBarButtonItem?.title = "Lessons"
            case .statutoryMonth: navigationItem.rightBarButtonItem?.title = selectedMonth?.lesson
            case .statutoryYear: navigationItem.rightBarButtonItem?.title = "Year"
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        state = .lesson
        records = PersistenceDatabase.shared.attendance.lesson
        tableView.register(AttendanceViewCell.self, forCellReuseIdentifier: "Centralis.AttendanceCell")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Lessons", style: .plain, target: self, action: #selector(changeState(_:)))
    }
    
    @objc private func changeState(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if let popoverController = alert.popoverPresentationController {
           popoverController.barButtonItem = sender as? UIBarButtonItem
        }
        
        alert.addAction(UIAlertAction(title: "Lesson Attendance", style: .default, handler: { [weak self] _ in
            self?.state = .lesson
            self?.index()
        }))
        alert.addAction(UIAlertAction(title: "Statutory Year", style: .default, handler: { [weak self] _ in
            self?.state = .statutoryYear
            self?.index()
        }))
        
        for month in PersistenceDatabase.shared.attendance.statutory {
            alert.addAction(UIAlertAction(title: month.lesson, style: .default, handler: { [weak self] _ in
                self?.state = .statutoryMonth
                self?.selectedMonth = month
                self?.index()
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alert, animated: true)
    }
    
    override public func index(_ reload: Bool = true) {
        if reload {
            //tableView.beginUpdates()
        }
        records = PersistenceDatabase.shared.attendance.lesson
        if reload {
            tableView.reloadData()
        }
        
        if reload {
            //tableView.endUpdates()
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        records.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1 + (expanded[section] ? records[section].exceptions.count : 0)
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Centralis.AttendanceCell", for: indexPath) as! AttendanceViewCell
            cell.setRecord(record: records[indexPath.section])
            return cell
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
