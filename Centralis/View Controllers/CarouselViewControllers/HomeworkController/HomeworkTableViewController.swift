//
//  HomeworkTable.swift
//  Centralis
//
//  Created by Amy While on 05/12/2020.
//

import UIKit

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
        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: .SuccesfulHomework, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: .SuccesfulHomeworkToggle, object: nil)
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(HomeworkTableViewController.showCompleteMenu))
        self.tableView.addGestureRecognizer(longPress)
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
                let hw = EduLink_Homework()
                hw.completeHomework(!homework.completed!, indexPath.row, self.context!)
            }))
            alert.addAction(UIAlertAction(title: "Show Description", style: .default, handler: { action in
                let vc = UIViewController()
                let view: HomeworkDetailView = .fromNib()
                view.context = self.context
                view.homework = homework
                view.index = indexPath.row
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
    
    @objc private func reload() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
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
