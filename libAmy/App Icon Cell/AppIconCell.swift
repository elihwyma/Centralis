//
//  appIconCell.swift
//  dra1n
//
//  Created by Amy While on 14/08/2020.
//

import UIKit

class AppIconCell: AmyCell {
    
    var data: AppIconCellData! {
        didSet {
            self.iconImage.image = UIImage(named: data.image)
            self.iconName.text = data.title
            self.refreshView()
        }
    }
   
    @objc private func pressed() {
        if data.isDefault {
            UIApplication.shared.setAlternateIconName(nil)
        } else {
            UIApplication.shared.setAlternateIconName(data.image)
        }
        NotificationCenter.default.post(name: .AppIconChanged, object: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.meta()
    }
    
    @IBInspectable weak var minHeight: NSNumber! = 75
       
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        let size = super.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: horizontalFittingPriority, verticalFittingPriority: verticalFittingPriority)
        guard let minHeight = minHeight else { return size }
        return CGSize(width: size.width, height: max(size.height, (minHeight as! CGFloat)))
    }
    
    @objc private func refreshView() {
        if data.isDefault && UIApplication.shared.alternateIconName == nil || data.image == UIApplication.shared.alternateIconName {
            //self.isCurrentIcon.backgroundColor = ThemeManager.tintColor
        } else {
            self.isCurrentIcon.backgroundColor = .clear
        }
    }
    
    private func meta() {
        self.iconImage.layer.cornerRadius = self.iconImage.frame.height / 2
        self.iconImage.layer.masksToBounds = true
        self.isCurrentIcon.layer.masksToBounds = true
        self.isCurrentIcon.layer.cornerRadius = self.isCurrentIcon.frame.height / 2
        self.control.addTarget(self, action: #selector(pressed), for: .touchUpInside)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshView), name: .AppIconChanged, object: nil)
    }
    
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var iconName: UILabel!
    @IBOutlet weak var control: UIControl!
    @IBOutlet weak var isCurrentIcon: UIView!
}

fileprivate extension NSNotification.Name {
    static let AppIconChanged = Notification.Name("AppIconChanged")
}
