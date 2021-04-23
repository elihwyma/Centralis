//
//  SettingsSwitchCell.swift
//  Sileo
//
//  Created by Amy on 16/03/2021.
//  Copyright © 2021 Amy While. All rights reserved.
//

import UIKit

class SettingsSwitchTableViewCell: UITableViewCell {
    
    private var control: UISwitch = UISwitch()
    public var amyPogLabel: UILabel = UILabel()
    var fallback = false
    
    var defaultKey: String? {
        didSet {
            if let key = defaultKey { control.isOn = EduLinkAPI.shared.defaults.optionalBool(key, fallback: fallback) }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        

        self.selectionStyle = .none
        amyPogLabel.adjustsFontSizeToFitWidth = true
        self.contentView.addSubview(control)
        self.contentView.addSubview(amyPogLabel)
        
        amyPogLabel.translatesAutoresizingMaskIntoConstraints = false
        control.translatesAutoresizingMaskIntoConstraints = false
        
        control.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        control.addTarget(self, action: #selector(self.didChange(sender:)), for: .valueChanged)
        
        amyPogLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        amyPogLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
        control.leadingAnchor.constraint(equalTo: amyPogLabel.trailingAnchor, constant: 5).isActive = true
        control.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor).isActive = true
        amyPogLabel.setContentHuggingPriority(UILayoutPriority(251), for: .horizontal)
        amyPogLabel.setContentHuggingPriority(UILayoutPriority(251), for: .vertical)
        amyPogLabel.setContentCompressionResistancePriority(UILayoutPriority(749), for: .horizontal)

        self.updateCentralisColors()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateCentralisColors),
                                               name: ThemeManager.ThemeUpdate,
                                               object: nil)
    }
    
    @objc private func didChange(sender: UISwitch!) {
        if let key = defaultKey {
            EduLinkAPI.shared.defaults.setValue(sender.isOn, forKey: key); NotificationCenter.default.post(name: Notification.Name(key), object: nil)
        }
    }
    
    @objc private func updateCentralisColors() {
        amyPogLabel.textColor = .centralisTintColor
        control.onTintColor = .centralisTintColor
        backgroundColor = .centralisBackgroundColor
    }
}
