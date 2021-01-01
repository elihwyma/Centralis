//
//  HomeViewController.swift
//  Centralis
//
//  Created by Amy While on 01/12/2020.
//

import UIKit
import libCentralis

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
    private var shownMenus = [SimpleStore]()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "\(EduLinkAPI.shared.authorisedUser.forename ?? "") \(EduLinkAPI.shared.authorisedUser.surname ?? "")"
        if EduLinkAPI.shared.authorisedUser.authToken != nil {
            self.refreshStatus()
        }
    }
    
    private func menuOrganising() {
        self.shownMenus.removeAll()
        #if DEBUG
        self.shownMenus = EduLinkAPI.shared.authorisedUser.personalMenus
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
                    #if DEBUG
                    self.title = "Amy"
                    #else
                    self.title = "\(EduLinkAPI.shared.authorisedUser.forename!) \(EduLinkAPI.shared.authorisedUser.surname!)"
                    #endif
                } else {
                    self.delegateLoginError(error!)
                }
            }
        })
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
                if success {
                    #warning("Yeah status needs sorting out here")
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
        let menu = shownMenus[indexPath.row]
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
        switch shownMenus[indexPath.row].name {
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
        if self.shownMenus.count == 0 { self.tableView.isHidden = true} else { self.tableView.isHidden = false }
        return shownMenus.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Centralis.HomeMenuCell", for: indexPath) as! HomeMenuCell
        let menu = self.shownMenus[indexPath.row]
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
        //cell.contentView.layer.masksToBounds = true
        //cell.contentView.layer.cornerRadius = 10.0
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let vw = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 40))
        let label = UILabel(frame: CGRect(x: 0, y: 10, width: tableView.frame.width, height: 20))
        label.adjustsFontSizeToFitWidth = true
        let boldAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 20, weight: .bold),
        ]
        label.attributedText = NSAttributedString(string: "Menus", attributes: boldAttributes)
        vw.addSubview(label)
        return vw
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Top corners
        let maskPathTop = UIBezierPath(roundedRect: cell.contentView.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 10.0, height: 10.0))
        let shapeLayerTop = CAShapeLayer()
        shapeLayerTop.frame = cell.contentView.bounds
        shapeLayerTop.path = maskPathTop.cgPath

        //Bottom corners
        let maskPathBottom = UIBezierPath(roundedRect: cell.contentView.bounds, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: 5.0, height: 5.0))
        let shapeLayerBottom = CAShapeLayer()
        shapeLayerBottom.frame = cell.contentView.bounds
        shapeLayerBottom.path = maskPathBottom.cgPath

        // All corners
        let maskPathAll = UIBezierPath(roundedRect: cell.contentView.bounds, byRoundingCorners: [.topLeft, .topRight, .bottomRight, .bottomLeft], cornerRadii: CGSize(width: 5.0, height: 5.0))
        let shapeLayerAll = CAShapeLayer()
        shapeLayerAll.frame = cell.contentView.bounds
        shapeLayerAll.path = maskPathAll.cgPath

        if indexPath.row == 0 && indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            cell.contentView.layer.mask = shapeLayerAll
        } else if indexPath.row == 0 {
            cell.contentView.layer.mask = shapeLayerTop
        } else if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            cell.contentView.layer.mask = shapeLayerBottom
        }
    }
}
