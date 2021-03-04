//
//  HomeViewController.swift
//  Centralis
//
//  Created by AW on 01/12/2020.
//

import UIKit
//import libCentralis

struct HomeScreenLesson {
    var current: MiniLesson!
    var upcoming: MiniLesson!
}

class HomeViewController: UIViewController {
    
    let completedMenus: [String] = [
        "Achievement",
        "Catering",
        "Account Info",
        "Homework",
        "Timetable",
        "Links",
        "Documents",
        "Behaviour",
        "Attendance"
    ]
    
    @IBOutlet weak var tableView: UITableView!
    var workingCover: WorkingCover = .fromNib()
    var login: SavedLogin!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title()
        if EduLinkAPI.shared.authorisedUser.authToken != nil {
            self.refreshStatus()
        }
    }
    
    var shownCells: [[Any]] = [[],[]]
    
    private func menuOrganising() {
        self.shownCells[1].removeAll()
        #if DEBUG
        self.shownCells[1] = EduLinkAPI.shared.authorisedUser.personalMenus
        #else
        for m in EduLinkAPI.shared.authorisedUser.personalMenus {
            if completedMenus.contains(m.name) {
                self.shownMenus.append(m)
            }
        }
        #endif
    }
    
    private func setup() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.showsHorizontalScrollIndicator = false
        self.tableView.backgroundColor = .none
        self.tableView.register(UINib(nibName: "HomeMenuCell", bundle: nil), forCellReuseIdentifier: "Centralis.HomeMenuCell")
        self.tableView.register(UINib(nibName: "HomeMenuLessonCell", bundle: nil), forCellReuseIdentifier: "Centralis.HomeMenuLessonCell")
        self.menuOrganising()
    }
    
    @objc public func arriveFromDelegate() {
        if let nc = self.navigationController { self.workingCover.startWorking(nc) }
        LoginManager.shared.quickLogin(self.login, { (success, error) -> Void in
            DispatchQueue.main.async {
                self.workingCover.stopWorking()
                if success {
                    self.menuOrganising()
                    self.tableView.reloadData()
                    self.refreshStatus()
                    self.title()
                } else {
                    self.delegateLoginError(error!)
                }
            }
        })
    }
    
    private func title() {
        #if DEBUG
        self.title = "😎🖕"
        #else
        self.title = "\(EduLinkAPI.shared.authorisedUser.forename ?? "") \(EduLinkAPI.shared.authorisedUser.surname ?? "")"
        #endif
    }
    
    private func delegateLoginError(_ error: String) {
        let errorView: ErrorView = .fromNib()
        errorView.text.text = error
        errorView.goBackButton.addTarget(self, action: #selector(self.logout), for: .touchUpInside)
        errorView.retryButton.addTarget(self, action: #selector(self.arriveFromDelegate), for: .touchUpInside)
        if let nc = self.navigationController { errorView.startWorking(nc) }
    }
    
    @objc private func refreshStatus() {
        EduLink_Status.status(rootCompletion: { (success, error) -> Void in
            DispatchQueue.main.async {
                self.shownCells[0].removeAll()
                if success {
                    if EduLinkAPI.shared.status.current != nil && EduLinkAPI.shared.status.upcoming != nil {
                        self.shownCells[0].append(HomeScreenLesson(current: EduLinkAPI.shared.status.current, upcoming: EduLinkAPI.shared.status.upcoming))
                        self.tableView.reloadData()
                    }
                } else {
                    self.statusError(error!)
                }
            }
        })
    }
    
    private func statusError(_ error: String) {
        let errorView: ErrorView = .fromNib()
        errorView.text.text = error
        errorView.changeGoBackLabel("Ignore")
        errorView.retryButton.addTarget(self, action: #selector(self.refreshStatus), for: .touchUpInside)
        if let nc = self.navigationController { errorView.startWorking(nc) }
    }
    
    @objc func logout(_ sender: Any) {
        EduLinkAPI.shared.clear()
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        viewController.modalPresentationStyle = .fullScreen
        self.present(viewController, animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPaths: NSArray = self.tableView.indexPathsForSelectedRows! as NSArray
        if indexPaths.count == 0 { return }
        let indexPath: IndexPath = indexPaths[0] as! IndexPath
        let menu = self.shownCells[1][indexPath.row] as! SimpleStore
        if segue.identifier == "Centralis.TextViewController" {
            let controller = segue.destination as! TextViewController
            switch menu.name! {
            case "Achievement": controller.context = .achievement
            case "Catering": controller.context = .catering
            case "Account Info": controller.context = .personal
            case "Links": controller.context = .links
            case "Documents": controller.context = .documents
            default: fatalError("Not implemented yet")
            }
        } else if segue.identifier == "Centralis.ShowCarousel" {
            let controller = segue.destination as! CarouselContainerController
            switch menu.name! {
            case "Homework": controller.context = .homework
            case "Timetable": controller.context = .timetable
            case "Behaviour": controller.context = .behaviour
            case "Attendance": controller.context = .attendance
            default: fatalError("Not implemented yet")
            }
        }
    }
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (self.shownCells[1][indexPath.row] as! SimpleStore).name {
        case "Achievement": self.performSegue(withIdentifier: "Centralis.TextViewController", sender: nil)
        case "Catering": self.performSegue(withIdentifier: "Centralis.TextViewController", sender: nil)
        case "Account Info": self.performSegue(withIdentifier: "Centralis.TextViewController", sender: nil)
        case "Homework": self.performSegue(withIdentifier: "Centralis.ShowCarousel", sender: nil)
        case "Behaviour": self.performSegue(withIdentifier: "Centralis.ShowCarousel", sender: nil)
        case "Timetable": self.performSegue(withIdentifier: "Centralis.ShowCarousel", sender: nil)
        case "Links": self.performSegue(withIdentifier: "Centralis.TextViewController", sender: nil)
        case "Documents": self.performSegue(withIdentifier: "Centralis.TextViewController", sender: nil)
        case "Attendance": self.performSegue(withIdentifier: "Centralis.ShowCarousel", sender: nil)
        default: print("Not yet implemented")
        }
    }
}

extension HomeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.shownCells[1].count == 0 { self.tableView.isHidden = true} else { self.tableView.isHidden = false }
        return self.shownCells[section + (self.shownCells[0].isEmpty ? 1 : 0)].count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.shownCells[0].isEmpty ? 1 : 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.shownCells[0].isEmpty || indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Centralis.HomeMenuCell", for: indexPath) as! HomeMenuCell
            let menu = self.shownCells[1][indexPath.row] as! SimpleStore
            cell.name.text = menu.name
            switch menu.name {
            case "Exams": cell.iconView.image = UIImage(systemName: "envelope.fill")
            case "Documents": cell.iconView.image = UIImage(systemName: "doc.fill")
            case "Timetable": cell.iconView.image = UIImage(systemName: "clock.fill")
            case "Account Info": cell.iconView.image = UIImage(systemName: "person.fill")
            case "Clubs": cell.iconView.image = UIImage(systemName: "person.3.fill")
            case "Links": cell.iconView.image = UIImage(systemName: "link.circle.fill")
            case "Homework": cell.iconView.image = UIImage(systemName: "briefcase.fill")
            case "Catering": cell.iconView.image = UIImage(systemName: "sterlingsign.square.fill")
            case "Attendance": cell.iconView.image = UIImage(systemName: "chart.bar.fill")
            case "Behaviour": cell.iconView.image = UIImage(systemName: "hand.raised.slash.fill")
            case "Achievement": cell.iconView.image = UIImage(systemName: "wand.and.stars")
            default: break
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Centralis.HomeMenuLessonCell", for: indexPath) as! HomeMenuLessonCell
            if let l = self.shownCells[0][0] as? HomeScreenLesson {
                cell.lessons(l)
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let vw = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 40))
        let label = UILabel(frame: CGRect(x: 0, y: 10, width: tableView.frame.width, height: 20))
        label.adjustsFontSizeToFitWidth = true
        let boldAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 20, weight: .bold),
        ]
        if self.shownCells[0].isEmpty || section == 1 {
            label.attributedText = NSAttributedString(string: "Menus", attributes: boldAttributes)
        } else {
            label.attributedText = NSAttributedString(string: "Lessons", attributes: boldAttributes)
        }
        
        vw.addSubview(label)
        return vw
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cornerRadius = 10
        var corners: UIRectCorner = []

        if indexPath.row == 0 {
            corners.update(with: .topLeft)
            corners.update(with: .topRight)
        }

        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            corners.update(with: .bottomLeft)
            corners.update(with: .bottomRight)
        }

        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(roundedRect: cell.bounds,
                                      byRoundingCorners: corners,
                                      cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)).cgPath
        cell.layer.mask = maskLayer
    }
}
