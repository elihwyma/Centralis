//
//  ClosureSwitchCell.swift
//  Aemulo
//
//  Created by Somica on 20/09/2021.
//

import UIKit

public class ClosureSwitchTableViewCell: UITableViewCell {
    
    public var control: UISwitch = UISwitch()
    public var amyPogLabel: UILabel = UILabel()
    public var callback: ((Bool) -> ())?
    
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

        backgroundColor = .secondaryBackgroundColor
        control.onTintColor = .tintColor
    }
    
    @objc private func didChange(sender: UISwitch!) {
        callback?(sender.isOn)
    }
    
}
