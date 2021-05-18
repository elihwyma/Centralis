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

class HomeViewController: BaseTableViewController {
    
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
    
    var shownCells: [[Any]] = [[],[],[]]
    
    private func menuOrganising() {
        self.shownCells[1].removeAll()
        #if DEBUG
        self.shownCells[1] = EduLinkAPI.shared.authorisedUser.personalMenus
        #else
        for m in EduLinkAPI.shared.authorisedUser.personalMenus {
            if completedMenus.contains(m.name) {
                self.shownCells[1].append(m)
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
        self.tableView.register(UINib(nibName: "HomeMenuLessonCell", bundle: nil), forCellReuseIdentifier: "Centralis.HomeMenuLessonCell")
        self.menuOrganising()
        self.shownCells[2].append(SimpleStore(id: "CentralisSettings", name: "Settings"))
        self.tableView.layer.masksToBounds = true
        self.tableView.layer.cornerRadius = 10
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in
            UNUserNotificationCenter.current().getNotificationSettings() { settings in
                if settings.authorizationStatus == .denied {
                    var rn = EduLinkAPI.shared.defaults.object(forKey: "RegisteredNotifications") as? [String : Any] ?? [String : Any]()
                    rn["HomeworkChanges"] = false
                    rn["RoomChanges"] = false
                    EduLinkAPI.shared.defaults.setValue(rn, forKey: "RegisteredNotifications")
                }
            }
        }
        
        self.view.backgroundColor = .systemGroupedBackground
        self.updateColours()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateColours),
                                               name: ThemeManager.ThemeUpdate,
                                               object: nil)
    }
    
    @objc private func updateColours() {
        self.view.tintColor = .centralisTintColor
        self.tableView.reloadData()
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
        self.title = "Debug Mode"
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
    
    @objc private func logout() {
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
        let menu: SimpleStore
        if indexPath.section == 2 {
            menu = self.shownCells[2][indexPath.row] as! SimpleStore
        } else {
            menu = self.shownCells[1][indexPath.row] as! SimpleStore
        }
        if segue.identifier == "Centralis.TextViewController" {
            let controller = segue.destination as! TextViewController
            switch menu.name {
            case "Achievement": controller.context = .achievement
            case "Catering": controller.context = .catering
            case "Account Info": controller.context = .personal
            case "Links": controller.context = .links
            case "Documents": controller.context = .documents
            default: fatalError("Not implemented yet")
            }
        } else if segue.identifier == "Centralis.ShowCarousel" {
            let controller = segue.destination as! CarouselContainerController
            switch menu.name {
            case "Homework": controller.context = .homework
            case "Timetable": controller.context = .timetable
            case "Behaviour": controller.context = .behaviour
            case "Attendance": controller.context = .attendance
            default: fatalError("Not implemented yet")
            }
        } else if segue.identifier == "Centralis.Settings" {
            let _ = segue.destination as! UINavigationController
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 || (self.shownCells[0].isEmpty && indexPath.section == 1) {
            switch (self.shownCells[2][indexPath.row] as! SimpleStore).name {
            case "Settings": self.performSegue(withIdentifier: "Centralis.Settings", sender: nil)
            default: print("Not yet implemented")
            }
        } else {
            switch (self.shownCells[1][indexPath.row] as! SimpleStore).name {
            case "Achievement": self.performSegue(withIdentifier: "Centralis.TextViewController", sender: nil)
            case "Catering": self.performSegue(withIdentifier: "Centralis.TextViewController", sender: nil)
            case "Account Info":
                let accountViewController = AccountViewController(style: .insetGrouped)
                self.navigationController?.pushViewController(accountViewController, animated: true)
            case "Homework": self.performSegue(withIdentifier: "Centralis.ShowCarousel", sender: nil)
            case "Behaviour": self.performSegue(withIdentifier: "Centralis.ShowCarousel", sender: nil)
            case "Timetable": self.performSegue(withIdentifier: "Centralis.ShowCarousel", sender: nil)
            case "Links": self.performSegue(withIdentifier: "Centralis.TextViewController", sender: nil)
            case "Documents": self.performSegue(withIdentifier: "Centralis.TextViewController", sender: nil)
            case "Attendance": self.performSegue(withIdentifier: "Centralis.ShowCarousel", sender: nil)
            case "Settings": self.performSegue(withIdentifier: "Centralis.Settings", sender: nil)
            default: print("Not yet implemented")
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.shownCells[1].count == 0 { self.tableView.isHidden = true} else { self.tableView.isHidden = false }
        return self.shownCells[section + (self.shownCells[0].isEmpty ? 1 : 0)].count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.shownCells[0].isEmpty ? 2 : 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch self.section(indexPath.section) {
        case .lessons:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Centralis.HomeMenuLessonCell", for: indexPath) as! HomeMenuLessonCell
            if let l = self.shownCells[0][0] as? HomeScreenLesson {
                cell.lessons(l)
            }
            return cell
        case .menus:
            let cell = self.reusableCell(withStyle: .default, reuseIdentifier: "Centralis.DefaultCell")
            let store = self.shownCells[1][indexPath.row] as! SimpleStore
            cell.textLabel?.text = store.name
            cell.textLabel?.textColor = .centralisTintColor
            cell.accessoryType = .disclosureIndicator
            cell.backgroundColor = .centralisBackgroundColor
            return cell
        case .settings:
            let cell = self.reusableCell(withStyle: .default, reuseIdentifier: "Centralis.DefaultCell")
            let store = self.shownCells[2][indexPath.row] as! SimpleStore
            cell.textLabel?.text = store.name
            cell.textLabel?.textColor = .centralisTintColor
            cell.accessoryType = .disclosureIndicator
            cell.backgroundColor = .centralisBackgroundColor
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch self.section(section) {
        case .lessons: return "Lessons"
        case .settings: return nil
        case .menus: return "Menus"
        }
    }

    private func section(_ section: Int) -> HomeViewController.section {
        if section == 2 || (self.shownCells[0].isEmpty && section == 1) {
            return .settings
        } else if self.shownCells[0].isEmpty || section == 1 {
            return .menus
        } else {
            return .lessons
        }
    }
    
    private enum section {
        case lessons
        case menus
        case settings
    }
}

