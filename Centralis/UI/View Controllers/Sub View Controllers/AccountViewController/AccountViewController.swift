//
//  AccountViewController.swift
//  Centralis
//
//  Created by Amy While on 23/04/2021.
//

import UIKit

class AccountViewController: BaseTableViewController {
    
    var personal = [String: String]()
    var sortedKeys = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Account Info"
        self.view.tintColor = .centralisTintColor
        self.navigationController?.view.tintColor = .centralisTintColor
        self.personalParser()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.loadData()
    }
    
    @objc func loadData() {
        EduLink_Personal.personal { success, error in
            DispatchQueue.main.async {
                if success {
                    self.personalParser()
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
    
    private func personalParser() {
        personal.removeAll()
        guard let personal = EduLinkAPI.shared.personal else { return }
        let mirror = Mirror(reflecting: personal)
        for child in mirror.children {
            if child.label == "id" || child.label == "address" { continue }
            if let value = child.value as? String,
               let label = child.label {
                let name = personal.name(label)
                self.personal[name] = value
                continue
            }
            if let value = child.value as? Employee,
               !value.name.isEmpty,
               let label = child.label {
                let name = personal.name(label)
                self.personal[name] = value.name
                continue
            }
        }
        let sorted = self.personal.sorted(by: { $0.key < $1.key })
        self.sortedKeys = Array(sorted.map({ $0.key }))
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sortedKeys.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.reusableCell(withStyle: .value1, reuseIdentifier: "Centralis.AccountCell")
        cell.backgroundColor = .centralisBackgroundColor
        cell.textLabel?.textColor = .centralisTintColor
        cell.detailTextLabel?.textColor = .centralisTintColor
        cell.selectionStyle = .none
        let key = sortedKeys[indexPath.row]
        cell.textLabel?.text = key
        cell.detailTextLabel?.text = personal[key]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
