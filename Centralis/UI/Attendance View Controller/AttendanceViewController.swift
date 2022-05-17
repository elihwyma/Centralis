//
//  AttendanceViewController.swift
//  Centralis
//
//  Created by Amy While on 17/05/2022.
//

import UIKit

class AttendanceViewController: BaseTableViewController {
    
    public var records: [Attendance.Lesson] = [] {
        didSet {
            expanded = [Bool](repeating: false, count: records.count)
        }
    }
    public var expanded: [Bool] = [Bool]()
    
    enum State {
        case lesson
        case statutory
        
        var title: String {
            switch self {
            case .lesson: return "Lesson Attendance"
            case .statutory: return "Statutory Attendance"
            }
        }
    }
    
    public var state: State = .lesson {
        didSet {
            title = state.title
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        state = .lesson
        records = PersistenceDatabase.shared.attendance.lesson
        print(records)
        tableView.register(AttendanceViewCell.self, forCellReuseIdentifier: "Centralis.AttendanceCell")
        NotificationCenter.default.addObserver(self, selector: #selector(persistenceReload), name: PersistenceDatabase.persistenceReload, object: nil)
    }
    
    private func index(_ reload: Bool = true) {
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
    
    @objc private func persistenceReload() {
        if !Thread.isMainThread {
            DispatchQueue.main.async { [weak self] in
                self?.persistenceReload()
            }
            return
        }
        index()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        index()
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
