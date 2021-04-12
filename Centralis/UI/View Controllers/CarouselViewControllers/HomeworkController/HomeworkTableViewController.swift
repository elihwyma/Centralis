//
//  HomeworkTable.swift
//  Centralis
//
//  Created by AW on 05/12/2020.
//

import UIKit
//import libCentralis

class HomeworkTableViewController: UIView {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var descriptionLabel: UILabel!
    var rootSender: CarouselContainerController?
    var context: HomeworkContext?
    var sender: CarouselController?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }
        
    private func setup() {
        self.tableView.backgroundColor = .none
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.singleLine
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.showsHorizontalScrollIndicator = false
        self.tableView.register(UINib(nibName: "HomeworkCell", bundle: nil), forCellReuseIdentifier: "Centralis.HomeworkCell")
        self.tableView.alwaysBounceVertical = false
        self.tableView.delegate = self
        self.tableView.dataSource = self
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(HomeworkTableViewController.showCompleteMenu))
        self.tableView.addGestureRecognizer(longPress)
    }
    
    var completeCache: (Bool, Int, HomeworkContext)!
    private func completeError(_ error: String) {
        let errorView: ErrorView = .fromNib()
        errorView.text.text = error
        errorView.changeGoBackLabel("Ignore")
        errorView.retryButton.addTarget(self, action: #selector(self.completeHomework), for: .touchUpInside)
        if let nc = self.rootSender?.navigationController { errorView.startWorking(nc) }
    }
    
    @objc private func completeHomework() {
        EduLink_Homework.completeHomework(self.completeCache.0, self.completeCache.1, self.completeCache.2, {(success, error) -> Void in
            DispatchQueue.main.async {
                if success {
                    self.tableView.reloadData()
                } else {
                    self.completeError(error!)
                }
            }
        })
    }
    
    @objc private func showCompleteMenu(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        if longPressGestureRecognizer.state != UIGestureRecognizer.State.began { return }
        let touchPoint = longPressGestureRecognizer.location(in: tableView)
        if let indexPath = tableView.indexPathForRow(at: touchPoint) {
            let homework: Homework!
            switch context {
            case .current: homework = EduLinkAPI.shared.homework.current[indexPath.row]
            case .past: homework = EduLinkAPI.shared.homework.past[indexPath.row]
            case .none: fatalError("fuck")
            }
            let alert = UIAlertController(title: "Homework Options", message: "What do you want do with this homework?", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Mark as \(homework.completed ? "Not Completed" : "Completed")", style: .default, handler: { action in
                self.completeCache = (!homework.completed, indexPath.row, self.context!)
                self.completeHomework()
            }))
            alert.addAction(UIAlertAction(title: "Show Description", style: .default, handler: { action in
                let vc = UIViewController()
                let view: HomeworkDetailView = .fromNib()
                view.context = self.context
                view.homework = homework
                view.index = indexPath.row
                view.rootSender = self.rootSender
                view.setup()
                vc.view = view
                ((self.sender?.view)?.parentViewController)?.navigationController?.pushViewController(vc, animated: true)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            if let popoverController = alert.popoverPresentationController {
              popoverController.sourceView = self
              popoverController.sourceRect = CGRect(x: self.bounds.midX, y: self.bounds.midY, width: 0, height: 0)
              popoverController.permittedArrowDirections = []
            }
            self.sender?.present(alert, animated: true)
        }
    }

    private func setLabel() {
        switch self.context {
        case .current: do {
            if EduLinkAPI.shared.homework.current.isEmpty {
                self.descriptionLabel.text = "No Current Homework 🥳"
            }
        }
        case .past: do {
            if EduLinkAPI.shared.homework.past.isEmpty {
                self.descriptionLabel.text = "No Past Homework 🥳"
            }
        }
        default: break
        }
    }
}

extension HomeworkTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension HomeworkTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.setLabel()
        if self.context == .current {
            if var notificationPreferences = EduLinkAPI.shared.defaults.dictionary(forKey: "RegisteredNotifications") {
                var postedChanges = notificationPreferences["HomeworkPosted"] as? [String : Any] ?? [String : Any]()
                var postedNew = postedChanges["PostedNew"] as? [String] ?? [String]()
                for homework in EduLinkAPI.shared.homework.current {
                    if !postedNew.contains(homework.id ?? "") {
                        postedNew.append(homework.id ?? "")
                    }
                }
                postedChanges["PostedNew"] = postedNew
                notificationPreferences["HomeworPosted"] = postedChanges
                EduLinkAPI.shared.defaults.setValue(notificationPreferences, forKey: "RegisteredNotifications")
            }
        }
        
        switch self.context {
        case .current: return EduLinkAPI.shared.homework.current.count
        case .past: return EduLinkAPI.shared.homework.past.count
        case .none: fatalError("fuck")
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Centralis.HomeworkCell", for: indexPath) as! HomeworkCell
        switch self.context {
        case .current: cell.homework(EduLinkAPI.shared.homework.current[indexPath.row])
        case .past: cell.homework(EduLinkAPI.shared.homework.past[indexPath.row])
        case .none: fatalError("fuck")
        }
        cell.textView.attributedText = cell.att
        cell.textView.textColor = .label
        return cell
    }
}
