//
//  SettingsSwitchCell.swift
//  SignalReborn
//
//  Created by Amy While on 23/09/2020.
//  Copyright © 2020 Amy While. All rights reserved.
//

import UIKit

class SettingsSwitchCell: AmyCell {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var prefsSwitch: UISwitch!

    var data: SettingsSwitchData! {
        didSet {
            self.label.text = data.title
            if EduLinkAPI.shared.defaults.object(forKey: data.defaultName) != nil {
                prefsSwitch.isOn = EduLinkAPI.shared.defaults.bool(forKey: data.defaultName)
            } else {
                prefsSwitch.isOn = data.defaultState
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func prefsSwitched(_ sender: Any) {
        EduLinkAPI.shared.defaults.setValue(prefsSwitch.isOn, forKey: data.defaultName)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: data.defaultName), object: nil)
    }
}
