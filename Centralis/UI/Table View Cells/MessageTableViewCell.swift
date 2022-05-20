//
//  MessageTableViewCell.swift
//  Centralis
//
//  Created by Amy While on 13/01/2022.
//

import UIKit

class MessageTableViewCell: UITableViewCell, BaseTableViewCell {
    
    public var message: Message?
    
    private var teacherView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 45),
            view.widthAnchor.constraint(equalToConstant: 45)
        ])
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 45 / 2
        view.layer.masksToBounds = true
        view.layer.cornerCurve = .continuous
        return view
    }()
    
    private var senderLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        return label
    }()
    
    private var subjectLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    private var dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 11, weight: .light)
        return label
    }()
    
    public var unreadView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 6.5),
            view.widthAnchor.constraint(equalToConstant: 6.5)
        ])
        view.layer.cornerRadius = 6.5 / 2
        view.layer.masksToBounds = true
        view.layer.cornerCurve = .continuous
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .secondaryBackgroundColor
        
        let rootStackView = UIStackView()
        rootStackView.translatesAutoresizingMaskIntoConstraints = false
        rootStackView.axis = .horizontal
        rootStackView.alignment = .center
        rootStackView.distribution = .fill
        rootStackView.spacing = 4
        contentView.addSubview(rootStackView)
        
        let labelStackView = UIStackView()
        labelStackView.translatesAutoresizingMaskIntoConstraints = false
        labelStackView.axis = .vertical
        labelStackView.alignment = .leading
        labelStackView.distribution = .fill
        labelStackView.addArrangedSubview(senderLabel)
        labelStackView.addArrangedSubview(subjectLabel)
        labelStackView.addArrangedSubview(dateLabel)
        
        rootStackView.addArrangedSubview(unreadView)
        rootStackView.addArrangedSubview(teacherView)
        rootStackView.addArrangedSubview(labelStackView)
        
        NSLayoutConstraint.activate([
            rootStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            rootStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            rootStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            rootStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func set(message: Message) {
        guard message != self.message else { return }
        self.message = message
        senderLabel.text = message.sender.name
        subjectLabel.text = message.subject
        
        if let date = message.date {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            dateLabel.text = formatter.string(from: date)
        } else {
            dateLabel.text = "No Date"
        }
        unreadView.backgroundColor = message.read == nil ? .tintColor : .clear
        teacherView.image = Photos.shared.getImage(for: message.sender.id, size: teacherView.bounds.size, { [weak self] image in
            guard let self = self,
                  self.message == message else { return }
            Thread.mainBlock {
                self.teacherView.image = image
            }
        })
    }
    
    func leadingSwipeActionsConfiguration() -> UISwipeActionsConfiguration? {
        if message?.read != nil { return nil }
        let _message = message
        let mark = UIContextualAction(style: .normal, title: "Read") { [weak self] _, _, completion in
            guard let self = self,
                  let message = self.message,
                  message == _message else { return }
            message.markAsRead { [weak self] in
                guard self?.message == _message else { return }
                Thread.mainBlock {
                    self?.unreadView.backgroundColor = .clear
                }
            }
            completion(true)
        }
        mark.backgroundColor = .systemBlue
        mark.image = UIImage(systemName: "envelope.badge")
        return UISwipeActionsConfiguration(actions: [mark])
    }
}
