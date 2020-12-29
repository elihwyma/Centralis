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
    case behaviour
    case attendance
}

class CarouselContainerController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var rightNavigationButton: UIButton!
    var context: CarouselContext?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
    private func setup() {
        switch context {
        case .homework: self.homeworkSetup()
        case .timetable: self.timetableSetup()
        case .behaviour: self.behaviourSetup()
        case .attendance: self.attendanceSetup()
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
        self.rightNavigationButton.isHidden = true
    }
}

//MARK: - Timetable
extension CarouselContainerController {
    private func timetableSetup() {
        self.title = "Timetable"
        if EduLinkAPI.shared.weeks.isEmpty {
            self.activityIndicator.isHidden = true
        }
        self.rightNavigationButton.setTitle("", for: .normal)
    }
}

//MARK: - Behaviour
extension CarouselContainerController {
    private func behaviourSetup() {
        self.title = "Behaviour"
        if !EduLinkAPI.shared.achievementBehaviourLookups.behaviours.isEmpty {
            self.activityIndicator.isHidden = true
        }

        self.rightNavigationButton.isHidden = true
    }
}

//MARK: - Attendance
extension CarouselContainerController {
    private func attendanceSetup() {
        self.title = "Attendance"
        if !EduLinkAPI.shared.attendance.lessons.isEmpty || !EduLinkAPI.shared.attendance.statutory.isEmpty {
            self.activityIndicator.isHidden = true
        }
        self.rightNavigationButton.isHidden = true
    }
}
