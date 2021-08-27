//
//  MenuTableView.swift
//  Centralis
//
//  Created by Andromeda on 27/08/2021.
//

import UIKit

class MenuTableView: UITableView {
    
    public var menus = [String]()
    
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

    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: .plain)
        
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: 210).isActive = true
        backgroundColor = .centralisViewColor
        tintColor = .centralisTintColor
        separatorStyle = .none
        dataSource = self
        delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func reloadData() {
        menus.removeAll()
        #if DEBUG
        menus = EduLinkAPI.shared.authorisedUser.personalMenus.map { $0.name }
        #else
        for m in EduLinkAPI.shared.authorisedUser.personalMenus {
            if completedMenus.contains(m.name) {
                menus.append(m.name)
            }
        }
        #endif
        menus.insert("Today", at: 0)
        super.reloadData()
    }
}

extension MenuTableView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        return
    }
    
}

extension MenuTableView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        menus.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = MenuHeaderCell(style: .default, reuseIdentifier: "Centralis.HomeHeaderCell")
            let shared = EduLinkAPI.shared
            if let userData = shared.authorisedUser.avatar,
               let userImage = UIImage(data: userData) {
                cell.userPicture.image = userImage
            }
            if let name = shared.authorisedUser.forename,
               let surname = shared.authorisedUser.surname {
                cell.username.text = "\(name) \(surname)"
            }
            return cell
        } else {
            let cell = tableView.reusableCell(withStyle: .default, reuseIdentifier: "Centralis.HomeMenuCell")
            cell.textLabel?.text = menus[indexPath.row - 1]
            cell.textLabel?.adjustsFontSizeToFitWidth = true
            cell.accessoryType = .disclosureIndicator
            return cell
        }
    }
    
    
}
	
