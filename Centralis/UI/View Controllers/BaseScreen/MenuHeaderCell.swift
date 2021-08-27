//
//  MenuHeaderCell.swift
//  Centralis
//
//  Created by Andromeda on 27/08/2021.
//

import UIKit

class MenuHeaderCell: UITableViewCell {
    
    public var userPicture: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 50),
            view.widthAnchor.constraint(equalToConstant: 50)
        ])
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 25
        view.layer.cornerCurve = .continuous
        return view
    }()
    
    public var username: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 20).isActive = true
        view.adjustsFontSizeToFitWidth = true
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(userPicture)
        contentView.addSubview(username)
        selectionStyle = .none
        backgroundColor = .centralisViewColor
        
        NSLayoutConstraint.activate([
            userPicture.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 7.5),
            userPicture.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 7.5),

            username.topAnchor.constraint(equalTo: userPicture.bottomAnchor, constant: 7.5),
            username.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15),
            username.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            username.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
