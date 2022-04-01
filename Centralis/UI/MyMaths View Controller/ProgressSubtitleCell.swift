//
//  ProgressSubtitleCell.swift
//  Centralis
//
//  Created by Amy While on 12/03/2022.
//

import UIKit
import Evander

class ProgressSubtitleCell: UITableViewCell {
    
    private var progressBar: UIProgressView = {
        let view = UIProgressView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 1.5).isActive = true
        view.progressViewStyle = .bar
        return view
    }()
    public weak var task: MyMathsTaskCompletionViewController.Task?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(progressBar)
        NSLayoutConstraint.activate([
            progressBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            progressBar.trailingAnchor.constraint(equalTo: trailingAnchor),
            progressBar.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        progressBar.progress = 0
    }
    
    public func setProgress(_ progress: Float) {
        Thread.mainBlock { [weak self] in
            self?.progressBar.progress = progress
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
