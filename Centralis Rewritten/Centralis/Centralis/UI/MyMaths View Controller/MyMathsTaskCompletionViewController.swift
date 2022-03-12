//
//  MyMathsTaskCompletionViewController.swift
//  Centralis
//
//  Created by Amy While on 12/03/2022.
//

import UIKit
import Evander

class MyMathsTaskCompletionViewController: BaseTableViewController {
    
    class Task {
        let task: MyMaths.CurrentTasks
        var remainingTime = 0
        var startTime = 0
        var isCompeted = false
        
        init(task: MyMaths.CurrentTasks) {
            self.task = task
        }
        
        public var progress: Float {
            Float(remainingTime) / Float(startTime)
        }
    }
    
    private let tasks: [Task]
    private var selectedConfig: TimeConfig = .instant
    private var hasStarted = false {
        didSet {
            UIApplication.shared.isIdleTimerDisabled = hasStarted
        }
    }
    
    init(tasks: [MyMaths.CurrentTasks]) {
        self.tasks = tasks.map { .init(task: $0) }
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "MyMaths Hax"
        tableView.register(ProgressSubtitleCell.self, forCellReuseIdentifier: "MyMaths.ProgressSubtitleCell")
        tableView.register(TimeConfigSelectionCell.self, forCellReuseIdentifier: "MyMaths.TimeConfigSelectionCell")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Start", style: .done, target: self, action: #selector(startWarning))
    }
    
    @objc private func startWarning() {
        var canContinue = false
        for task in tasks {
            if !task.isCompeted {
                canContinue = true
            }
        }
        guard canContinue else { return }
        let alert = UIAlertController(title: "Warning", message: "Keep your screen on until all the tasks finish, not my fault if you get shouted out yada yada", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Start", style: .destructive, handler: { [weak self] _ in
            self?.start()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.view.tintColor = .tintColor
        self.present(alert, animated: true)
    }
    
    @objc private func start() {
        // Should be impossible regardless but I don't like crashes, sanity check I suppose
        guard !tasks.isEmpty else { return }
        if selectedConfig == .instant {
            navigationItem.rightBarButtonItem?.isEnabled = false
            var index = 0
            func runTask() {
                MyMaths.shared.completeTask(task: tasks[index].task) { log in
                    // Again do something with this, not sure yet
                    print(log)
                } completion: { [weak self] error in
                    if let error = error {
                        // Do something, not sure what yet
                        print(error)
                    } else {
                        Thread.mainBlock {
                            guard let `self` = self else { return }
                            self.tasks[index].isCompeted = true
                            let indexPath = IndexPath(row: index, section: 0)
                            if let cell = self.tableView.cellForRow(at: indexPath) as? ProgressSubtitleCell {
                                cell.accessoryType = .checkmark
                            }
                            index++
                            if index == self.tasks.count {
                                return self.cancel()
                            }
                            runTask()
                        }
                    }
                }

            }
            runTask()
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(cancel))
        }
    }
    
    @objc private func cancel() {
        if !Thread.isMainThread {
            DispatchQueue.main.async { [weak self] in
                self?.cancel()
            }
            return
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Start", style: .done, target: self, action: #selector(startWarning))
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Tasks"
        case 1: return "Configuration"
        default: return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return tasks.count
        case 1: return 1
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyMaths.ProgressSubtitleCell", for: indexPath) as! ProgressSubtitleCell
            let task = tasks[indexPath.row]
            cell.textLabel?.text = task.task.name
            if hasStarted {
                cell.setProgress(task.progress)
            }
            cell.accessoryType = task.isCompeted ? .checkmark : .none
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyMaths.TimeConfigSelectionCell", for: indexPath) as! TimeConfigSelectionCell
            cell.segmentedControl.selectedSegmentIndex = selectedConfig.rawValue
            cell.delegate = self
            return cell
        default:
            return UITableViewCell()
        }
    }
    
}

extension MyMathsTaskCompletionViewController: TimeConfigSelection {
    
    func didSelect(config: TimeConfig) {
        selectedConfig = config
    }
    
}


