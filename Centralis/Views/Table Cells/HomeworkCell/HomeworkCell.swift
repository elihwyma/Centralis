//
//  HomeworkCell.swift
//  Centralis
//
//  Created by Amy While on 05/12/2020.
//

import UIKit

class HomeworkCell: UITableViewCell {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var completedLabel: UILabel!
    @IBOutlet weak var completedView: UIView!
    var att: NSMutableAttributedString?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setup()
    }
    
    private func setup() {
        self.att = NSMutableAttributedString()
        self.completedView.layer.masksToBounds = true
        self.completedView.layer.cornerRadius = self.completedView.frame.height / 2
    }
}
