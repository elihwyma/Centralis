//
//  AchievementViewController.swift
//  Centralis
//
//  Created by Amy While on 03/12/2020.
//

import UIKit

enum TextViewContext {
    case catering
    case achievement
    case personal
}

class TextViewController: UIViewController {

    var context: TextViewContext!
    @IBOutlet weak var tableView: UITableView!
    
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
        switch self.context {
        case .catering: self.cateringTitle()
        case .achievement: self.achievementTitle()
        case .personal: self.personalTitle()
        case .none: fatalError("fuck")
        }
    }
    
    private func setup() {
        self.tableView.backgroundColor = .none
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.singleLine
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.showsHorizontalScrollIndicator = false
        self.tableView.register(UINib(nibName: "TextViewCell", bundle: nil), forCellReuseIdentifier: "Centralis.TextViewCell")
        self.tableView.alwaysBounceVertical = false
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.individualSetup()
    }
    
    private func individualSetup() {
        switch self.context {
        case .catering: self.cateringSetup()
        case .achievement: self.achievementSetup()
        case .personal: self.personalSetup()
        case .none: fatalError("fuck")
        }
    }
    
    @objc private func dataResponse() {
        DispatchQueue.main.async {
            self.title()
            self.tableView.reloadData()
        }
    }
}

extension TextViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension TextViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.context {
        case .achievement: return EduLinkAPI.shared.achievementBehaviourLookups.achievements.count
        case .catering: return EduLinkAPI.shared.catering.transactions.count
        case .personal: return ((EduLinkAPI.shared.personal.forename == nil) ? 0 : 1)
        case .none: fatalError("fuck")
        }
        
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Centralis.TextViewCell", for: indexPath) as! TextViewCell
        switch self.context {
        case .achievement: do {
            let achievement = EduLinkAPI.shared.achievementBehaviourLookups.achievements[indexPath.row]
            cell.achievement(achievement)
        }
        case .catering: do {
            let transaction = EduLinkAPI.shared.catering.transactions[indexPath.row]
            cell.catering(transaction)
        }
        case .personal: do {
            cell.personal(EduLinkAPI.shared.personal)
        }
        case .none: do {
            fatalError("fuck")
        }
        }
    
        cell.transactionsView.attributedText = cell.att
        cell.transactionsView.textColor = .label
        return cell
    }
}

//MARK: - Achievement
extension TextViewController {
    private func achievementSetup() {
        NotificationCenter.default.addObserver(self, selector: #selector(dataResponse), name: .SuccesfulAchievement, object: nil)
        let achievement = EduLink_Achievement()
        achievement.achievement()
    }
    
    private func achievementTitle() {
        var count = 0
        for achievement in EduLinkAPI.shared.achievementBehaviourLookups.achievements {
            count += achievement.points
        }
        self.title = "Achievements: \(count)"
    }
}

//MARK: - Catering
extension TextViewController {
    private func cateringSetup() {
        NotificationCenter.default.addObserver(self, selector: #selector(dataResponse), name: .SuccesfulCatering, object: nil)
        let catering = EduLink_Catering()
        catering.catering()
    }
    
    private func formatPrice(_ number: Double) -> String {
        let numstring = String(format: "%03.2f", number)
        return "£\(numstring)"
    }
    
    private func cateringTitle() {
        if let balance = EduLinkAPI.shared.catering.balance {
            self.title = "Balance: \(self.formatPrice(balance))"
        }
    }
}

//MARK: - Personal
extension TextViewController {
    private func personalSetup() {
        NotificationCenter.default.addObserver(self, selector: #selector(dataResponse), name: .SuccesfulPersonal, object: nil)
        let personal = EduLink_Personal()
        personal.personal()
    }
    
    private func personalTitle() {
        self.title = "Account Info"
    }
}