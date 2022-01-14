//
//  MessagesViewController.swift
//  Centralis
//
//  Created by Somica on 11/01/2022.
//

import UIKit

class MessagesViewController: BaseTableViewController {
    
    var messages = [Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(MessageTableViewCell.self, forCellReuseIdentifier: "Centralis.MessageCell")
    }
    
    private func index(_ reload: Bool = true) {
        if reload {
            tableView.beginUpdates()
        }
        var messages = Array(PersistenceDatabase.shared.messages.values)
        messages.sort { $0.date ?? Date() > $1.date ?? Date() }
        self.messages = messages
        if reload {
            tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
            tableView.endUpdates()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        index()
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Centralis.MessageCell", for: indexPath) as! MessageTableViewCell
        cell.set(message: messages[indexPath.row])
        return cell
    }
}
