//
//  LinksViewController.swift
//  Centralis
//
//  Created by Amy While on 06/02/2022.
//

import UIKit

class LinksViewController: CentralisDataViewController {
    
    var links = [Link]()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Links"
    }

    override public func index(_ reload: Bool = true) {
        if reload {
            tableView.beginUpdates()
        }
        var links = Array(PersistenceDatabase.shared.links.values)
        links.sort { $0.position < $1.position }
        if links != self.links {
            self.links = links
            if reload {
                tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
            }
        }
        if reload {
            tableView.endUpdates()
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        links.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.reusableCell(withStyle: .subtitle, reuseIdentifier: "Centralis.LinkCell")
        let link = links[indexPath.row]
        cell.textLabel?.text = link.name
        cell.detailTextLabel?.text = link.url.absoluteString
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let link = links[indexPath.row].url
        tableView.deselectRow(at: indexPath, animated: true)
        UIApplication.shared.open(link)
    }

}
