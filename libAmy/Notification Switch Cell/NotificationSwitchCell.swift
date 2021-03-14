//
//  SettingsSwitchCell.swift
//  SignalReborn
//
//  Created by Amy While on 23/09/2020.
//  Copyright © 2020 Amy While. All rights reserved.
//

import UIKit

class NotificationSwitchCell: AmyCell {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var prefsSwitch: UISwitch!

    var data: NotificationSwitchData! {
        didSet {
            self.label.text = data.title
            if let rn = EduLinkAPI.shared.defaults.object(forKey: "RegisteredNotifications") as? [String : Any] {
                if rn[data.defaultName] != nil {
                    prefsSwitch.isOn = rn[data.defaultName] as? Bool ?? data.defaultState
                    return
                }
            }
            prefsSwitch.isOn = data.defaultState
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func prefsSwitched(_ sender: Any) {
        UNUserNotificationCenter.current().getNotificationSettings() { settings in
            if settings.authorizationStatus == .denied {
                let ac = UIAlertController(title: "Notifications Denied", message: "Notifications have been disabled for this app. You can change this in Settings.", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                ac.addAction(UIAlertAction(title: "Settings", style: .default) { action in
                    guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
                    if UIApplication.shared.canOpenURL(settingsUrl) {
                        UIApplication.shared.open(settingsUrl)
                    }
                })
                DispatchQueue.main.async {
                    self.prefsSwitch.isOn = false
                    self.data.vc.present(ac, animated: true)
                }
            }
            var notificationPreferences = EduLinkAPI.shared.defaults.dictionary(forKey: "RegisteredNotifications") ?? [String : Any]()
            notificationPreferences[self.data.defaultName] = self.prefsSwitch.isOn
            EduLinkAPI.shared.defaults.setValue(notificationPreferences, forKey: "RegisteredNotifications")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: self.data.defaultName), object: nil)
        }
    }
}
