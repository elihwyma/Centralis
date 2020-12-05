//
//  HomeworkTable.swift
//  Centralis
//
//  Created by Amy While on 05/12/2020.
//

import UIKit

class HomeworkTable: UIView {
    
    @IBOutlet weak var tableView: UITableView!
    var context: HomeworkContext?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }
    
    private func setup() {
        self.backgroundColor = .systemGreen
    }
}
