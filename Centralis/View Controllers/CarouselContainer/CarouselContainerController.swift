//
//  HomeworkContainerController.swift
//  Centralis
//
//  Created by Amy While on 05/12/2020.
//

import UIKit

enum CarouselContext {
    case homework
    case timetable
}

class CarouselContainerController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var context: CarouselContext?
    
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
        switch context {
        case .homework: self.homeworkSetup()
        case .timetable: self.timetableSetup()
        case .none: break
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Centralis.CarouselEmbed" {
            let vc = segue.destination as! CarouselController
            vc.context = context
        }
    }
}

//MARK: - Homework
extension CarouselContainerController {
    private func homeworkSetup() {
        self.title = "Homework"
        if !(EduLinkAPI.shared.homework.current.isEmpty || EduLinkAPI.shared.homework.past.isEmpty) {
            self.activityIndicator.isHidden = true
        }
        NotificationCenter.default.addObserver(self, selector: #selector(hide), name: .SuccesfulHomework, object: nil)
    }
}

extension CarouselContainerController {
    private func timetableSetup() {
        self.title = "Timetable"
        if EduLinkAPI.shared.weeks.isEmpty {
            self.activityIndicator.isHidden = true
        }
        NotificationCenter.default.addObserver(self, selector: #selector(hide), name: .SuccesfulTimetable, object: nil)
    }
}
