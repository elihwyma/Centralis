//
//  MessageViewController.swift
//  Centralis
//
//  Created by Somica on 14/01/2022.
//

import UIKit
import QuickLook
import Evander

class MessageViewController: UIViewController {
    
    public let message: Message
    private var targetURL: URL?
    private var activeLock: Bool = false
    
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
        view.isUserInteractionEnabled = true
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
    
    @objc private func didBecomeActive() {
        if activeLock {
            guard let body = message.body else { return }
            if let attributedString = try? NSMutableAttributedString(html: body) {
                self.bodyTextView.attributedText = attributedString
            } else {
                self.bodyTextView.text = "Failed to parse message body"
            }
            activeLock = false
        }
    }
    
    private func layoutMessage() {
        if !Thread.isMainThread {
            DispatchQueue.main.async { [weak self] in
                self?.layoutMessage()
            }
            return
        }
        if message.read == nil {
            message.markAsRead {}
        }
        
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
        
        if UIApplication.shared.applicationState == .active {
            if let body = message.body {
                if let attributedString = try? NSMutableAttributedString(html: body) {
                    bodyTextView.attributedText = attributedString
                } else {
                    bodyTextView.text = "Failed to parse message body"
                }
            }
        } else {
            activeLock = true
        }
        
        for (index, attachment) in message.attachments.enumerated() {
            let control = UIControl()
            control.translatesAutoresizingMaskIntoConstraints = false
            control.tag = index
            let view = UIStackView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.heightAnchor.constraint(equalToConstant: 30).isActive = true
            view.axis = .horizontal
            view.isUserInteractionEnabled = false
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = attachment.filename
            label.isUserInteractionEnabled = false
            let image = UIImageView()
            image.translatesAutoresizingMaskIntoConstraints = false
            image.image = UIImage(systemName: "arrow.down.circle")
            image.contentMode = .scaleAspectFit
            image.isUserInteractionEnabled = false
            control.addSubview(view)
            view.addArrangedSubview(label)
            view.addArrangedSubview(image)
            
            NSLayoutConstraint.activate([
                view.heightAnchor.constraint(equalToConstant: 30),
                control.topAnchor.constraint(equalTo: view.topAnchor),
                control.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                control.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                control.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                image.heightAnchor.constraint(equalToConstant: 25),
                image.widthAnchor.constraint(equalToConstant: 25)
            ])
            
            control.addTarget(self, action: #selector(downloadAttachment(_:)), for: .touchUpInside)
            self.embedStackView.addArrangedSubview(control)
        }
    }
    
    @objc private func downloadAttachment(_ control: UIControl) {
        let attachment = message.attachments[control.tag]
        if Message.attachmentFolder.dirExists {
            if attachment.fileDestination.exists {
                return display(with: attachment.fileDestination)
            }
        } else {
            try? FileManager.default.createDirectory(at: Message.attachmentFolder, withIntermediateDirectories: true)
        }
        
        let alert = UIAlertController(title: "Downloading \(attachment.filename)", message: "Resolving", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.view.tintColor = .tintColor
        present(alert, animated: true) { [weak self] in
            guard let self = self else { return }
            var foundLabel: UILabel?
            @discardableResult func findTheFuckingLabel(_ view: UIView) -> Bool {
                for view in view.subviews {
                    if let label = view as? UILabel,
                       label.text == "Resolving" {
                        foundLabel = label
                        return true
                    }
                    if findTheFuckingLabel(view) {
                        return true
                    }
                }
                return false
            }
            findTheFuckingLabel(alert.view)
            self.message.getAttachment(attachment: attachment) { error, url in
                guard let url = url else {
                    Thread.mainBlock {
                        foundLabel?.text = error ?? "Unknown Error"
                    }
                    return
                }
                if url.isFileURL {
                    return self.display(with: url)
                } else {
                    let downloader = EvanderDownloader(url: url)
                    downloader.make()
                    downloader.progressCallback = { progress in
                        let percent = progress.fractionCompleted * 100.0
                        Thread.mainBlock {
                            foundLabel?.text = "\(Int(percent))% downloaded"
                        }
                    }
                    downloader.errorCallback = { _, error, _ in
                        Thread.mainBlock {
                            foundLabel?.text = error?.localizedDescription
                        }
                    }
                    downloader.didFinishCallback = { _, url in
                        try? FileManager.default.moveItem(at: url, to: attachment.fileDestination)
                        self.display(with: attachment.fileDestination)
                    }
                    downloader.resume()
                }
            }
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        Thread.mainBlock { [weak self] in
            if let body = self?.message.body {
                if UIApplication.shared.applicationState == .active {
                    if let attributedString = try? NSMutableAttributedString(html: body) {
                        self?.bodyTextView.attributedText = attributedString
                    } else {
                        self?.bodyTextView.text = "Failed to parse message body"
                    }
                } else {
                    self?.activeLock = true
                }
            }
        }
    }
    
    private func display(with url: URL) {
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.display(with: url)
            }
            return
        }
        self.dismiss(animated: true)
        
        targetURL = url
        let quickLookViewController = QLPreviewController()
        quickLookViewController.view.tintColor = .tintColor
        quickLookViewController.dataSource = self
        quickLookViewController.currentPreviewItemIndex = 0
        present(quickLookViewController, animated: true)
    }
}

extension MessageViewController: QLPreviewControllerDataSource {
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        targetURL! as NSURL
    }
}
