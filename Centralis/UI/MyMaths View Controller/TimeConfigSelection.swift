//
//  NFCByteSelection.swift
//  Aemulo
//
//  Created by Somica on 20/09/2021.
//

import UIKit

public protocol TimeConfigSelection: AnyObject {
    func didSelect(config: TimeConfig)
}

public enum TimeConfig: Int {
    case instant = 0
    case medium = 1
    case long = 2
}

final public class TimeConfigSelectionCell: UITableViewCell {
    
    public lazy var segmentedControl: UISegmentedControl = {
        let view = UISegmentedControl(items: ["Instant",
                                              "5 - 7 minutes",
                                              "7 - 12 minutes"])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(selectedSegment(sender:)), for: .valueChanged)
        return view
    }()
    
    public weak var delegate: TimeConfigSelection?
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        contentView.addSubview(segmentedControl)
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            segmentedControl.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            segmentedControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            segmentedControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -0)
        ])
    }
    
    @objc private func selectedSegment(sender: UISegmentedControl) {
        if let timeConfig = TimeConfig(rawValue: sender.selectedSegmentIndex) {
            delegate?.didSelect(config: timeConfig)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
