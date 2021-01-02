//
//  QuickLessonView.swift
//  Centralis
//
//  Created by Amy While on 02/01/2021.
//

import UIKit

class QuickLessonView: UIView {
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var lesson: UILabel!
    @IBOutlet weak var teacher: UILabel!
    @IBOutlet weak var room: UILabel!
    @IBOutlet weak var time: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 10
    }
}
