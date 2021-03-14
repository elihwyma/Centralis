//
//  ButtonCell.swift
//  SignalReborn
//
//  Created by Amy While on 23/09/2020.
//  Copyright © 2020 Amy While. All rights reserved.
//

import UIKit

class ButtonCell: AmyCell {
    
    @IBOutlet weak var control: UIControl!
    @IBOutlet weak var label: UILabel!
    
    var data: ButtonCellData! {
        didSet {
            self.label.text = data.title
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.meta()
    }
    
    private func meta() {
        self.control.addTarget(self, action: #selector(pressed), for: .touchUpInside)
    }

    
    @objc private func pressed() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: data.notificationName), object: nil)
    }
}
