//
//  MyMathsTaskList.swift
//  Centralis
//
//  Created by Amy While on 11/03/2022.
//

import UIKit

protocol TaskListDelegate: AnyObject {
    func complete(task: MyMaths.PastTasks)
}

class MyMathsTaskList: BaseTableViewController {
    
    private var currentTasks: [MyMaths.CurrentTasks]
    private var pastTasks: [MyMaths.PastTasks]
    private var selectedTasks: [[Int]] = [[], []]
    
    init(currentTasks: [MyMaths.CurrentTasks], pastTasks: [MyMaths.PastTasks]) {
        self.currentTasks = currentTasks
        self.pastTasks = pastTasks.sorted(by: { $0.date > $1.date })
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Tasks"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Confirm", style: .done, target: self, action: #selector(confirm))
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    @objc private func confirm() {
        var tasks = [MyMaths.CurrentTasks]()
        selectedTasks[0].forEach { tasks.append(currentTasks[$0]) }
        selectedTasks[1].forEach { tasks.append(pastTasks[$0]) }
        if tasks.isEmpty { return }
        navigationController?.pushViewController(MyMathsTaskCompletionViewController(tasks: tasks, delegate: self), animated: true)
        selectedTasks[0] = []
        selectedTasks[1] = []
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return currentTasks.isEmpty ? 1 : currentTasks.count
        case 1: return pastTasks.isEmpty ? 1 : pastTasks.count
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Current Tasks"
        case 1: return "Past Tasks"
        default: return nil
        }
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, d MMM y"
        return formatter
    }()

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let isEmpty = indexPath.section == 0 ? currentTasks.isEmpty : pastTasks.isEmpty
        
        if isEmpty {
            let cell = self.reusableCell(withStyle: .default, reuseIdentifier: "MyMaths.NoTasks")
            cell.selectionStyle = .none
            cell.textLabel?.text = "No \(indexPath.section == 0 ? "Current" : "Past") Tasks"
            return cell
        }
        let task: MyMaths.CurrentTasks =  indexPath.section == 0 ? currentTasks[indexPath.row] : pastTasks[indexPath.row]
        let cell = self.reusableCell(withStyle: indexPath.section == 0 ? .default : .subtitle, reuseIdentifier: indexPath.section == 0 ? "MyMaths.Current" : "MyMaths.Past")
        cell.textLabel?.text = task.name
        if let pastTask = task as? MyMaths.PastTasks {
            cell.detailTextLabel?.text = "\(pastTask.percent)% - \(dateFormatter.string(from: pastTask.date))"
        }
        cell.accessoryType = selectedTasks[indexPath.section].contains(indexPath.row) ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard !(indexPath.section == 0 ? currentTasks.isEmpty : pastTasks.isEmpty),
              let cell = tableView.cellForRow(at: indexPath) else { return }
        if let index = selectedTasks[indexPath.section].firstIndex(of: indexPath.row) {
            selectedTasks[indexPath.section].remove(at: index)
            cell.accessoryType = .none
        } else {
            selectedTasks[indexPath.section].append(indexPath.row)
            cell.accessoryType = .checkmark
        }
    }
    
}

extension MyMathsTaskList: TaskListDelegate {
    
    func complete(task: MyMaths.PastTasks) {
        tableView.beginUpdates()
        if let index = currentTasks.firstIndex(where: { $0 == task }) {
            currentTasks.remove(at: index)
            if currentTasks.isEmpty {
                tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            } else {
                tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            }
            pastTasks.insert(task, at: 0)
            tableView.insertRows(at: [IndexPath(row: 0, section: 1)], with: .automatic)
        } else {
            if let pastIndex = pastTasks.firstIndex(where: { $0 == task }) {
                pastTasks.remove(at: pastIndex)
                pastTasks.insert(task, at: 0)
                tableView.deleteRows(at: [IndexPath(row: pastIndex, section: 1)], with: .automatic)
                tableView.insertRows(at: [IndexPath(row: 0, section: 1)], with: .automatic)
            } else {
                pastTasks.insert(task, at: 0)
                tableView.insertRows(at: [IndexPath(row: 0, section: 1)], with: .automatic)
            }
        }
        tableView.endUpdates()
    }
    
}
