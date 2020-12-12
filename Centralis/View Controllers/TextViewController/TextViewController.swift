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
    case links
    case documents
}

class TextViewController: UIViewController {

    var context: TextViewContext!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var workingCover: WorkingCover = .fromNib()
    var documentIndex = -1
    
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
        case .links: self.linkTitle()
        case .documents: self.documentTitle()
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
        self.tableView.register(UINib(nibName: "LoginCell", bundle: nil), forCellReuseIdentifier: "Centralis.LoginCell")
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
        case .links: self.linkSetup()
        case .documents: self.documentSetup()
        case .none: fatalError("fuck")
        }
    }
    
    @objc private func dataResponse() {
        DispatchQueue.main.async {
            self.title()
            self.activityIndicator.isHidden = true
            self.tableView.reloadData()
        }
    }
}

extension TextViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("but this runs")
        if self.context == TextViewContext.links {
            let link = EduLinkAPI.shared.links[indexPath.row]
            if let url = URL(string: link.link) {
                UIApplication.shared.open(url)
            }
        }
        if self.context == TextViewContext.documents {
            print("this runs")
            self.startWorking()
            self.documentIndex = indexPath.row
            let document = EduLink_Documents()
            document.document(EduLinkAPI.shared.documents[indexPath.row], self)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension TextViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.context {
        case .achievement: return EduLinkAPI.shared.achievementBehaviourLookups.achievements.count
        case .catering: return EduLinkAPI.shared.catering.transactions.count
        case .personal: return ((EduLinkAPI.shared.personal.forename == nil) ? 0 : 1)
        case .links: return EduLinkAPI.shared.links.count
        case .documents: return EduLinkAPI.shared.documents.count
        case .none: fatalError("fuck")
        }
        
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.context == TextViewContext.links {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Centralis.LoginCell", for: indexPath) as! LoginCell
            let link = EduLinkAPI.shared.links[indexPath.row]
            cell.schoolLogo.image = link.image
            cell.schoolName.text = link.name
            cell.forename.text = link.link
            cell.backgroundColor = .systemGray5
            return cell
        }
        
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
        case .documents: do {
            let document = EduLinkAPI.shared.documents[indexPath.row]
            cell.document(document)
        }
        default: do {
            fatalError("fuck")
        }
        }
    
        cell.transactionsView.attributedText = cell.att
        cell.transactionsView.textColor = .label
        self.activityIndicator.isHidden = true
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

//MARK: - Links
extension TextViewController {
    private func linkSetup() {
        NotificationCenter.default.addObserver(self, selector: #selector(dataResponse), name: .SuccesfulLink, object: nil)
        let link = EduLink_Links()
        link.links()
    }
    
    private func linkTitle() {
        self.title = "Links"
    }
}

//MARK: - Documents
extension TextViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Centralis.DocumentWebView" {
            if self.documentIndex == -1 { return }
            let d = EduLinkAPI.shared.documents[self.documentIndex]
            if d.data.isEmpty { return }
            let vc = segue.destination as! DocumentWebViewController
            vc.document = d
        }
    }
    
    private func documentSetup() {
        NotificationCenter.default.addObserver(self, selector: #selector(dataResponse), name: .SucccesfulDocument, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(stopWorking), name: .SucccesfulDocumentLookup, object: nil)
        let document = EduLink_Documents()
        document.documents()
    }
    
    private func documentTitle() {
        self.title = "Documents"
    }
    
    private func startWorking() {
        self.workingCover.frame = self.view.frame
        self.workingCover.alpha = 0
        self.view.addSubview(workingCover)
        UIView.animate(withDuration: 0.5,
                         delay: 0, usingSpringWithDamping: 1.0,
                         initialSpringVelocity: 1.0,
                         options: .curveEaseInOut, animations: {
                            self.workingCover.alpha = 1
                         }, completion: { (value: Bool) in
          })
    }
    
    @objc private func stopWorking() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5,
                             delay: 0, usingSpringWithDamping: 1.0,
                             initialSpringVelocity: 1.0,
                             options: .curveEaseInOut, animations: {
                                self.workingCover.alpha = 0
                             }, completion: { (value: Bool) in
                                self.workingCover.removeFromSuperview()
              })
        }
    }
}
