//
//  TintColorPicker.swift
//  Aemulo
//
//  Created by Andromeda on 09/04/2021.
//

import UIKit

class TintColorPicker: UITableViewCell  {
    
    var switcherView: UIView = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: "Centralis.TintColorPicker")
        self.selectionStyle = .gray
        
        self.contentView.addSubview(switcherView)
        self.textLabel?.text = "Tint Colour"
        switcherView.translatesAutoresizingMaskIntoConstraints = false
        switcherView.layer.masksToBounds = true

        switcherView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        switcherView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        switcherView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -20).isActive = true
        switcherView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
        switcherView.layer.cornerRadius = 10
        
        self.updateCentralisColors()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateCentralisColors),
                                               name: ThemeManager.ThemeUpdate,
                                               object: nil)
    }

    @objc private func updateCentralisColors() {
        backgroundColor = .centralisBackgroundColor
        self.textLabel?.textColor = .centralisTintColor
        switcherView.backgroundColor = .centralisTintColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
