//
//  MyMathsTaskCompletionViewController.swift
//  Centralis
//
//  Created by Amy While on 12/03/2022.
//

import UIKit
import Evander

class MyMathsTaskCompletionViewController: BaseTableViewController {
    
    final class Task: Equatable {
        
        static func == (lhs: MyMathsTaskCompletionViewController.Task, rhs: MyMathsTaskCompletionViewController.Task) -> Bool {
            lhs.task == rhs.task
        }
        
        let task: MyMaths.CurrentTasks
        var currentTime = 0
        var startTime = 0 {
            didSet {
                currentTime = 0
            }
        }
        var isRunning = false
        var isCompeted = false {
            didSet {
                guard isCompeted else { return }
                let pastTask: MyMaths.PastTasks = .init(name: task.name, url: task.url, date: Date(), percent: 100)
                delegate?.complete(task: pastTask)
            }
        }
        private weak var delegate: TaskListDelegate?
        
        init(task: MyMaths.CurrentTasks, delegate: TaskListDelegate) {
            self.task = task
            self.delegate = delegate
        }
        
        public var progress: Float {
            Float(currentTime) / Float(startTime)
        }
    }
    
    private var timer: Timer?
    private let tasks: [Task]
    private var selectedConfig: TimeConfig = .instant
    private var hasStarted = false {
        didSet {
            UIApplication.shared.isIdleTimerDisabled = hasStarted
        }
    }
    private weak var delegate: TaskListDelegate?
    
    init(tasks: [MyMaths.CurrentTasks], delegate: TaskListDelegate) {
        self.tasks = tasks.map { .init(task: $0, delegate: delegate) }
        self.delegate = delegate
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
            randomTimes(for: selectedConfig)
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(cycle), userInfo: nil, repeats: true)
            hasStarted = true
        }
    }
    
    @objc private func cycle() {
        print("Cycle")
        if !Thread.isMainThread {
            DispatchQueue.main.async { [weak self] in
                self?.cycle()
            }
            return
        }
        for (index, task) in tasks.enumerated() where !task.isCompeted {
            task.currentTime++
            guard let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? ProgressSubtitleCell else { continue }
            if task.currentTime ==  task.startTime {
                guard !task.isRunning else { continue }
                task.isRunning = true
                MyMaths.shared.completeTask(task: task.task) { log in
                    print(log)
                } completion: { [weak self, weak task] error in
                    if let error = error {
                        print(error)
                        return
                    }
                    Thread.mainBlock {
                        task?.isCompeted = true
                        if let cell = self?.tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? ProgressSubtitleCell {
                            cell.accessoryType = .checkmark
                            cell.setProgress(1)
                        }
                        var shouldBreak = true
                        for task in self?.tasks ?? [] {
                            if !task.isCompeted {
                                shouldBreak = false
                            }
                        }
                        if shouldBreak {
                            self?.cancel()
                        }
                    }
                }
            } else {
                print(task.progress)
                cell.setProgress(task.progress)
            }
        }
    }
    
    private func randomTimes(for config: TimeConfig) {
        let range = config == .medium ? 300...420 : 420...720
        tasks.forEach { $0.startTime = Int.random(in: range)  }
    }
    
    @objc private func cancel() {
        if !Thread.isMainThread {
            DispatchQueue.main.async { [weak self] in
                self?.cancel()
            }
            return
        }
        timer?.invalidate()
        hasStarted = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Start", style: .done, target: self, action: #selector(startWarning))
        var canContinue = false
        for task in tasks {
            if !task.isCompeted {
                canContinue = true
            }
        }
        tasks.forEach { $0.isRunning = false }
        navigationItem.rightBarButtonItem?.isEnabled = canContinue
        if !canContinue {
            let alert = UIAlertController(title: "Finished", message: "All tasks have been finished with 100%", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Close", style: .default, handler: { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }))
            alert.view.tintColor = .tintColor
            self.present(alert, animated: true)
            return
        }
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
            } else {
                cell.setProgress(0)
            }
            cell.accessoryType = task.isCompeted ? .checkmark : .none
            cell.task = task
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


