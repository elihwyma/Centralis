//
//  CentralisDataViewController.swift
//  Centralis
//
//  Created by Amy While on 18/06/2022.
//

import UIKit

class CentralisDataViewController: BaseTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(persistenceReload), name: PersistenceDatabase.persistenceReload, object: nil)
        
        refreshControl = UIRefreshControl()
        refreshControl!.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl!.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
    
    @objc private func refresh() {
        let cancel = PersistenceDatabase.backgroundRefresh {
            Thread.mainBlock { [weak self] in
                self?.refreshControl!.endRefreshing()
            }
        }
        if !cancel {
            refreshControl!.endRefreshing()
        }
    }

    public func index(_ reload: Bool = true) {
        
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
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

}
