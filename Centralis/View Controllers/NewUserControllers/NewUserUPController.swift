//
//  NewUserUPController.swift
//  Centralis
//
//  Created by Amy While on 28/12/2020.
//

import UIKit

class NewUserUPController: UIViewController {

    @IBOutlet weak var schoolImage: UIImageView!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
    private func setup() {
        self.schoolImage.image = EduLinkAPI.shared.authorisedSchool.schoolLogo
    }

    @IBAction func login(_ sender: Any) {
    }
}

