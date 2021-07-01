//
//  AchievementViewController.swift
//  Centralis
//
//  Created by AW on 03/12/2020.
//

import UIKit
//import libCentralis

enum TextViewContext {
    case catering
    case achievement
    case links
    case documents
}

class TextViewController: UIViewController {

    var context: TextViewContext!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var noDataLabel: UILabel!
    
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
            self.noDataLabel.isHidden = false
            switch self.context {
            case .catering: self.noDataLabel.text = "\(!EduLinkAPI.shared.catering.transactions.isEmpty ? "" : "No transactions available")"
            case .achievement: self.noDataLabel.text = "\(!EduLinkAPI.shared.achievementBehaviourLookups.achievements.isEmpty ? "" : "No achievements available")"
            case .links: self.noDataLabel.text = "\(!EduLinkAPI.shared.links.isEmpty ? "" : "No links available")"
            case .documents: self.noDataLabel.text = "\(!EduLinkAPI.shared.documents.isEmpty ? "" : "No transactions available")"
            default: break
            }
        }
    }
    
    @objc private func goBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func error(_ error: String) {
        let errorView: ErrorView = .fromNib()
        errorView.text.text = error
        errorView.goBackButton.addTarget(self, action: #selector(self.goBack), for: .touchUpInside)
        switch context {
        case .catering: errorView.retryButton.addTarget(self, action: #selector(self.cateringSetup), for: .touchUpInside)
        case .achievement: errorView.retryButton.addTarget(self, action: #selector(self.achievementSetup), for: .touchUpInside)
        case .links: errorView.retryButton.addTarget(self, action: #selector(self.linkSetup), for: .touchUpInside)
        case .documents: errorView.retryButton.addTarget(self, action: #selector(self.documentSetup), for: .touchUpInside)
        case .none: break
        }
        if let nc = self.navigationController { errorView.startWorking(nc) }
    }
    
    private func documentError(_ error: String) {
        let errorView: ErrorView = .fromNib()
        errorView.text.text = error
        errorView.changeGoBackLabel("Ignore")
        errorView.retryButton.addTarget(self, action: #selector(self.loadDocument), for: .touchUpInside)
        if let nc = self.navigationController { errorView.startWorking(nc) }
    }
    
    @objc private func loadDocument() {
        if let nc = self.navigationController { self.workingCover.startWorking(nc) }
        EduLink_Documents.document(EduLinkAPI.shared.documents[self.documentIndex], {(success, error) -> Void in
            DispatchQueue.main.async {
                self.workingCover.stopWorking()
                if success {
                    self.performSegue(withIdentifier: "Centralis.DocumentWebView", sender: nil)
                } else {
                    self.documentError(error!)
                }
            }
        })
    }
}

extension TextViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.context == TextViewContext.links {
            let link = EduLinkAPI.shared.links[indexPath.row]
            if let url = URL(string: link.link) {
                UIApplication.shared.open(url)
            }
        }
        if self.context == TextViewContext.documents {
            self.documentIndex = indexPath.row
            self.loadDocument()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension TextViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.context {
        case .achievement: return EduLinkAPI.shared.achievementBehaviourLookups.achievements.count
        case .catering: return EduLinkAPI.shared.catering.transactions.count
        case .links: return EduLinkAPI.shared.links.count
        case .documents: return EduLinkAPI.shared.documents.count
        case .none: fatalError("fuck")
        }
        
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.context == TextViewContext.links {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Centralis.LoginCell", for: indexPath) as! LoginCell
            let link = EduLinkAPI.shared.links[indexPath.row]
            if let data = link.image,
               let image = UIImage(data: data) {
                cell.schoolLogo.image = image
            } else {
                cell.schoolLogo.image = UIImage(systemName: "link.circle.fill")
            }
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
    @objc private func achievementSetup() {
        if !EduLinkAPI.shared.achievementBehaviourLookups.achievements.isEmpty { return self.dataResponse() }
        EduLink_Achievement.achievement({(success, error) -> Void in
            DispatchQueue.main.async {
                if success {
                    self.dataResponse()
                } else {
                    self.error(error!)
                }
            }
        })
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
    @objc private func cateringSetup() {
        if !EduLinkAPI.shared.catering.transactions.isEmpty { return self.dataResponse() }
        EduLink_Catering.catering({(success, error) -> Void in
            DispatchQueue.main.async {
                if success {
                    self.dataResponse()
                } else {
                    self.error(error!)
                }
            }
        })
    }
    
    private func formatPrice(_ number: Double) -> String {
        let numstring = String(format: "%03.2f", number)
        return "£\(numstring)"
    }
    
    private func cateringTitle() {
        self.title = "Balance: \(self.formatPrice(EduLinkAPI.shared.catering.balance))"
    }
}

//MARK: - Links
extension TextViewController {
    @objc private func linkSetup() {
        if !EduLinkAPI.shared.links.isEmpty { return self.dataResponse() }
        EduLink_Links.links({(success, error) -> Void in
            DispatchQueue.main.async {
                if success {
                    self.dataResponse()
                } else {
                    self.error(error!)
                }
            }
        })
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
            if d.data?.isEmpty ?? false { return }
            let vc = segue.destination as! DocumentWebViewController
            vc.document = d
        }
    }
    
    @objc private func documentSetup() {
        if !EduLinkAPI.shared.documents.isEmpty { return self.dataResponse() }
        EduLink_Documents.documents({(success, error) -> Void in
            DispatchQueue.main.async {
                if success {
                    self.dataResponse()
                } else {
                    self.error(error!)
                }
            }
        })
    }
    
    private func documentTitle() {
        self.title = "Documents"
    }
}
