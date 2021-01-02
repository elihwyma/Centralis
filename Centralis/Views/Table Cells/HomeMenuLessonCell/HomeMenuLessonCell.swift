//
//  HomeMenuLessonCell.swift
//  Centralis
//
//  Created by Amy While on 02/01/2021.
//

import UIKit

class HomeMenuLessonCell: UITableViewCell {

    @IBOutlet weak var current: QuickLessonView!
    @IBOutlet weak var upcoming: QuickLessonView!
    @IBInspectable weak var minHeight: NSNumber! = 150
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        let size = super.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: horizontalFittingPriority, verticalFittingPriority: verticalFittingPriority)
        guard let minHeight = minHeight else { return size }
        return CGSize(width: size.width, height: max(size.height, (minHeight as! CGFloat)))
    }
}
