//
//  HomeworkViewController.swift
//  Centralis
//
//  Created by Andromeda on 05/12/2021.
//

import UIKit

class HomeworkViewController: BaseTableViewController {
    
    public var currentHomework = [Homework]()
    public var pastHomework = [Homework]()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(HomeworkCell.self, forCellReuseIdentifier: "Centralis.HomeworkCell")
        let homework = PersistenceDatabase.shared.homework.map { $0.1 }
        currentHomework = homework.filter { $0.isCurrent }
        currentHomework.sort { one, two -> Bool in
            if let one = one.due_date,
               let two = two.due_date {
                return one < two
            }
            return false
        }
        
        pastHomework = homework.filter { !$0.isCurrent }
        pastHomework.sort { one, two -> Bool in
            if let one = one.due_date,
               let two = two.due_date {
                return one > two
            }
            return false
        }
        self.title = "Homework"
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? currentHomework.count : pastHomework.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let homeworkCell = tableView.cellForRow(at: indexPath) as? HomeworkCell {
            tableView.beginUpdates()
            homeworkCell.toggleDescription()
            tableView.endUpdates()
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Centralis.HomeworkCell", for: indexPath) as! HomeworkCell
        cell.delegate = self
        cell.set(homework: indexPath.section == 0 ? currentHomework[indexPath.row] : pastHomework[indexPath.row])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "Current Homework" : "Past Homework"
    }

}
