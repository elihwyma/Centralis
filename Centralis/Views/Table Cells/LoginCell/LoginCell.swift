//
//  LoginCell.swift
//  Centralis
//
//  Created by Amy While on 01/12/2020.
//

import UIKit

class LoginCell: UITableViewCell {
    
    @IBOutlet weak var schoolLogo: UIImageView!
    @IBOutlet weak var schoolName: UILabel!
    @IBOutlet weak var forename: UILabel!
    @IBOutlet weak var blurView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.setup()
    }
    
    private func setup() {
        self.schoolLogo.layer.masksToBounds = true
        self.schoolLogo.layer.cornerRadius = 12.5
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 15
        self.schoolName.adjustsFontSizeToFitWidth = true
        self.forename.adjustsFontSizeToFitWidth = true
    }
}
