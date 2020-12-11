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
    @IBOutlet weak var rightNavigationButton: UIButton!
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
            vc.senderContext = self
        }
    }
    
    @IBAction func rightNavigationButton(_ sender: Any) {
        switch context {
        case .timetable: NotificationCenter.default.post(name: .TimetableButtonPressed, object: nil)
        default: break
        }
    }
}

//MARK: - Homework
extension CarouselContainerController {
    private func homeworkSetup() {
        self.title = "Homework"
        if !(EduLinkAPI.shared.homework.current.isEmpty && EduLinkAPI.shared.homework.past.isEmpty) {
            self.activityIndicator.isHidden = true
        }
        NotificationCenter.default.addObserver(self, selector: #selector(hide), name: .SuccesfulHomework, object: nil)
        self.rightNavigationButton.isHidden = true
    }
}

extension CarouselContainerController {
    private func timetableSetup() {
        self.title = "Timetable"
        if EduLinkAPI.shared.weeks.isEmpty {
            self.activityIndicator.isHidden = true
        }
        NotificationCenter.default.addObserver(self, selector: #selector(hide), name: .SuccesfulTimetable, object: nil)
        self.rightNavigationButton.setTitle("", for: .normal)
    }
}
