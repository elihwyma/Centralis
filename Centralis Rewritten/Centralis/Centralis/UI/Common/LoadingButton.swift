//
//  LoadingButton.swift
//  Centralis
//
//  Created by Andromeda on 26/11/2021.
//

import UIKit
import Evander

class LoadingButton: UIButton {

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.isHidden = true
        
        addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            indicator.topAnchor.constraint(equalTo: topAnchor, constant: 2.5),
            indicator.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2.5)
        ])
        return indicator
    }()

    public var isLoading: Bool = false {
        didSet {
            FRUIView.animate(withDuration: 0.1) { [weak self] in
                if self?.isLoading ?? false {
                    self?.activityIndicator.isHidden = false
                    self?.activityIndicator.startAnimating()
                    self?.setTitleColor(.clear, for: .normal)
                } else {
                    self?.setTitleColor(.label, for: .normal)
                    self?.activityIndicator.stopAnimating()
                }
            }
            
        }
    }
}
