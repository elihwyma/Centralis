//
//  MessageViewController.swift
//  Centralis
//
//  Created by Somica on 14/01/2022.
//

import UIKit

class MessageViewController: UIViewController {
    
    public let message: Message
    init(message: Message) {
        self.message = message
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        return label
    }()
    
    private var dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    private var subjectLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 27, weight: .bold)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var bodyTextView: UITextView = {
        let view = UITextView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isEditable = false
        view.isScrollEnabled = false
        view.backgroundColor = .clear
        view.textContainerInset = UIEdgeInsets.zero
        view.textContainer.lineFragmentPadding = 0
        view.textColor = .label
        
        let variableConstraint = view.heightAnchor.constraint(equalToConstant: 0)
        variableConstraint.priority = UILayoutPriority(rawValue: 250)
        NSLayoutConstraint.activate([
            variableConstraint,
            view.heightAnchor.constraint(greaterThanOrEqualToConstant: 0)
        ])
        return view
    }()
    
    private var embedStackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        let variableConstraint = view.heightAnchor.constraint(equalToConstant: 0)
        variableConstraint.priority = UILayoutPriority(rawValue: 250)
        NSLayoutConstraint.activate([
            variableConstraint,
            view.heightAnchor.constraint(greaterThanOrEqualToConstant: 0)
        ])
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        view.addSubview(scrollView)
        
        let senderStackView = UIStackView()
        senderStackView.axis = .horizontal
        senderStackView.spacing = 8
        senderStackView.addArrangedSubview(teacherView)
        senderStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let senderNameStackView = UIStackView()
        senderNameStackView.axis = .vertical
        senderStackView.alignment = .leading
        senderNameStackView.addArrangedSubview(senderLabel)
        senderNameStackView.addArrangedSubview(dateLabel)
        senderStackView.addArrangedSubview(senderNameStackView)
        senderNameStackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(senderStackView)
        
        let separatorView = UIView()
        separatorView.backgroundColor = .separator
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(separatorView)
        stackView.addArrangedSubview(subjectLabel)
        stackView.addArrangedSubview(bodyTextView)
        stackView.addArrangedSubview(embedStackView)
        
        NSLayoutConstraint.activate([
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            
            scrollView.contentLayoutGuide.topAnchor.constraint(equalTo: stackView.topAnchor),
            scrollView.contentLayoutGuide.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            scrollView.contentLayoutGuide.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            scrollView.contentLayoutGuide.bottomAnchor.constraint(equalTo: stackView.bottomAnchor),
            
            scrollView.frameLayoutGuide.widthAnchor.constraint(equalTo: stackView.widthAnchor)
        ])
        navigationItem.largeTitleDisplayMode = .never
        layoutMessage()
        
        view.backgroundColor = .backgroundColor
    }
    
    private func layoutMessage() {
        teacherView.image = Photos.shared.getImage(for: message.sender.id, size: teacherView.bounds.size, { [weak self] image in
            guard let self = self else { return }
            Thread.mainBlock {
                self.teacherView.image = image
            }
        })
        subjectLabel.text = message.subject
        senderLabel.text = message.sender.name
        if let date = message.date {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            dateLabel.text = formatter.string(from: date)
        } else {
            dateLabel.text = "No Date"
        }
        if let body = message.body {
            if let attributedString = try? NSMutableAttributedString(html: body) {
                bodyTextView.attributedText = attributedString
                print(body)
            } else {
                bodyTextView.text = "Failed to parse message body"
            }
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if let body = message.body {
            if let attributedString = try? NSMutableAttributedString(html: body) {
                bodyTextView.attributedText = attributedString
            } else {
                bodyTextView.text = "Failed to parse message body"
            }
        }
    }
}
