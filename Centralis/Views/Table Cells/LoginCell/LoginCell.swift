//
//  LoginCell.swift
//  Centralis
//
//  Created by Amy While on 01/12/2020.
//

import UIKit
//import libCentralis

class LoginCell: UITableViewCell {
    
    @IBOutlet weak var schoolLogo: UIImageView!
    @IBOutlet weak var schoolName: UILabel!
    @IBOutlet weak var forename: UILabel!
    @IBOutlet weak var blurView: UIView!
    @IBInspectable weak var minHeight: NSNumber! = 75
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.setup()
    }

    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        let size = super.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: horizontalFittingPriority, verticalFittingPriority: verticalFittingPriority)
        guard let minHeight = minHeight else { return size }
        return CGSize(width: size.width, height: max(size.height, (minHeight as! CGFloat)))
    }
    
    private func setup() {
        self.schoolLogo.layer.masksToBounds = true
        self.schoolLogo.layer.cornerRadius = 12.5
        self.schoolName.adjustsFontSizeToFitWidth = true
        self.forename.adjustsFontSizeToFitWidth = true
    }
}
