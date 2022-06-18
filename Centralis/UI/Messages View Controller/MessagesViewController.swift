//
//  MessagesViewController.swift
//  Centralis
//
//  Created by Somica on 11/01/2022.
//

import UIKit

class MessagesViewController: CentralisDataViewController {
    
    var messages = [Message]()
    var showArchived: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emptyLabel.text = "No Messages"
        tableView.register(MessageTableViewCell.self, forCellReuseIdentifier: "Centralis.MessageCell")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Mark all as read", style: .plain, target: self, action: #selector(markAllAsRead))
    }
    
    override public func index(_ reload: Bool = true) {
        var messages = Array(PersistenceDatabase.shared.messages.values)
        messages.sort { $0.date ?? Date() > $1.date ?? Date() }
        if !showArchived {
            messages.removeAll { $0.archived }
        }
        self.messages = messages
        emptyLabel.isHidden = !messages.isEmpty
        if reload {
            tableView.reloadData()
        }
    }
    
    public func refreshReadState() {
        for cell in self.tableView.visibleCells as? [MessageTableViewCell] ?? [] {
            guard let message = cell.message else { continue }
            cell.unreadView.backgroundColor = message.read == nil ? .tintColor : .clear
        }
    }
    
    @objc private func markAllAsRead() {
        Message.markAllAsRead {}
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Centralis.MessageCell", for: indexPath) as! MessageTableViewCell
        cell.set(message: messages[indexPath.row])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewController = MessageViewController(message: messages[indexPath.row])
        if let cell = tableView.cellForRow(at: indexPath) as? MessageTableViewCell {
            cell.unreadView.backgroundColor = .clear
        }
        navigationController?.pushViewController(viewController, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
