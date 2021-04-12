//
//  HomeMenuCell.swift
//  Centralis
//
//  Created by AW on 01/01/2021.
//

import UIKit

class HomeMenuCell: UITableViewCell {
    
    @IBInspectable weak var minHeight: NSNumber! = 75
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var name: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.name.adjustsFontSizeToFitWidth = true
    }

    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        let size = super.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: horizontalFittingPriority, verticalFittingPriority: verticalFittingPriority)
        guard let minHeight = minHeight else { return size }
        return CGSize(width: size.width, height: max(size.height, (minHeight as! CGFloat)))
    }
    
}
