//
//  ChartTableViewController.swift
//  Centralis
//
//  Created by Amy While on 17/12/2020.
//

import UIKit

enum ChartContext {
    case lessonBehaviour
    case lessonattendance
}

class ChartTableViewController: UIView {

    @IBOutlet weak var tableView: UITableView!
    var context: ChartContext?
    
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
        self.tableView.register(UINib(nibName: "AmyChartCell", bundle: nil), forCellReuseIdentifier: "Centralis.AmyChartCell")
        self.tableView.alwaysBounceVertical = false
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.individualSetup()
    }
    
    private func individualSetup() {
        switch self.context {
        case .lessonBehaviour: self.lessonBehaviour()
        default: break
        }
    }
    
    @objc private func reloadTable() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

//MARK: - Lesson Behaviour
extension ChartTableViewController {
    private func lessonBehaviour() {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTable), name: .BehaviourCodes, object: nil)
        let rc = EduLink_Register()
        rc.registerCodes(.BehaviourCodes)
    }
}

extension ChartTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ChartTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.context {
        case .lessonBehaviour: return ( EduLinkAPI.shared.authorisedSchool.schoolInfo.lesson_codes.isEmpty ? 0 : EduLinkAPI.shared.achievementBehaviourLookups.behaviourForLessons.count)
        case .lessonattendance: return EduLinkAPI.shared.attendance.lessons.count
        default: return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Centralis.AmyChartCell", for: indexPath) as! AmyChartCell
        switch self.context {
        case .lessonBehaviour: do {
            let lb = EduLinkAPI.shared.achievementBehaviourLookups.behaviourForLessons[indexPath.row]
            cell.lessonBehaviour(lb)
        }
        case .lessonattendance: do {
            let l = EduLinkAPI.shared.attendance.lessons[indexPath.row]
            cell.lessonAttendance(l)
        }
        default: fatalError("fuck")
        }
        
        cell.textView.attributedText = cell.att
        return cell
    }
}

