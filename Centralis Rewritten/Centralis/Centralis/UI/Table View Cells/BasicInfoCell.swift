//
//  HomeworkCell.swift
//  Centralis
//
//  Created by Andromeda on 28/11/2021.
//

import UIKit

class BasicInfoCell: UITableViewCell, BaseTableViewCell {
    
    public weak var delegate: VariableCellDelegate?
    public class DescriptionLabel: UILabel {
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            font = UIFont.systemFont(ofSize: 12)
            textColor = .darkGray
            translatesAutoresizingMaskIntoConstraints = false
            heightAnchor.constraint(equalToConstant: 15).isActive = true
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
    
    public class DescriptionImage: UIImageView {
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            NSLayoutConstraint.activate([
                heightAnchor.constraint(equalToConstant: 10),
                widthAnchor.constraint(equalToConstant: 10)
            ])
            layer.masksToBounds = true
            layer.cornerCurve = .continuous
            layer.cornerRadius = 10 / 2
            contentMode = .scaleAspectFill
            tintColor = .lightGray
            translatesAutoresizingMaskIntoConstraints = false
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
    
    public let title: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        label.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 751), for: .vertical)
        let variableHeight = label.heightAnchor.constraint(equalToConstant: 20)
        variableHeight.priority = UILayoutPriority(rawValue: 750)
        NSLayoutConstraint.activate([
            variableHeight,
            label.heightAnchor.constraint(greaterThanOrEqualToConstant: 20)
        ])
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    public let primaryLabel = DescriptionLabel(frame: .zero)
    public let primaryImage = DescriptionImage(frame: .zero)
    
    public let secondaryLabel = DescriptionLabel(frame: .zero)
    public let secondaryImage = DescriptionImage(frame: .zero)
    
    public let tertiaryLabel = DescriptionLabel(frame: .zero)
    public let tertiaryImage = DescriptionImage(frame: .zero)
    
    public let loadingIndicator: UIActivityIndicatorView = {
        var indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.heightAnchor.constraint(equalToConstant: 15).isActive = true
        indicator.widthAnchor.constraint(equalToConstant: 15).isActive = true
        indicator.isHidden = true
        return indicator
    }()
    public lazy var loadingTopAnchor: NSLayoutConstraint = {
        var anchor = loadingIndicator.topAnchor.constraint(equalTo: tertiaryImage.bottomAnchor, constant: -10)
        anchor.priority = UILayoutPriority(rawValue: 750)
        return anchor
    }()
    
    public lazy var descriptionTextView: UITextView = {
        let view = UITextView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isEditable = false
        view.isSelectable = false
        view.isScrollEnabled = false
        view.backgroundColor = .clear
        view.textContainerInset = UIEdgeInsets.zero
        view.textContainer.lineFragmentPadding = 0
        view.textColor = .label
        return view
    }()
    public lazy var descriptionHeightAnchor: NSLayoutConstraint = {
        let heightConstant = descriptionTextView.heightAnchor.constraint(equalToConstant: 0)
        heightConstant.priority = UILayoutPriority(250)
        return heightConstant
    }()
    public lazy var descriptionVariableHeightAnchor = descriptionTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 0)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(primaryLabel)
        contentView.addSubview(primaryImage)
        contentView.addSubview(secondaryLabel)
        contentView.addSubview(secondaryImage)
        contentView.addSubview(tertiaryLabel)
        contentView.addSubview(tertiaryImage)
        contentView.addSubview(title)
        contentView.addSubview(loadingIndicator)
        contentView.addSubview(descriptionTextView)
        
        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            title.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            title.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            
            primaryImage.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            primaryImage.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 8),
            
            primaryLabel.leadingAnchor.constraint(equalTo: primaryImage.trailingAnchor, constant: 5),
            primaryLabel.trailingAnchor.constraint(equalTo: title.trailingAnchor),
            primaryLabel.centerYAnchor.constraint(equalTo: primaryImage.centerYAnchor),
            
            secondaryImage.topAnchor.constraint(equalTo: primaryImage.bottomAnchor, constant: 8),
            secondaryImage.leadingAnchor.constraint(equalTo: primaryImage.leadingAnchor),
            
            secondaryLabel.trailingAnchor.constraint(equalTo: primaryLabel.trailingAnchor),
            secondaryLabel.leadingAnchor.constraint(equalTo: primaryLabel.leadingAnchor),
            secondaryLabel.centerYAnchor.constraint(equalTo: secondaryImage.centerYAnchor),
            
            tertiaryLabel.leadingAnchor.constraint(equalTo: primaryLabel.leadingAnchor),
            tertiaryLabel.trailingAnchor.constraint(equalTo: primaryLabel.trailingAnchor),
            tertiaryLabel.centerYAnchor.constraint(equalTo: tertiaryImage.centerYAnchor),
            
            tertiaryImage.topAnchor.constraint(equalTo: secondaryImage.bottomAnchor, constant: 8),
            tertiaryImage.trailingAnchor.constraint(equalTo: primaryImage.trailingAnchor),
            tertiaryImage.leadingAnchor.constraint(equalTo: primaryImage.leadingAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            loadingTopAnchor,
 
            descriptionTextView.topAnchor.constraint(equalTo: loadingIndicator.bottomAnchor),
            descriptionTextView.leadingAnchor.constraint(equalTo: tertiaryImage.leadingAnchor),
            descriptionTextView.trailingAnchor.constraint(equalTo: primaryLabel.trailingAnchor),
            descriptionTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            descriptionHeightAnchor,
            descriptionVariableHeightAnchor
        ])
        
        descriptionVariableHeightAnchor.isActive = false
        descriptionHeightAnchor.priority = UILayoutPriority(1000)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

protocol VariableCellDelegate: AnyObject {
    func changeContentSize(_ update: () -> Void)
}
