//
//  AccountViewController.swift
//  Centralis
//
//  Created by Amy While on 23/04/2021.
//

import UIKit

class AccountViewController: BaseTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Account Info"
        self.view.tintColor = .centralisTintColor
        self.navigationController?.view.tintColor = .centralisTintColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.loadData()
    }
    
    @objc func loadData() {
        EduLink_Personal.personal { success, error in
            DispatchQueue.main.async {
                if success {
                    self.tableView.reloadData()
                } else {
                    self.error(error!)
                }
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
        errorView.retryButton.addTarget(self, action: #selector(self.loadData), for: .touchUpInside)
        if let nc = self.navigationController { errorView.startWorking(nc) }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        EduLinkAPI.shared.personal.forename == nil ? 0 : 14
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.reusableCell(withStyle: .value1, reuseIdentifier: "Centralis.AccountCell")
        cell.backgroundColor = .centralisBackgroundColor
        cell.textLabel?.textColor = .centralisTintColor
        cell.detailTextLabel?.textColor = .centralisTintColor
        let personal = EduLinkAPI.shared.personal
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Forename"
            cell.detailTextLabel?.text =  personal.forename ?? "Not Given"
        case 1:
            cell.textLabel?.text = "Surname"
            cell.detailTextLabel?.text =  personal.surname ?? "Not Given"
        case 2:
            cell.textLabel?.text = "Gender"
            cell.detailTextLabel?.text =  personal.gender ?? "Not Given"
        case 3:
            cell.textLabel?.text = "Admission Number"
            cell.detailTextLabel?.text =  personal.admission_number ?? "Not Given"
        case 4:
            cell.textLabel?.text = "Pupil Number"
            cell.detailTextLabel?.text =  personal.unique_pupil_number ?? "Not Given"
        case 5:
            cell.textLabel?.text = "Learner Number"
            cell.detailTextLabel?.text =  personal.unique_learner_number ?? "Not Given"
        case 6:
            cell.textLabel?.text = "Date of Birth"
            cell.detailTextLabel?.text =  personal.date_of_birth ?? "Not Given"
        case 7:
            cell.textLabel?.text = "Admission Date"
            cell.detailTextLabel?.text =  personal.admission_date ?? "Not Given"
        case 8:
            cell.textLabel?.text = "Email"
            cell.detailTextLabel?.text =  personal.email ?? "Not Given"
        case 9:
            cell.textLabel?.text = "Phone"
            cell.detailTextLabel?.text =  personal.phone ?? "Not Given"
        case 10:
            cell.textLabel?.text = "Form Group"
            cell.detailTextLabel?.text =  personal.form ?? "Not Given"
        case 11:
            cell.textLabel?.text = "Form Room"
            cell.detailTextLabel?.text =  personal.room_code ?? "Not Given"
        case 12:
            cell.textLabel?.text = "Teacher"
            cell.detailTextLabel?.text =  personal.form_teacher ?? "Not Given"
        case 13:
            cell.textLabel?.text = "House"
            cell.detailTextLabel?.text =  personal.house_group ?? "Not Given"
        default: break
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
