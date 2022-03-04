//
//  CateringViewController.swift
//  Centralis
//
//  Created by Somica on 03/03/2022.
//

import UIKit

class CateringViewController: BaseTableViewController {
    
    private var catering: Catering = Catering(balance: 0, transactions: [])

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        title = "Balanace: \(catering.stringBalance)"
        NotificationCenter.default.addObserver(self, selector: #selector(persistenceReload), name: PersistenceDatabase.persistenceReload, object: nil)
    }

    private func index(_ reload: Bool = true) {
        if reload {
            //tableView.beginUpdates()
        }
        
        let catering = PersistenceDatabase.shared.catering
        let originalCount = self.catering.transactions.isEmpty ? 1 : self.catering.transactions.count
        title = "Balanace: \(catering.stringBalance)"
        catering.transactions .sort { $0.date! > $1.date! }
        catering.transactions.forEach { $0.items.sort { $0.item < $1.item } }
        if catering.transactions != self.catering.transactions {
            self.catering = catering
            if reload {
                /*
                let newCount = catering.transactions.isEmpty ? 1 : catering.transactions.count
                NSLog("[Centralis] \(originalCount) \(newCount)")
                if originalCount == newCount {
                    tableView.reloadSections(IndexSet(integersIn: 0..<newCount), with: .automatic)
                } else if originalCount > newCount {
                    tableView.deleteSections(IndexSet(integersIn: newCount..<originalCount), with: .automatic)
                    tableView.reloadSections(IndexSet(integersIn: 0..<newCount), with: .automatic)
                } else if newCount > originalCount {
                    let diff = newCount - originalCount
                    tableView.insertSections(IndexSet(integersIn: originalCount..<newCount), with: .automatic)
                    tableView.reloadSections(IndexSet(integersIn: 0..<diff), with: .automatic)
                }
                 */
                tableView.reloadData()
            }
        }
        if reload {
            //tableView.endUpdates()
        }
    }
    
    @objc private func persistenceReload() {
        if !Thread.isMainThread {
            DispatchQueue.main.async { [weak self] in
                self?.persistenceReload()
            }
            return
        }
        index()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        index()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        catering.transactions.isEmpty ? 1 : catering.transactions.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        catering.transactions.isEmpty ? 1 : catering.transactions[section].items.count
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm E, d MMM y"
        return formatter
    }()
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        catering.transactions.isEmpty ? nil : dateFormatter.string(from: catering.transactions[section].date!)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if catering.transactions.isEmpty {
            let cell = self.reusableCell(withStyle: .default, reuseIdentifier: "Catering.NoTransactions")
            cell.isUserInteractionEnabled = true
            cell.textLabel?.text = "No Transactions"
            return cell
        } else {
            let cell = self.reusableCell(withStyle: .value1, reuseIdentifier: "Catering.ItemCell")
            let item = catering.transactions[indexPath.section].items[indexPath.row]
            cell.textLabel?.text = item.item
            cell.detailTextLabel?.text = item.stringPrice
            cell.isUserInteractionEnabled = false
            return cell
        }
    }

}
