//
//  AchievementViewController.swift
//  Centralis
//
//  Created by Amy While on 03/12/2020.
//

import UIKit

class AchievementViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    let achievement = EduLink_Achievement()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title()
    }
    
    private func title() {
        var count = 0
        for achievement in EduLinkAPI.shared.achievementBehaviourLookups.achievements {
            count += achievement.points
        }
        self.title = "Achievements: \(count)"
    }
    
    private func setup() {
        self.achievement.achievement()
        self.tableView.backgroundColor = .none
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.singleLine
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.showsHorizontalScrollIndicator = false
        self.tableView.register(UINib(nibName: "TextViewCell", bundle: nil), forCellReuseIdentifier: "Centralis.TextViewCell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.alwaysBounceVertical = false
        NotificationCenter.default.addObserver(self, selector: #selector(achievementResponse), name: .SuccesfulAchievement, object: nil)
    }
    
    @objc private func achievementResponse() {
        DispatchQueue.main.async {
            self.title()
            self.tableView.reloadData()
        }
    }
    
}

extension AchievementViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension AchievementViewController : UITableViewDataSource {
    
    //This is just meant to be
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return EduLinkAPI.shared.achievementBehaviourLookups.achievements.count
    }

    //This is what handles all the images and text etc, using the class mainScreenTableCells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Centralis.TextViewCell", for: indexPath) as! TextViewCell
        let achievement = EduLinkAPI.shared.achievementBehaviourLookups.achievements[indexPath.row]
        cell.att = NSMutableAttributedString()
        cell.addPair(bold: "Date: ", normal: "\(achievement.date!)\n")
        for employee in EduLinkAPI.shared.employees where employee.id == achievement.employee_id {
            cell.addPair(bold: "Teacher: ", normal: "\(employee.title!) \(employee.forename!) \(employee.surname!)\n")
        }
        cell.addPair(bold: "Lesson: ", normal: "\(achievement.lesson_information ?? "Not Given")\n")
        cell.addPair(bold: "Points: ", normal: "\(achievement.points!)\n")
        for type in achievement.type_ids {
            for at in EduLinkAPI.shared.achievementBehaviourLookups.achievement_types where at.id == type {
                cell.addPair(bold: "Type: ", normal: "\(at.description!)\n")
            }
        }
        cell.addPair(bold: "Comment: ", normal: "\(achievement.comments!)")
        cell.transactionsView.attributedText = cell.att
        cell.transactionsView.textColor = .label
        return cell
    }
}
