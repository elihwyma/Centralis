//
//  ChartTableViewController.swift
//  Centralis
//
//  Created by Amy While on 17/12/2020.
//

import UIKit

enum ChartContext {
    case lessonBehaviour
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
        case .lessonBehaviour: return EduLinkAPI.shared.achievementBehaviourLookups.behaviourForLessons.count
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
        default: fatalError("fuck")
        }
        
        cell.textView.attributedText = cell.att
        cell.textView.textColor = .label
        return cell
    }
}

