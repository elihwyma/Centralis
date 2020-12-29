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
    case statutorymonth
    case statutoryyear
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
        self.tableView.register(UINib(nibName: "TextViewCell", bundle: nil), forCellReuseIdentifier: "Centralis.TextViewCell")
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
}

//MARK: - Lesson Behaviour
extension ChartTableViewController {
    private func lessonBehaviour() {
        EduLink_Register.registerCodes({ (success, error) -> Void in
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
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
        case .statutorymonth: if EduLinkAPI.shared.attendance.statutory.count == 0 { return 0 } else { return EduLinkAPI.shared.attendance.statutory.first!.exceptions.count + 1 }
        case .statutoryyear: return EduLinkAPI.shared.attendance.statutoryyear.exceptions.count + 1
        default: return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch self.context {
        case .lessonBehaviour: do {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Centralis.AmyChartCell", for: indexPath) as! AmyChartCell
            let lb = EduLinkAPI.shared.achievementBehaviourLookups.behaviourForLessons[indexPath.row]
            cell.lessonBehaviour(lb)
            cell.textView.attributedText = cell.att
            return cell
        }
        case .lessonattendance: do {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Centralis.AmyChartCell", for: indexPath) as! AmyChartCell
            let l = EduLinkAPI.shared.attendance.lessons[indexPath.row]
            cell.lessonAttendance(l.values, text: l.subject!)
            cell.textView.attributedText = cell.att
            return cell
        }
        case .statutorymonth: do {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Centralis.AmyChartCell", for: indexPath) as! AmyChartCell
                cell.lessonAttendance(EduLinkAPI.shared.attendance.statutory.first!.values, text: EduLinkAPI.shared.attendance.statutory.first!.month)
                cell.textView.attributedText = cell.att
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Centralis.TextViewCell", for: indexPath) as! TextViewCell
                let exception = EduLinkAPI.shared.attendance.statutory.first!.exceptions[indexPath.row - 1]
                cell.exception(exception)
                cell.transactionsView.attributedText = cell.att
                cell.transactionsView.textColor = .label
                return cell
            }
        }
        case .statutoryyear: do {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Centralis.AmyChartCell", for: indexPath) as! AmyChartCell
                cell.lessonAttendance(EduLinkAPI.shared.attendance.statutoryyear.values, text: "Statutory Year")
                cell.textView.attributedText = cell.att
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Centralis.TextViewCell", for: indexPath) as! TextViewCell
                let exception = EduLinkAPI.shared.attendance.statutoryyear.exceptions[indexPath.row - 1]
                cell.exception(exception)
                cell.transactionsView.attributedText = cell.att
                cell.transactionsView.textColor = .label
                return cell
            }
        }
        default: fatalError("fuck")
        }
    }
}

