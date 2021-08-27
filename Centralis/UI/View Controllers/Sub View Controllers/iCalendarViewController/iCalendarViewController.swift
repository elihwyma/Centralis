//
//  iCalendarViewController.swift
//  Centralis
//
//  Created by Somica on 21/05/2021.
//

import UIKit

class iCalendarViewController: BaseTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "iCalendar"
        self.view.tintColor = .centralisTintColor
        self.navigationController?.view.tintColor = .centralisTintColor
        self.tableView.register(UINib(nibName: "LoginCell", bundle: nil), forCellReuseIdentifier: "Centralis.LoginCell")
        
        EduLink_ICalendar.calendar { success, error in
            if success {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        EduLinkAPI.shared.calendars.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let calendar = EduLinkAPI.shared.calendars[indexPath.row]
        if let url = calendar.url {
            UIApplication.shared.open(url)
        } else {
            let alert = UIAlertController(title: "No URL", message: "No URL has been supplied for this Calendar", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Close", style: .cancel))
            self.present(alert, animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.reusableCell(withStyle: .default, reuseIdentifier: "Centralis.iCalendarCell")
        let calendar = EduLinkAPI.shared.calendars[indexPath.row]
        cell.textLabel?.text = calendar.description
        cell.backgroundColor = .centralisBackgroundColor
        cell.textLabel?.textColor = .centralisTintColor
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}
