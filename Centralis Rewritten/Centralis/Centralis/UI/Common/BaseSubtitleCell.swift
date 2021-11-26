//
//  BaseSubtitleCell.swift
//  Aemulo
//
//  Created by Andromeda on 26/05/2021.
//

import UIKit

public class BaseSubtitleCell: UITableViewCell {
    
    public var cellImage = UIImageView()
    public var title = UILabel()
    public var subtitle = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(cellImage)
        cellImage.translatesAutoresizingMaskIntoConstraints = false
        cellImage.heightAnchor.constraint(equalToConstant: 30).isActive = true
        cellImage.widthAnchor.constraint(equalToConstant: 30).isActive = true
        cellImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5).isActive = true
        cellImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
        contentView.addSubview(title)
        title.translatesAutoresizingMaskIntoConstraints = false
        title.heightAnchor.constraint(equalToConstant: 20).isActive = true
        title.leadingAnchor.constraint(equalTo: cellImage.trailingAnchor, constant: 6.5).isActive = true
        title.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5).isActive = true
        title.font = UIFont.systemFont(ofSize: 18)
        title.adjustsFontSizeToFitWidth = true
        
        contentView.addSubview(subtitle)
        subtitle.translatesAutoresizingMaskIntoConstraints = false
        subtitle.heightAnchor.constraint(equalToConstant: 13).isActive = true
        subtitle.leadingAnchor.constraint(equalTo: cellImage.trailingAnchor, constant: 6.5).isActive = true
        contentView.trailingAnchor.constraint(equalTo: subtitle.trailingAnchor, constant: 2.5).isActive = true
        contentView.bottomAnchor.constraint(equalTo: subtitle.bottomAnchor, constant: 7.5).isActive = true
        subtitle.font = UIFont.systemFont(ofSize: 12, weight: .light)
        subtitle.adjustsFontSizeToFitWidth = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        let size = super.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: horizontalFittingPriority, verticalFittingPriority: verticalFittingPriority)
        return CGSize(width: size.width, height: max(size.height, (NSNumber(45) as! CGFloat)))
    }
    
}
