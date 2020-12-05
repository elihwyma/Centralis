//
//  HomeworkContainerController.swift
//  Centralis
//
//  Created by Amy While on 05/12/2020.
//

import UIKit

class HomeworkContainerController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setup()
    }
    
    @objc private func hide() {
        DispatchQueue.main.async {
            self.activityIndicator.isHidden = true
        }
    }
    
    private func setup() {
        self.title = "Homework"
        if !(EduLinkAPI.shared.homework.current.isEmpty || EduLinkAPI.shared.homework.past.isEmpty) {
            self.activityIndicator.isHidden = true
        }
        NotificationCenter.default.addObserver(self, selector: #selector(hide), name: .SuccesfulHomework, object: nil)
    }
}
