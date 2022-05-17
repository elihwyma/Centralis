//
//  MessagesViewController.swift
//  Centralis
//
//  Created by Somica on 11/01/2022.
//

import UIKit

class MessagesViewController: BaseTableViewController {
    
    var messages = [Message]()
    var showArchived: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(MessageTableViewCell.self, forCellReuseIdentifier: "Centralis.MessageCell")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Mark all as read", style: .plain, target: self, action: #selector(markAllAsRead))
        NotificationCenter.default.addObserver(self, selector: #selector(persistenceReload), name: PersistenceDatabase.persistenceReload, object: nil)
    }
    
    private func index(_ reload: Bool = true) {
        if reload {
            tableView.beginUpdates()
        }
        var messages = Array(PersistenceDatabase.shared.messages.values)
        messages.sort { $0.date ?? Date() > $1.date ?? Date() }
        if !showArchived {
            messages.removeAll { $0.archived }
        }
        if messages != self.messages {
            self.messages = messages
            if reload {
                tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
            }
        }
        if reload {
            tableView.endUpdates()
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewController = MessageViewController(message: messages[indexPath.row])
        if let cell = tableView.cellForRow(at: indexPath) as? MessageTableViewCell {
            cell.unreadView.backgroundColor = .clear
        }
        navigationController?.pushViewController(viewController, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}