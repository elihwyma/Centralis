//
//  HomeViewController.swift
//  Centralis
//
//  Created by Andromeda on 26/11/2021.
//

import UIKit

class HomeViewController: BaseTableViewController {
    
    public var homework = [Homework]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(HomeworkCell.self, forCellReuseIdentifier: "Centralis.HomeworkCell")
        // Do any additional setup after loading the view.
        
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
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        homework.count + 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "Upcoming Homework"
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == homework.count {
            let cell = self.reusableCell(withStyle: .default, reuseIdentifier: "Centralis.DefaultCell")
            cell.accessoryType = .disclosureIndicator
            cell.textLabel?.text = "See all homework"
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "Centralis.HomeworkCell", for: indexPath) as! HomeworkCell
        cell.set(homework: homework[indexPath.row])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let homeworkCell = tableView.cellForRow(at: indexPath) as? HomeworkCell {
            tableView.beginUpdates()
            homeworkCell.toggleDescription()
            tableView.endUpdates()
        }
    }
}
